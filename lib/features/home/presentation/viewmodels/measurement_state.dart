import 'package:renal_care_app/features/home/domain/entities/allergy.dart';
import 'package:renal_care_app/features/home/domain/entities/measurement.dart';
import 'package:renal_care_app/features/home/domain/entities/sleep_record.dart';
import 'package:renal_care_app/features/home/domain/entities/water_intake.dart';

class MeasurementState {
  final Measurement? measurement;
  final WaterIntake water;
  final SleepRecord sleep;
  final bool loading;
  final String? error;
  final DateTime? sleepStart;
  final DateTime? sleepEnd;
  final int waterGoalMl;
  final int glassSizeMl;
  final List<Allergy> allergies;

  MeasurementState({
    this.measurement,
    required this.water,
    required this.sleep,
    this.loading = false,
    this.error,
    this.sleepStart,
    this.sleepEnd,
    this.waterGoalMl = 3000,
    this.glassSizeMl = 200,
    this.allergies = const [],
  });

  MeasurementState copyWith({
    Measurement? measurement,
    WaterIntake? water,
    SleepRecord? sleep,
    bool? loading,
    String? error,
    DateTime? sleepStart,
    DateTime? sleepEnd,
    int? waterGoalMl,
    int? glassSizeMl,
    List<Allergy>? allergies,
  }) => MeasurementState(
    measurement: measurement ?? this.measurement,
    water: water ?? this.water,
    sleep: sleep ?? this.sleep,
    loading: loading ?? this.loading,
    error: error,
    sleepStart: sleepStart ?? this.sleepStart,
    sleepEnd: sleepEnd ?? this.sleepEnd,
    waterGoalMl: waterGoalMl ?? this.waterGoalMl,
    glassSizeMl: glassSizeMl ?? this.glassSizeMl,
    allergies: allergies ?? this.allergies,
  );
}
