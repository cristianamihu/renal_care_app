import 'package:renal_care_app/features/chat/domain/entities/message.dart';
import 'package:renal_care_app/features/chat/domain/repositories/chat_repository.dart';

class WatchMessages {
  final ChatRepository _repo;
  WatchMessages(this._repo);

  Stream<List<Message>> call(String roomId) => _repo.watchMessages(roomId);
}
