import 'package:renal_care_app/features/chat/domain/entities/chat_room.dart';
import 'package:renal_care_app/features/chat/domain/repositories/chat_repository.dart';

class CreateChatRoom {
  final ChatRepository _repo;
  CreateChatRoom(this._repo);

  Future<ChatRoom> call({
    required String doctorUid,
    required String patientUid,
  }) => _repo.createChatRoom(doctorUid: doctorUid, patientUid: patientUid);
}
