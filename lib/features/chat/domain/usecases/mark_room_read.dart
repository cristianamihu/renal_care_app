import 'package:renal_care_app/features/chat/domain/repositories/chat_repository.dart';

class MarkRoomRead {
  final ChatRepository _repo;
  MarkRoomRead(this._repo);

  Future<void> call({required String roomId, required String userId}) {
    return _repo.markRoomRead(roomId: roomId, userId: userId);
  }
}
