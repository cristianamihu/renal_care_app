import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_state.dart';

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
import 'package:renal_care_app/features/home/presentation/viewmodels/measurement_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    // Ascultăm schimbarea autentificării
    _ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      final oldUid = previous?.user?.uid;
      final newUid = next.user?.uid;
      if (oldUid != newUid) {
        // Dacă s‐a schimbat UID‐ul (login/logout/substituire), reîncarcă TOATE datele:
        _loadAll();
      }
    });
    // Încarcă inițial pentru UID-ul actual (dacă există)
    _loadAll();
  }

  Future<void> _loadAll() async {
    state = state.copyWith(loading: true);

    final uid = _ref.read(authViewModelProvider).user!.uid;

    try {
      final measurement = await _getMeasurement(uid);
      final water = await _getWater(uid);
      final sleep = await _getSleep(uid);
      final prefs = await SharedPreferences.getInstance();
      final goal = prefs.getInt('waterGoalMl') ?? 2000;
      final glass = prefs.getInt('glassSizeMl') ?? 200;

      state = state.copyWith(
        measurement: measurement,
        water: water,
        sleep: sleep,
        sleepStart: sleep.start,
        sleepEnd: sleep.end,
        waterGoalMl: goal,
        glassSizeMl: glass,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> addGlass() async {
    final uid = _ref.read(authViewModelProvider).user!.uid;
    final today = DateTime.now();
    final newWater = WaterIntake(date: today, glasses: state.water.glasses + 1);
    await _updateWater(uid, newWater);
    state = state.copyWith(water: newWater);
  }

  Future<void> saveMeasurement(Measurement m) async {
    state = state.copyWith(loading: true);
    final uid = _ref.read(authViewModelProvider).user!.uid;
    await _updateMeasurement(uid, m);
    state = state.copyWith(measurement: m, loading: false);
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
    // persist în SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('waterGoalMl', goalMl);
    await prefs.setInt('glassSizeMl', glassSizeMl);

    // actualizează starea
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
