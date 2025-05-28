import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:renal_care_app/core/theme/app_colors.dart';
import 'package:renal_care_app/features/emergency/presentation/viewmodels/emergency_viewmodel.dart';

class EmergencyPage extends ConsumerStatefulWidget {
  const EmergencyPage({super.key});

  @override
  ConsumerState<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends ConsumerState<EmergencyPage> {
  final Completer<GoogleMapController> _mapCtrl = Completer();
  Set<Marker> _markers = {};
  LatLng? _center;

  // camera inițială: Romania centric
  static const _defaultCamera = CameraPosition(
    target: LatLng(45.9432, 24.9668),
    zoom: 7,
  );

  @override
  Widget build(BuildContext context) {
    final hospitalsState = ref.watch(emergencyViewModelProvider);
    // Handle back press for exiting the app

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.gradient1,
                AppColors.gradient2,
                AppColors.gradient3,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/home'),
          tooltip: 'Înapoi acasă',
        ),
        title: const Text('Emergency', style: TextStyle(color: Colors.white)),
      ),

      // BODY: Google Map widget sus, barăde conținut jos
      body: Column(
        children: [
          //textul de deasupra hărții
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'In case of emergency, search for the nearest hospital',
              style: TextStyle(
                color: AppColors.whiteColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // harta
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.1 * 255).round()),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: _defaultCamera,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        markers: _markers,
                        onMapCreated: (controller) {
                          if (!_mapCtrl.isCompleted) {
                            _mapCtrl.complete(controller);
                            _initLocation(controller);
                          }
                        },
                      ),

                      // loading & eroare
                      hospitalsState.when(
                        loading:
                            () => const Positioned.fill(
                              child: Center(child: CircularProgressIndicator()),
                            ),
                        error:
                            (e, _) => Positioned(
                              bottom: 16,
                              left: 16,
                              child: Text(
                                'Error: \$e',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                        data: (hospitals) {
                          if (_center == null) {
                            // dacă încă nu avem locaţia, arată încărcător
                            return const Positioned.fill(
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          // când vin datele, construim marker-ele cu distanță
                          final newMarkers =
                              hospitals.map((h) {
                                final dist = Geolocator.distanceBetween(
                                  _center!.latitude,
                                  _center!.longitude,
                                  h.lat,
                                  h.lng,
                                );
                                final distKm = (dist / 1000).toStringAsFixed(1);
                                return Marker(
                                  markerId: MarkerId(h.id),
                                  position: LatLng(h.lat, h.lng),
                                  infoWindow: InfoWindow(
                                    title: h.name,
                                    snippet: '${h.vicinity} • $distKm km',
                                  ),
                                );
                              }).toSet();

                          // actualizăm marker-ele
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted) return;
                            setState(() => _markers = newMarkers);
                          });

                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          //buton apel 112
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            child: Semantics(
              button: true,
              label: 'Buton apel de urgență',
              hint: 'Atinge pentru a suna la 112',
              child: Tooltip(
                message: 'Apel de urgență 112',
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.phone, size: 32, color: Colors.white),
                  label: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Apel direct în caz de urgență',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '112',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  onPressed: _call112Direct,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Cere permisiunea CALL_PHONE și, dacă e OK, sună direct la 112
  Future<void> _call112Direct() async {
    // Cerem permisiunea
    final status = await Permission.phone.request();
    if (!status.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permisiunea de apel direct a fost refuzată'),
        ),
      );
      return;
    }
    // Apel direct
    await FlutterPhoneDirectCaller.callNumber('0770915846');
  }

  Future<void> _initLocation(GoogleMapController map) async {
    // permisiuni
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permisiunea de locație este necesară')),
      );
      return;
    }

    // obține poziția curentă
    Position pos;
    try {
      pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nu s-a putut obține locația: $e')),
      );
      return;
    }

    _center = LatLng(pos.latitude, pos.longitude);

    // Trimitem coordonatele în ViewModel
    ref
        .read(emergencyViewModelProvider.notifier)
        .load(pos.latitude, pos.longitude);
    // Animăm camera imediat ce avem controller
    map.animateCamera(CameraUpdate.newLatLngZoom(_center!, 15));
  }
}
