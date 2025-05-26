import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntryModel {
  final String id;
  final String text;
  final DateTime timestamp;
  final String label;

  JournalEntryModel({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.label,
  });

  factory JournalEntryModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return JournalEntryModel(
      id: doc.id,
      text: data['text'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      label: data['label'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    'timestamp': Timestamp.fromDate(timestamp),
    'label': label,
  };
}
