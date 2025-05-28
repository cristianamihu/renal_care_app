import 'package:renal_care_app/features/home/domain/entities/sleep_record.dart';
import 'package:renal_care_app/features/home/domain/repositories/measurement_repository.dart';

class GetTodaySleep {
  final MeasurementRepository _repo;
  GetTodaySleep(this._repo);
  Future<SleepRecord> call(String uid) => _repo.getTodaySleep(uid);
}
