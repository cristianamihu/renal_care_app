import 'package:renal_care_app/features/home/domain/entities/measurement.dart';
import 'package:renal_care_app/features/home/domain/entities/water_intake.dart';
import 'package:renal_care_app/features/home/domain/entities/sleep_record.dart';

abstract class MeasurementRepository {
  Future<Measurement?> getLatestMeasurement(String uid);
  Future<void> updateMeasurement(String uid, Measurement m);

  Future<WaterIntake> getTodayWater(String uid);
  Future<void> updateTodayWater(String uid, WaterIntake w);

  Future<SleepRecord> getTodaySleep(String uid);
  Future<void> updateTodaySleep(String uid, SleepRecord s);
}
