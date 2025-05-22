import 'package:renal_care_app/features/chat/domain/entities/message.dart';
import 'package:renal_care_app/features/chat/domain/repositories/chat_repository.dart';

class SendMessage {
  final ChatRepository _repo;
  SendMessage(this._repo);

  Future<Message> call({
    required String roomId,
    required String senderId,
    required String text,
    String? attachmentPath,
    String? attachmentName,
    String? attachmentType,
  }) => _repo.sendMessage(
    roomId: roomId,
    senderId: senderId,
    text: text,
    attachmentPath: attachmentPath,
    attachmentName: attachmentName,
    attachmentType: attachmentType,
  );
}
