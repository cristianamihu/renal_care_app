import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:renal_care_app/features/home/data/models/measurement_model.dart';
import 'package:renal_care_app/features/home/data/models/sleep_record_model.dart';
import 'package:renal_care_app/features/home/data/models/water_intake_model.dart';
import 'package:renal_care_app/features/home/data/services/measurement_remote_service.dart';
import 'package:renal_care_app/features/home/domain/entities/measurement.dart';
import 'package:renal_care_app/features/home/domain/entities/water_intake.dart';
import 'package:renal_care_app/features/home/domain/entities/sleep_record.dart';
import 'package:renal_care_app/features/home/domain/repositories/measurement_repository.dart';

class MeasurementRepositoryImpl implements MeasurementRepository {
  final MeasurementRemoteService _remote;
  MeasurementRepositoryImpl(this._remote);

  @override
  Future<Measurement?> getLatestMeasurement(String uid) async {
    final model = await _remote.fetchLatestMeasurement(uid);
    return model?.toEntity();
  }

  @override
  Future<void> updateMeasurement(String uid, Measurement m) async {
    final model = MeasurementModel(
      weight: m.weight,
      height: m.height,
      bmi: m.bmi,
      glucose: m.glucose,
      systolic: m.systolic,
      diastolic: m.diastolic,
      temperature: m.temperature,
      date: Timestamp.fromDate(m.date),
      moment: m.moment,
    );
    await _remote.updateMeasurement(uid, model);
  }

  @override
  Future<WaterIntake> getTodayWater(String uid) async {
    final model = await _remote.fetchTodayWater(uid);
    return model.toEntity();
  }

  @override
  Future<void> updateTodayWater(String uid, WaterIntake w) async {
    final model = WaterIntakeModel(
      date: Timestamp.fromDate(w.date),
      glasses: w.glasses,
    );
    await _remote.saveTodayWater(uid, model);
  }

  @override
  Future<SleepRecord> getTodaySleep(String uid) async {
    final model = await _remote.fetchTodaySleep(uid);
    return model.toEntity();
  }

  @override
  Future<void> updateTodaySleep(String uid, SleepRecord s) async {
    final model = SleepRecordModel(
      date: Timestamp.fromDate(s.date),
      hours: s.hours,
      start: Timestamp.fromDate(s.start),
      end: Timestamp.fromDate(s.end),
    );
    await _remote.saveTodaySleep(uid, model);
  }
}
