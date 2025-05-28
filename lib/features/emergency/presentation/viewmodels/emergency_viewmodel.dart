import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:renal_care_app/core/di/emergency_providers.dart';
import 'package:renal_care_app/features/emergency/domain/entities/hospital.dart';
import 'package:renal_care_app/features/emergency/domain/usecases/get_nearby_hospitals.dart';

final emergencyViewModelProvider =
    StateNotifierProvider<EmergencyViewModel, AsyncValue<List<Hospital>>>((
      ref,
    ) {
      return EmergencyViewModel(ref.watch(getNearbyHospitalsUseCaseProvider));
    });

class EmergencyViewModel extends StateNotifier<AsyncValue<List<Hospital>>> {
  final GetNearbyHospitals _getHospitals;
  EmergencyViewModel(this._getHospitals) : super(const AsyncValue.loading());

  Future<void> load(double lat, double lng) async {
    try {
      final list = await _getHospitals(lat, lng);
      state = AsyncValue.data(list);
    } catch (e, st) {
      // Trimitem și stackTrace, așa cum necesită AsyncValue.error
      state = AsyncValue.error(e, st);
    }
  }
}
