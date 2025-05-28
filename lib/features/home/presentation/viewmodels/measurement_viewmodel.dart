import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:renal_care_app/features/home/domain/entities/measurement.dart';
import 'package:renal_care_app/features/home/domain/entities/water_intake.dart';
import 'package:renal_care_app/features/home/domain/entities/sleep_record.dart';
import 'package:renal_care_app/features/home/domain/usecases/add_water_glass.dart';
import 'package:renal_care_app/features/home/domain/usecases/get_measurements.dart';
import 'package:renal_care_app/features/home/domain/usecases/get_sleep_history.dart';
import 'package:renal_care_app/features/home/domain/usecases/update_measurement.dart';
import 'package:renal_care_app/features/home/domain/usecases/update_water.dart';
import 'package:renal_care_app/features/home/domain/usecases/update_sleep.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';

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

class MeasurementViewModel extends StateNotifier<MeasurementState> {
  final Ref _ref;
  final GetLatestMeasurement _getMeasurement;
  final UpdateMeasurement _updateMeasurement;
  final GetTodayWater _getWater;
  final UpdateTodayWater _updateWater;
  final GetTodaySleep _getSleep;
  final UpdateTodaySleep _updateSleep;

  MeasurementViewModel(
    this._ref,
    this._getMeasurement,
    this._updateMeasurement,
    this._getWater,
    this._updateWater,
    this._getSleep,
    this._updateSleep,
  ) : super(
        MeasurementState(
          water: WaterIntake(date: DateTime.now(), glasses: 0),
          sleep: SleepRecord(
            date: DateTime.now(),
            hours: 0,
            start: DateTime.now(),
            end: DateTime.now(),
          ),
        ),
      ) {
    _loadAll();
  }

  Future<void> _loadAll() async {
    state = state.copyWith(loading: true);
    final uid = _ref.read(authViewModelProvider).user!.uid;
    try {
      final measurement = await _getMeasurement(uid);
      final water = await _getWater(uid);
      final sleep = await _getSleep(uid);
      state = state.copyWith(
        measurement: measurement,
        water: water,
        sleep: sleep,
        sleepStart: sleep.start,
        sleepEnd: sleep.end,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> saveMeasurement(Measurement m) async {
    state = state.copyWith(loading: true);
    final uid = _ref.read(authViewModelProvider).user!.uid;
    await _updateMeasurement(uid, m);
    state = state.copyWith(measurement: m, loading: false);
  }

  Future<void> addGlass() async {
    final uid = _ref.read(authViewModelProvider).user!.uid;
    final today = DateTime.now();
    final newWater = WaterIntake(date: today, glasses: state.water.glasses + 1);
    await _updateWater(uid, newWater);
    state = state.copyWith(water: newWater);
  }

  Future<void> setSleep(double hours) async {
    final uid = _ref.read(authViewModelProvider).user!.uid;
    final newSleep = SleepRecord(
      date: DateTime.now(),
      hours: hours,
      start: DateTime.now(),
      end: DateTime.now(),
    );
    await _updateSleep(uid, newSleep);
    state = state.copyWith(sleep: newSleep);
  }

  Future<void> updateWaterSettings(int goalMl, int glassSizeMl) async {
    // eventual salvează în Firestore (poţi folosi un nou use‐case)
    // actualizează state:
    state = state.copyWith(waterGoalMl: goalMl, glassSizeMl: glassSizeMl);
  }

  Future<void> setSleepTimes(DateTime start, DateTime end, double hours) async {
    final uid = _ref.read(authViewModelProvider).user!.uid;
    final today = DateTime.now();
    // persist only hours if you like, or persist times in a new use-case
    // salvezi în Firestore atât hours, cât și start/end
    await _updateSleep(
      uid,
      SleepRecord(date: today, hours: hours, start: start, end: end),
    );
    state = state.copyWith(
      sleep: SleepRecord(date: today, hours: hours, start: start, end: end),
      sleepStart: start,
      sleepEnd: end,
    );
  }
}
