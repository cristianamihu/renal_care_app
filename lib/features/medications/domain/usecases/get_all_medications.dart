import 'package:renal_care_app/features/medications/domain/entities/medication.dart';
import 'package:renal_care_app/features/medications/domain/repositories/medication_repository.dart';

class GetAllMedications {
  final MedicationRepository _repo;

  GetAllMedications(this._repo);

  Future<List<Medication>> call(String uid) {
    return _repo.getAllMedications(uid);
  }
}
