import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:renal_care_app/features/home/domain/usecases/get_today_sleep.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_state.dart';
import 'package:renal_care_app/features/home/domain/entities/measurement.dart';
import 'package:renal_care_app/features/home/domain/entities/water_intake.dart';
import 'package:renal_care_app/features/home/domain/entities/sleep_record.dart';
import 'package:renal_care_app/features/home/domain/usecases/add_allergy.dart';
import 'package:renal_care_app/features/home/domain/usecases/add_water_glass.dart';
import 'package:renal_care_app/features/home/domain/usecases/delete_allergy.dart';
import 'package:renal_care_app/features/home/domain/usecases/get_measurements.dart';
import 'package:renal_care_app/features/home/domain/usecases/list_allergies.dart';
import 'package:renal_care_app/features/home/domain/usecases/update_measurement.dart';
import 'package:renal_care_app/features/home/domain/usecases/update_water.dart';
import 'package:renal_care_app/features/home/domain/usecases/update_sleep.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:renal_care_app/features/home/presentation/viewmodels/measurement_state.dart';

class MeasurementViewModel extends StateNotifier<MeasurementState> {
  final Ref _ref;
  final GetLatestMeasurement _getMeasurement;
  final UpdateMeasurement _updateMeasurement;
  final GetTodayWater _getWater;
  final UpdateTodayWater _updateWater;
  final GetTodaySleep _getSleep;
  final UpdateTodaySleep _updateSleep;
  final ListAllergies _listAllergies;
  final AddAllergy _addAllergy;
  final DeleteAllergy _deleteAllergy;

  MeasurementViewModel(
    this._ref,
    this._getMeasurement,
    this._updateMeasurement,
    this._getWater,
    this._updateWater,
    this._getSleep,
    this._updateSleep,
    this._listAllergies,
    this._addAllergy,
    this._deleteAllergy,
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
    // Încarcă datele inițiale
    _loadAll();

    // Ascultă stream-ul de alergii
    final uid = _ref.read(authViewModelProvider).user!.uid;
    _listAllergies(uid).listen((allergies) {
      // când vine o nouă listă, o pui în state
      state = state.copyWith(allergies: allergies);
    });
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

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('measurement_documents')
        .add({
          'name':
              'Water: ${newWater.glasses * state.glassSizeMl} ml at ${DateFormat('HH:mm').format(today)}',
          'reportType': 'water',
          'data': {
            'glasses': newWater.glasses,
            'ml': newWater.glasses * state.glassSizeMl,
          },
          'addedAt': Timestamp.now(),
        });
  }

  Future<void> saveMeasurement(Measurement m) async {
    state = state.copyWith(loading: true);
    final uid = _ref.read(authViewModelProvider).user!.uid;
    await _updateMeasurement(uid, m);
    state = state.copyWith(measurement: m, loading: false);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('measurement_documents')
        .add({
          'name':
              'Measurement at ${DateFormat('dd MMM yyyy HH:mm').format(m.date)}',
          'reportType': 'measurements',
          'data': {
            'weight': m.weight,
            'height': m.height,
            'bmi': m.bmi,
            'glucose': m.glucose,
            'systolic': m.systolic,
            'diastolic': m.diastolic,
            'temperature': m.temperature,
            'moment': m.moment,
          },
          'addedAt': Timestamp.now(),
        });
  }

  Future<void> setSleep(double hours) async {
    final uid = _ref.read(authViewModelProvider).user!.uid;
    final now = DateTime.now();

    final totalMinutes = (hours * 60).round();
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;

    final newSleep = SleepRecord(date: now, hours: hours, start: now, end: now);
    await _updateSleep(uid, newSleep);
    state = state.copyWith(sleep: newSleep);

    final name = 'Sleep: $h h $m m on ${DateFormat('dd MMM yyyy').format(now)}';

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('measurement_documents')
        .add({
          'name': name,
          'reportType': 'sleep',
          'data': {
            'hours': hours,
            'start': Timestamp.fromDate(newSleep.start),
            'end': Timestamp.fromDate(newSleep.end),
          },
          'addedAt': Timestamp.now(),
        });
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
    final recordDate = DateTime(start.year, start.month, start.day);

    final totalMinutes = (hours * 60).round();
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;

    await _updateSleep(
      uid,
      SleepRecord(date: recordDate, hours: hours, start: start, end: end),
    );
    state = state.copyWith(
      sleep: SleepRecord(
        date: recordDate,
        hours: hours,
        start: start,
        end: end,
      ),
      sleepStart: start,
      sleepEnd: end,
    );

    final name =
        'Sleep: $h h $m m on ${DateFormat('dd MMM yyyy').format(recordDate)}';

    // loghezi documentul în Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('measurement_documents')
        .add({
          'name': name,
          'reportType': 'sleep',
          'data': {
            'hours': hours,
            'start': Timestamp.fromDate(start),
            'end': Timestamp.fromDate(end),
          },
          'addedAt': Timestamp.now(),
        });
  }

  /// Adaugă o nouă alergie și starea va fi actualizată automat
  Future<void> addAllergy(String name) async {
    final uid = _ref.read(authViewModelProvider).user!.uid;
    await _addAllergy(uid, name);
  }

  /// Șterge alergia cu acel ID
  Future<void> deleteAllergy(String allergyId) async {
    final uid = _ref.read(authViewModelProvider).user!.uid;
    await _deleteAllergy(uid, allergyId);
  }
}
