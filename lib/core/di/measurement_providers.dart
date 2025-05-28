import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:renal_care_app/features/home/data/services/measurement_remote_service.dart';
import 'package:renal_care_app/features/home/data/repositories/measurement_repository_impl.dart';
import 'package:renal_care_app/features/home/domain/repositories/measurement_repository.dart';
import 'package:renal_care_app/features/home/domain/usecases/add_water_glass.dart';
import 'package:renal_care_app/features/home/domain/usecases/get_measurements.dart';
import 'package:renal_care_app/features/home/domain/usecases/get_sleep_history.dart';
import 'package:renal_care_app/features/home/domain/usecases/update_measurement.dart';
import 'package:renal_care_app/features/home/domain/usecases/update_water.dart';
import 'package:renal_care_app/features/home/domain/usecases/update_sleep.dart';
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

/// ViewModel
final measurementViewModelProvider =
    StateNotifierProvider<MeasurementViewModel, MeasurementState>((ref) {
      return MeasurementViewModel(
        ref,
        ref.watch(getLatestMeasurementProvider),
        ref.watch(updateMeasurementProvider),
        ref.watch(getTodayWaterProvider),
        ref.watch(updateTodayWaterProvider),
        ref.watch(getTodaySleepProvider),
        ref.watch(updateTodaySleepProvider),
      );
    });
