import 'package:renal_care_app/features/appointments/domain/entities/appointment.dart';
import 'package:renal_care_app/features/appointments/domain/repositories/appointment_repository.dart';

class GetDoctorAppointments {
  final AppointmentRepository _repo;
  GetDoctorAppointments(this._repo);

  Future<List<Appointment>> call(String doctorId, String dayKey) =>
      _repo.fetchByDoctor(doctorId, dayKey);
}
