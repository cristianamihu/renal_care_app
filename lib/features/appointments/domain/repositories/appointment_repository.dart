import 'package:renal_care_app/features/appointments/domain/entities/appointment.dart';

abstract class AppointmentRepository {
  Future<List<Appointment>> fetchUpcoming(String userId); // pentru pacienți

  /// pentru doctor: adaugă ziua (yyyy-MM-dd) în care cauți programări
  Future<List<Appointment>> fetchByDoctor(String doctorId, String dayKey);

  Future<void> create(Appointment appt);
  Future<void> update(Appointment appt);
  Future<void> delete(String appointmentId);

  /// Returnează lista de slot-uri ocupate pentru doctorId în ziua dayKey
  Future<List<String>> getBookedSlots(String doctorId, String dayKey);
}
