import 'package:renal_care_app/features/chat/domain/entities/chat_room.dart';
import 'package:renal_care_app/features/chat/domain/repositories/chat_repository.dart';

class WatchChatRooms {
  final ChatRepository _repo;
  WatchChatRooms(this._repo);

  Stream<List<ChatRoom>> call(String uid) => _repo.watchChatRooms(uid);
}
