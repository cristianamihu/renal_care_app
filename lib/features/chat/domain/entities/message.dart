class Message {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final String? attachmentUrl;
  final String? attachmentName;
  final String? attachmentType;

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.attachmentUrl,
    this.attachmentName,
    this.attachmentType,
  });
}
