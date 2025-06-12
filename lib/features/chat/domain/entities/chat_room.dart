class ChatRoom {
  final String id;
  final List<String> participants;
  final DateTime createdAt;
  final String createdBy;
  final DateTime lastMessageAt;

  ChatRoom({
    required this.id,
    required this.participants,
    required this.createdAt,
    required this.createdBy,
    required this.lastMessageAt,
  });
}
