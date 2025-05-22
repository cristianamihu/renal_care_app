import 'package:renal_care_app/features/chat/domain/entities/patient_info.dart';
import 'package:renal_care_app/features/chat/domain/repositories/chat_repository.dart';

class SearchPatients {
  final ChatRepository _repo;
  SearchPatients(this._repo);

  Future<List<PatientInfo>> call(String query) => _repo.searchPatients(query);
}
