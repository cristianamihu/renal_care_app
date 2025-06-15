import 'package:renal_care_app/features/home/domain/entities/sleep_record.dart';
import 'package:renal_care_app/features/home/domain/repositories/measurement_repository.dart';

class GetSleepHistory {
  final MeasurementRepository _repo;
  GetSleepHistory(this._repo);

  /// Returnează lista de SleepRecord între două date
  Future<List<SleepRecord>> call(String uid, DateTime from, DateTime to) {
    return _repo.getSleepHistory(uid, from, to);
  }
}
