import 'package:renal_care_app/features/home/domain/repositories/measurement_repository.dart';

class AddAllergy {
  final MeasurementRepository _repo;
  AddAllergy(this._repo);

  /// Adaugă o alergie nouă în Firestore
  Future<void> call(String uid, String name) {
    return _repo.addAllergy(uid, name);
  }
}
