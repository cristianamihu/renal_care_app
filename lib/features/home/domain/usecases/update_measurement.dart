import 'package:renal_care_app/features/home/domain/entities/measurement.dart';
import 'package:renal_care_app/features/home/domain/repositories/measurement_repository.dart';

class UpdateMeasurement {
  final MeasurementRepository _repo;
  UpdateMeasurement(this._repo);
  Future<void> call(String uid, Measurement m) =>
      _repo.updateMeasurement(uid, m);
}
