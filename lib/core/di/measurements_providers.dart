import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:renal_care_app/features/auth/data/models/measurement_document_model.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:renal_care_app/features/home/data/services/measurement_remote_service.dart';
import 'package:renal_care_app/features/home/data/repositories/measurement_repository_impl.dart';
import 'package:renal_care_app/features/home/domain/repositories/measurement_repository.dart';
import 'package:renal_care_app/features/home/domain/usecases/add_allergy.dart';
import 'package:renal_care_app/features/home/domain/usecases/add_water_glass.dart';
import 'package:renal_care_app/features/home/domain/usecases/delete_allergy.dart';
import 'package:renal_care_app/features/home/domain/usecases/get_measurements.dart';
import 'package:renal_care_app/features/home/domain/usecases/get_sleep_history.dart';
import 'package:renal_care_app/features/home/domain/usecases/list_allergies.dart';
import 'package:renal_care_app/features/home/domain/usecases/update_measurement.dart';
import 'package:renal_care_app/features/home/domain/usecases/update_water.dart';
import 'package:renal_care_app/features/home/domain/usecases/update_sleep.dart';
import 'package:renal_care_app/features/home/presentation/viewmodels/measurement_state.dart';
import 'package:renal_care_app/features/home/presentation/viewmodels/measurement_viewmodel.dart';

/// Remote service
final measurementRemoteServiceProvider = Provider<MeasurementRemoteService>((
  _,
) {
  return MeasurementRemoteService();
});

/// Repository
final measurementRepositoryProvider = Provider<MeasurementRepository>((ref) {
  return MeasurementRepositoryImpl(ref.watch(measurementRemoteServiceProvider));
});

/// Use-cases
final getLatestMeasurementProvider = Provider<GetLatestMeasurement>((ref) {
  return GetLatestMeasurement(ref.watch(measurementRepositoryProvider));
});

final updateMeasurementProvider = Provider<UpdateMeasurement>((ref) {
  return UpdateMeasurement(ref.watch(measurementRepositoryProvider));
});

final getTodayWaterProvider = Provider<GetTodayWater>((ref) {
  return GetTodayWater(ref.watch(measurementRepositoryProvider));
});

final updateTodayWaterProvider = Provider<UpdateTodayWater>((ref) {
  return UpdateTodayWater(ref.watch(measurementRepositoryProvider));
});

final getTodaySleepProvider = Provider<GetTodaySleep>((ref) {
  return GetTodaySleep(ref.watch(measurementRepositoryProvider));
});

final updateTodaySleepProvider = Provider<UpdateTodaySleep>((ref) {
  return UpdateTodaySleep(ref.watch(measurementRepositoryProvider));
});

final listAllergiesProvider = Provider<ListAllergies>((ref) {
  return ListAllergies(ref.watch(measurementRepositoryProvider));
});

final addAllergyProvider = Provider<AddAllergy>((ref) {
  return AddAllergy(ref.watch(measurementRepositoryProvider));
});

final deleteAllergyProvider = Provider<DeleteAllergy>((ref) {
  return DeleteAllergy(ref.watch(measurementRepositoryProvider));
});

/// ViewModel
final measurementViewModelProvider =
    StateNotifierProvider.autoDispose<MeasurementViewModel, MeasurementState>((
      ref,
    ) {
      return MeasurementViewModel(
        ref,
        ref.watch(getLatestMeasurementProvider),
        ref.watch(updateMeasurementProvider),
        ref.watch(getTodayWaterProvider),
        ref.watch(updateTodayWaterProvider),
        ref.watch(getTodaySleepProvider),
        ref.watch(updateTodaySleepProvider),
        ref.watch(listAllergiesProvider),
        ref.watch(addAllergyProvider),
        ref.watch(deleteAllergyProvider),
      );
    });

final measurementDocsForUserProvider = StreamProvider.autoDispose
    .family<List<MeasurementDocument>, String>((ref, userId) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('measurement_documents')
          .orderBy('addedAt', descending: true)
          .snapshots()
          .map(
            (snap) =>
                snap.docs.map((doc) {
                  final data = doc.data();
                  return MeasurementDocument(
                    id: doc.id,
                    name: data['name'] as String,
                    url: data['url'] as String,
                    addedAt: (data['addedAt'] as Timestamp).toDate(),
                  );
                }).toList(),
          );
    });

/// Scurtătură pentru documentele de măsurări ale user-ului curent
final measurementDocsProvider =
    Provider.autoDispose<AsyncValue<List<MeasurementDocument>>>((ref) {
      final authState = ref.watch(authViewModelProvider);
      final uid = authState.user?.uid;
      if (uid == null) {
        // Dacă nu e niciun user logat, returnează un AsyncValue.data gol
        return const AsyncValue.data(<MeasurementDocument>[]);
      }
      return ref.watch(measurementDocsForUserProvider(uid));
    });
