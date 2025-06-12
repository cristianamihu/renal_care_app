import 'package:renal_care_app/features/home/domain/entities/allergy.dart';
import 'package:renal_care_app/features/home/domain/repositories/measurement_repository.dart';

class ListAllergies {
  final MeasurementRepository _repo;
  ListAllergies(this._repo);

  /// Returnează un stream cu lista de alergii ale user-ului
  Stream<List<Allergy>> call(String uid) {
    return _repo.watchAllergies(uid);
  }
}
