import 'package:renal_care_app/features/home/domain/repositories/measurement_repository.dart';

class DeleteAllergy {
  final MeasurementRepository _repo;
  DeleteAllergy(this._repo);

  /// Şterge alergia cu ID-ul dat
  Future<void> call(String uid, String allergyId) {
    return _repo.deleteAllergy(uid, allergyId);
  }
}
