import 'package:renal_care_app/features/chat/data/services/chat_remote_service.dart';
import 'package:renal_care_app/features/chat/domain/entities/chat_room.dart';
import 'package:renal_care_app/features/chat/domain/entities/message.dart';
import 'package:renal_care_app/features/chat/domain/entities/patient_info.dart';
import 'package:renal_care_app/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteService _remote;
  ChatRepositoryImpl(this._remote);

  @override
  Future<List<PatientInfo>> searchPatients(String query) =>
      _remote.searchPatients(query);

  @override
  Future<List<ChatRoom>> listChatRooms(String uid) => _remote
      .listChatRooms(uid)
      .then((ms) => ms.map((m) => m.toEntity()).toList());

  @override
  Stream<List<ChatRoom>> watchChatRooms(String uid) => _remote
      .watchChatRooms(uid)
      .map((ms) => ms.map((m) => m.toEntity()).toList());

  @override
  Future<ChatRoom> createChatRoom({
    required String doctorUid,
    required String patientUid,
  }) => _remote
      .createChatRoom(doctorUid: doctorUid, patientUid: patientUid)
      .then((m) => m.toEntity());

  @override
  Future<Message> sendMessage({
    required String roomId,
    required String senderId,
    required String text,
    String? attachmentPath,
    String? attachmentName,
    String? attachmentType,
  }) => _remote
      .sendMessage(
        roomId: roomId,
        senderId: senderId,
        text: text,
        attachmentPath: attachmentPath,
        attachmentName: attachmentName,
        attachmentType: attachmentType,
      )
      .then((m) => m.toEntity());

  @override
  Stream<List<Message>> watchMessages(String roomId) => _remote
      .watchMessages(roomId)
      .map((ms) => ms.map((m) => m.toEntity()).toList());

  @override
  Future<Message?> getLastMessage(String roomId) {
    return _remote.getLastMessage(roomId).then((model) => model?.toEntity());
  }

  @override
  Future<void> deleteMessage({
    required String roomId,
    required String messageId,
  }) {
    return _remote.deleteMessage(roomId: roomId, messageId: messageId);
  }

  @override
  Future<void> markRoomRead({required String roomId, required String userId}) {
    return _remote.markRoomRead(roomId: roomId, userId: userId);
  }
}
