import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:renal_care_app/features/emergency/data/services/hospital_remote_service.dart';
import 'package:renal_care_app/features/emergency/data/repositories/hospital_repository_impl.dart';
import 'package:renal_care_app/features/emergency/domain/entities/hospital.dart';
import 'package:renal_care_app/features/emergency/domain/repositories/hospital_repository.dart';
import 'package:renal_care_app/features/emergency/domain/usecases/get_nearby_hospitals.dart';
import 'package:renal_care_app/features/emergency/presentation/viewmodels/emergency_viewmodel.dart';

// Remote service
final hospitalRemoteServiceProvider = Provider<HospitalRemoteService>((_) {
  return HospitalRemoteService();
});

// Repository
final hospitalRepositoryProvider = Provider<HospitalRepository>((ref) {
  return HospitalRepositoryImpl(ref.watch(hospitalRemoteServiceProvider));
});

// Use-case
final getNearbyHospitalsUseCaseProvider = Provider<GetNearbyHospitals>((ref) {
  return GetNearbyHospitals(ref.watch(hospitalRepositoryProvider));
});

final emergencyViewModelProvider =
    StateNotifierProvider<EmergencyViewModel, AsyncValue<List<Hospital>>>(
      (ref) => EmergencyViewModel(ref.watch(getNearbyHospitalsUseCaseProvider)),
    );
