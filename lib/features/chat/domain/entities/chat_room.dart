class ChatRoom {
  final String id;
  final List<String> participants;
  final DateTime createdAt;
  final String createdBy;

  ChatRoom({
    required this.id,
    required this.participants,
    required this.createdAt,
    required this.createdBy,
  });
}
