import 'package:renal_care_app/features/appointments/domain/entities/appointment.dart';
import 'package:renal_care_app/features/appointments/domain/repositories/appointment_repository.dart';

class CreateAppointment {
  final AppointmentRepository _repo;
  CreateAppointment(this._repo);
  Future<void> call(Appointment appt) => _repo.create(appt);
}
