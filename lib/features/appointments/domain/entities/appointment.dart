class Appointment {
  final String id;
  final String patientId;
  final DateTime dateTime;
  final String doctorId;
  final String description;
  final String doctorAddress;

  Appointment({
    required this.id,
    required this.patientId,
    required this.dateTime,
    required this.doctorId,
    required this.description,
    required this.doctorAddress,
  });
}
