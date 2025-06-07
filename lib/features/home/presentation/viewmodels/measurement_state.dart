import 'package:renal_care_app/features/home/domain/entities/measurement.dart';
import 'package:renal_care_app/features/home/domain/entities/sleep_record.dart';
import 'package:renal_care_app/features/home/domain/entities/water_intake.dart';

class MeasurementState {
  final Measurement? measurement;
  final WaterIntake water;
  final SleepRecord sleep;
  final bool loading;
  final String? error;
  final int waterGoalMl;
  final int glassSizeMl;
  final DateTime? sleepStart;
  final DateTime? sleepEnd;

  MeasurementState({
    this.measurement,
    required this.water,
    required this.sleep,
    this.loading = false,
    this.error,
    this.waterGoalMl = 2000,
    this.glassSizeMl = 200,
    this.sleepStart,
    this.sleepEnd,
  });

  MeasurementState copyWith({
    Measurement? measurement,
    WaterIntake? water,
    SleepRecord? sleep,
    bool? loading,
    String? error,
    int? waterGoalMl,
    int? glassSizeMl,
    DateTime? sleepStart,
    DateTime? sleepEnd,
  }) => MeasurementState(
    measurement: measurement ?? this.measurement,
    water: water ?? this.water,
    sleep: sleep ?? this.sleep,
    loading: loading ?? this.loading,
    error: error,
    sleepStart: sleepStart ?? this.sleepStart,
    sleepEnd: sleepEnd ?? this.sleepEnd,
  );
}
