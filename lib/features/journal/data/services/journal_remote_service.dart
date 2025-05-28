import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:renal_care_app/features/journal/data/models/journal_entry_model.dart';

class JournalRemoteService {
  final FirebaseFirestore _firestore;

  JournalRemoteService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<JournalEntryModel>> watchEntries(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('journal')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(JournalEntryModel.fromDocument).toList());
  }

  Future<void> addEntry({
    required String userId,
    required String text,
    required String label,
  }) {
    final col = _firestore
        .collection('users')
        .doc(userId)
        .collection('journal');
    final entry = JournalEntryModel(
      id: col.doc().id,
      text: text,
      timestamp: DateTime.now(),
      label: label,
    );
    return col.doc(entry.id).set(entry.toJson());
  }

  Future<void> updateEntry({
    required String userId,
    required String entryId,
    required String text,
    required String label,
  }) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('journal')
        .doc(entryId)
        .update({
          'text': text,
          'label': label,
          'timestamp': Timestamp.fromDate(DateTime.now()),
        });
  }

  Future<void> deleteEntry({required String userId, required String entryId}) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('journal')
        .doc(entryId)
        .delete();
  }
}
