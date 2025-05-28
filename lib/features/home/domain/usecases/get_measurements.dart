import 'package:renal_care_app/features/home/domain/entities/measurement.dart';
import 'package:renal_care_app/features/home/domain/repositories/measurement_repository.dart';

class GetLatestMeasurement {
  final MeasurementRepository _repo;
  GetLatestMeasurement(this._repo);
  Future<Measurement?> call(String uid) => _repo.getLatestMeasurement(uid);
}
