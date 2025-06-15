import 'package:renal_care_app/features/home/domain/entities/water_intake.dart';
import 'package:renal_care_app/features/home/domain/repositories/measurement_repository.dart';

class GetWaterHistory {
  final MeasurementRepository _repo;
  GetWaterHistory(this._repo);

  Future<List<WaterIntake>> call(String uid, DateTime from, DateTime to) {
    return _repo.getWaterHistory(uid, from, to);
  }
}
