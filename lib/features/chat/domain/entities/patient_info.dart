// folosit la căutare pacienți
class PatientInfo {
  final String uid;
  final String email;
  final String? name; // opțional

  PatientInfo({required this.uid, required this.email, this.name});
}
