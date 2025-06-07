import 'package:renal_care_app/features/medications/domain/entities/medication.dart';

class MedicationState {
  final List<Medication> medications;
  final bool loading;
  final String? error;

  MedicationState({
    required this.medications,
    this.loading = false,
    this.error,
  });

  MedicationState copyWith({
    List<Medication>? medications,
    bool? loading,
    String? error,
  }) {
    return MedicationState(
      medications: medications ?? this.medications,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}
