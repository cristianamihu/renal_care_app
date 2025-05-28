import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:renal_care_app/features/journal/domain/entities/journal_entry.dart';

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

  /// Convertim modelul la entitatea de domain
  JournalEntry toEntity() {
    return JournalEntry(id: id, text: text, timestamp: timestamp, label: label);
  }
}
