import 'package:renal_care_app/features/chat/domain/repositories/chat_repository.dart';

class DeleteMessage {
  final ChatRepository _repo;
  DeleteMessage(this._repo);

  Future<void> call({required String roomId, required String messageId}) =>
      _repo.deleteMessage(roomId: roomId, messageId: messageId);
}
