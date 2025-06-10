import 'package:renal_care_app/features/appointments/domain/entities/appointment.dart';
import 'package:renal_care_app/features/appointments/domain/repositories/appointment_repository.dart';

class GetUpcomingAppointments {
  final AppointmentRepository _repo;
  GetUpcomingAppointments(this._repo);
  Future<List<Appointment>> call(String userId) => _repo.fetchUpcoming(userId);
}
