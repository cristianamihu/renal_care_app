import 'package:renal_care_app/features/chat/domain/entities/chat_room.dart';
import 'package:renal_care_app/features/chat/domain/entities/message.dart';
import 'package:renal_care_app/features/chat/domain/entities/patient_info.dart';

abstract class ChatRepository {
  /// Search pacient după email prefix
  Future<List<PatientInfo>> searchPatients(String query);

  /// Listare snapshot (o singură dată) chatRooms pentru un uid
  Future<List<ChatRoom>> listChatRooms(String uid);

  /// Stream real-time chatRooms (foloseşte când vrei stream UI)
  Stream<List<ChatRoom>> watchChatRooms(String uid);

  /// Creează o cameră nouă
  Future<ChatRoom> createChatRoom({
    required String doctorUid,
    required String patientUid,
  });

  /// Trimite un mesaj și returnează entitatea înapoi
  Future<Message> sendMessage({
    required String roomId,
    required String senderId,
    required String text,
    String? attachmentPath,
    String? attachmentName,
    String? attachmentType,
  });

  /// Stream real-time de mesaje
  Stream<List<Message>> watchMessages(String roomId);

  /// Returnează ultimul mesaj dintr-o cameră sau null dacă nu există niciun mesaj.
  Future<Message?> getLastMessage(String roomId);

  Future<void> deleteMessage({
    required String roomId,
    required String messageId,
  });

  Future<void> markRoomRead({required String roomId, required String userId});
}
