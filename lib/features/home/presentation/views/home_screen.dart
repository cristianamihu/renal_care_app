import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:renal_care_app/core/theme/app_colors.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';

/// Helper: fetch paginat spitale (20 rezultate/page, token-ul devine activ după ~2s)
Future<List<dynamic>> _fetchAllHospitals(
  double lat,
  double lng,
  String apiKey,
) async {
  List<dynamic> all = [];
  String? nextPage;
  do {
    final params = {
      'location': '$lat,$lng',
      'radius': '15000',
      'type': 'hospital',
      'key': apiKey,
      if (nextPage != null) 'pagetoken': nextPage,
    };
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/nearbysearch/json',
      params,
    );
    final res = await http.get(uri);
    if (res.statusCode != 200) break;

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    all.addAll(body['results'] as List<dynamic>? ?? []);
    nextPage = body['next_page_token'] as String?;
    if (nextPage != null) {
      // Give the token a moment to become valid
      await Future.delayed(const Duration(seconds: 2));
    }
  } while (nextPage != null);

  return all;
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, this.title = 'RenalCare'});
  final String title;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  //cheia Google Maps / Places
  static const _googleApiKey = 'AIzaSyC5P7W7EMfx3O0axZaECuYZBkrNCIuqFMw';

  final Completer<GoogleMapController> _mapCtrl = Completer();
  final Set<Marker> _markers = {};
  Position? _myPos; // poziția curentă
  DateTime? _lastBackPress; // pentru “press back again”

  // camera inițială: Romania centric
  static const _defaultCamera = CameraPosition(
    target: LatLng(45.9432, 24.9668),
    zoom: 8,
  );

  @override
  Widget build(BuildContext context) {
    // Handle back press for exiting the app
    return PopScope(
      canPop: false, // Prevent default pop
      onPopInvokedWithResult: (_, __) async {
        final now = DateTime.now();
        if (_lastBackPress == null ||
            now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
          _lastBackPress = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Apasă din nou pentru a ieși din aplicație'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // Exit the app on second back press
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        // APP BAR
        appBar: AppBar(
          // transparenţă + gradient pe toată suprafaţa
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

          // Titlu şi iconiţe în alb
          title: Text(
            widget.title,
            style: const TextStyle(color: AppColors.whiteColor),
          ),
          iconTheme: const IconThemeData(color: AppColors.whiteColor),
          actions: [
            // Chat button
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              tooltip: 'Chat',
              onPressed: () => context.go('/chat'),
            ),
            // Logout button
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _handleLogout,
            ),
          ],
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
                    child: GoogleMap(
                      initialCameraPosition: _defaultCamera,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      markers: _markers,
                      onMapCreated: (controller) {
                        if (!_mapCtrl.isCompleted) {
                          _mapCtrl.complete(controller);
                          _initializeMap(controller);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),

            //buton apel
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
                    icon: const Icon(
                      Icons.phone,
                      size: 32,
                      color: Colors.white,
                    ),
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
      ),
    );
  }

  // Handle user logout
  Future<void> _handleLogout() async {
    await ref.read(authViewModelProvider.notifier).signOut();
    if (!mounted) return;
    // Navigate to login screen after logout
    context.go('/login');
  }

  /// Cere permisiunea CALL_PHONE și, dacă e OK, sună direct la 112
  Future<void> _call112Direct() async {
    // 1. Cerem permisiunea
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
    // 2. Apel direct
    await FlutterPhoneDirectCaller.callNumber('0770915846');
  }

  Future<void> _initializeMap(GoogleMapController map) async {
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
    try {
      _myPos = await Geolocator.getCurrentPosition(
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

    if (_myPos == null) return;

    // Animă camera la zoom mare pe poziția ta
    map.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(_myPos!.latitude, _myPos!.longitude),
        15, // Zoom level adjusted to see a 15km radius better
      ),
    );

    // preia toate spitalele
    final places = await _fetchAllHospitals(
      _myPos!.latitude,
      _myPos!.longitude,
      _googleApiKey,
    );

    // Construiește marker‐e și calculează distanța
    final newMarkers =
        places.map<Marker>((p) {
          final loc =
              (p['geometry']['location'] as Map).cast<String, dynamic>();
          final name = p['name'] as String;
          final vicinity = (p['vicinity'] as String?) ?? 'Adresă necunoscută';
          final id = p['place_id'] as String;

          final dist = Geolocator.distanceBetween(
            _myPos!.latitude,
            _myPos!.longitude,
            loc['lat'],
            loc['lng'],
          );
          final distKm = (dist / 1000).toStringAsFixed(1);

          return Marker(
            markerId: MarkerId(id),
            position: LatLng(loc['lat'], loc['lng']),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(
              title: name,
              snippet: '$vicinity • $distKm km',
            ),
          );
        }).toSet();

    //  afișează marcatoarele și recalibrează bounds-ul
    setState(() {
      _markers.clear();
      _markers.addAll(newMarkers);
    });
  }
}
