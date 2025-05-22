import 'package:renal_care_app/features/chat/domain/entities/chat_room.dart';
import 'package:renal_care_app/features/chat/domain/repositories/chat_repository.dart';

class ListChatRooms {
  final ChatRepository _repo;
  ListChatRooms(this._repo);

  Future<List<ChatRoom>> call(String uid) => _repo.listChatRooms(uid);
}
