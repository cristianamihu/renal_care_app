import 'package:renal_care_app/features/medications/domain/entities/medication.dart';
import 'package:renal_care_app/features/medications/domain/repositories/medication_repository.dart';

class UpdateMedication {
  final MedicationRepository _repo;

  UpdateMedication(this._repo);

  Future<void> call(String uid, Medication medication) {
    return _repo.updateMedication(uid, medication);
  }
}
