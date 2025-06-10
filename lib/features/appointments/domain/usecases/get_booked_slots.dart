import 'package:renal_care_app/features/appointments/domain/repositories/appointment_repository.dart';

class GetBookedSlots {
  final AppointmentRepository _repo;
  GetBookedSlots(this._repo);

  Future<List<String>> call(String doctorId, String dayKey) =>
      _repo.getBookedSlots(doctorId, dayKey);
}
