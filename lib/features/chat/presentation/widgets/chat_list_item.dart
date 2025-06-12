import 'package:renal_care_app/features/chat/domain/entities/message.dart';

/// Reprezintă fie un separator de dată, fie un mesaj
abstract class ChatListItem {}

/// Separator care marchează începutul unui nou interval de zi
class DateSeparator implements ChatListItem {
  final DateTime when;
  DateSeparator(this.when);
}

/// Împachetează un mesaj ca element de listă
class MessageItem implements ChatListItem {
  final Message message;
  MessageItem(this.message);
}
