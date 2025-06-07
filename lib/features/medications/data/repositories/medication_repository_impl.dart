import 'package:renal_care_app/features/medications/data/models/medication_model.dart';
import 'package:renal_care_app/features/medications/data/services/medication_remote_service.dart';
import 'package:renal_care_app/features/medications/domain/entities/medication.dart';
import 'package:renal_care_app/features/medications/domain/repositories/medication_repository.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final MedicationRemoteService _remote;

  MedicationRepositoryImpl(this._remote);

  @override
  Future<List<Medication>> getAllMedications(String uid) async {
    final models = await _remote.fetchAll(uid);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addMedication(String uid, Medication medication) async {
    // Pregătim modelul din entitate
    final now = DateTime.now();
    final medWithTimestamps = Medication(
      id: '', // Firestore va genera
      name: medication.name,
      dose: medication.dose,
      unit: medication.unit,
      startDate: medication.startDate,
      endDate: medication.endDate,
      frequency: medication.frequency,
      times: medication.times,
      notificationsEnabled: medication.notificationsEnabled,
      createdAt: now,
      updatedAt: now,
      specificWeekdays: medication.specificWeekdays,
    );
    final model = MedicationModel.fromEntity(medWithTimestamps);
    await _remote.add(uid, model);
  }

  @override
  Future<void> updateMedication(String uid, Medication medication) async {
    final model = MedicationModel.fromEntity(medication);
    await _remote.update(uid, model);
  }

  @override
  Future<void> deleteMedication(String uid, String medicationId) async {
    await _remote.delete(uid, medicationId);
  }
}
