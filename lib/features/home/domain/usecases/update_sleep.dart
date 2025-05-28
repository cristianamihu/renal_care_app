import 'package:renal_care_app/features/home/domain/entities/sleep_record.dart';
import 'package:renal_care_app/features/home/domain/repositories/measurement_repository.dart';

class UpdateTodaySleep {
  final MeasurementRepository _repo;
  UpdateTodaySleep(this._repo);
  Future<void> call(String uid, SleepRecord s) =>
      _repo.updateTodaySleep(uid, s);
}
