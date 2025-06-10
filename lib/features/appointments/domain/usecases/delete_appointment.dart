import 'package:renal_care_app/features/appointments/domain/repositories/appointment_repository.dart';

class DeleteAppointment {
  final AppointmentRepository _repo;
  DeleteAppointment(this._repo);
  Future<void> call(String id) => _repo.delete(id);
}
