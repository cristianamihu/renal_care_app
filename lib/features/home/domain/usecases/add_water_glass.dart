import 'package:renal_care_app/features/home/domain/entities/water_intake.dart';
import 'package:renal_care_app/features/home/domain/repositories/measurement_repository.dart';

class GetTodayWater {
  final MeasurementRepository _repo;
  GetTodayWater(this._repo);
  Future<WaterIntake> call(String uid) => _repo.getTodayWater(uid);
}
