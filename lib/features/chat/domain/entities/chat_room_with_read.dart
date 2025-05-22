import 'package:renal_care_app/features/chat/domain/entities/chat_room.dart';

class ChatRoomWithRead {
  final ChatRoom room;

  /// pentru fiecare userId, data ultimei citiri
  final Map<String, DateTime> lastRead;

  ChatRoomWithRead({required this.room, required this.lastRead});
}
