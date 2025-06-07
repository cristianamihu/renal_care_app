import 'package:renal_care_app/features/medications/domain/entities/medication.dart';

abstract class MedicationRepository {
  Future<List<Medication>> getAllMedications(String uid);
  Future<void> addMedication(String uid, Medication medication);
  Future<void> updateMedication(String uid, Medication medication);
  Future<void> deleteMedication(String uid, String medicationId);
}
