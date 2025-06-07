import 'package:renal_care_app/features/medications/domain/repositories/medication_repository.dart';

class DeleteMedication {
  final MedicationRepository _repo;

  DeleteMedication(this._repo);

  Future<void> call(String uid, String medicationId) {
    return _repo.deleteMedication(uid, medicationId);
  }
}
