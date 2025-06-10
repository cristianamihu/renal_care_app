import 'package:renal_care_app/features/appointments/domain/entities/appointment.dart';
import 'package:renal_care_app/features/appointments/domain/repositories/appointment_repository.dart';

class UpdateAppointment {
  final AppointmentRepository _repo;
  UpdateAppointment(this._repo);
  Future<void> call(Appointment appt) => _repo.update(appt);
}
