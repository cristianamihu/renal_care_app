class JournalDocument {
  final String id;
  final String name;
  final String url; // fie un link (PDF, imagine, etc.), fie textul notei
  final String type; // ex: 'application/pdf', 'image/png', sau 'text/plain'
  final DateTime addedAt;

  JournalDocument({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.addedAt,
  });
}
