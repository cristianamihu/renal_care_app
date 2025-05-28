import 'package:renal_care_app/features/home/domain/entities/water_intake.dart';
import 'package:renal_care_app/features/home/domain/repositories/measurement_repository.dart';

class UpdateTodayWater {
  final MeasurementRepository _repo;
  UpdateTodayWater(this._repo);
  Future<void> call(String uid, WaterIntake w) =>
      _repo.updateTodayWater(uid, w);
}
