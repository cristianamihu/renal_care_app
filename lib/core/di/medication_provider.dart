import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:renal_care_app/features/medications/data/repositories/medication_repository_impl.dart';
import 'package:renal_care_app/features/medications/data/services/medication_remote_service.dart';
import 'package:renal_care_app/features/medications/domain/entities/medication.dart';
import 'package:renal_care_app/features/medications/domain/repositories/medication_repository.dart';
import 'package:renal_care_app/features/medications/domain/usecases/add_medication.dart';
import 'package:renal_care_app/features/medications/domain/usecases/delete_medication.dart';
import 'package:renal_care_app/features/medications/domain/usecases/get_all_medications.dart';
import 'package:renal_care_app/features/medications/domain/usecases/update_medication.dart';
import 'package:renal_care_app/features/medications/presentation/viewmodels/medication_state.dart';
import 'package:renal_care_app/features/medications/presentation/viewmodels/medication_viewmodel.dart';

/// Provider pentru serviciul remote (acces Firestore sau alt API)
final medicationRemoteServiceProvider = Provider<MedicationRemoteService>((
  ref,
) {
  return MedicationRemoteService();
});

/// Provider pentru repository (implentarea concretă a MedicationRepository)
final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  final remote = ref.read(medicationRemoteServiceProvider);
  return MedicationRepositoryImpl(remote);
});

/// Obține lista de medicamente
final getMedicationsUseCaseProvider = Provider<GetAllMedications>((ref) {
  final repo = ref.read(medicationRepositoryProvider);
  return GetAllMedications(repo);
});

/// FutureProvider care găsește un singur Medication după ID
final singleMedicationProvider = FutureProvider.autoDispose.family<
  Medication?,
  String
>((ref, medId) async {
  // Luăm lista completă
  final uid = ref.read(authViewModelProvider).user!.uid;
  final allMeds = await ref.read(getMedicationsUseCaseProvider).call(uid);

  // Încercăm să găsim medicamentul cu acest ID; dacă nu există, întoarcem null
  try {
    return allMeds.firstWhere((m) => m.id == medId);
  } catch (e) {
    // Dacă firstWhere aruncă StateError („No element”), întoarcem null
    return null;
  }
});

/// Adaugă un medicament nou
final addMedicationUseCaseProvider = Provider<AddMedication>((ref) {
  final repo = ref.read(medicationRepositoryProvider);
  return AddMedication(repo);
});

/// Actualizează un medicament existent
final updateMedicationUseCaseProvider = Provider<UpdateMedication>((ref) {
  final repo = ref.read(medicationRepositoryProvider);
  return UpdateMedication(repo);
});

/// Șterge un medicament după ID
final deleteMedicationUseCaseProvider = Provider<DeleteMedication>((ref) {
  final repo = ref.read(medicationRepositoryProvider);
  return DeleteMedication(repo);
});

/// Provider pentru ViewModel-ul de medicamente (stare + logică)
final medicationViewModelProvider =
    StateNotifierProvider<MedicationViewModel, MedicationState>((ref) {
      final getUseCase = ref.read(getMedicationsUseCaseProvider);
      final addUseCase = ref.read(addMedicationUseCaseProvider);
      final updateUseCase = ref.read(updateMedicationUseCaseProvider);
      final deleteUseCase = ref.read(deleteMedicationUseCaseProvider);
      return MedicationViewModel(
        ref,
        getUseCase,
        addUseCase,
        updateUseCase,
        deleteUseCase,
      );
    });
