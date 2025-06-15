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

  // creează jurnal + creează duplicatul în journal_documents
  Future<void> addEntry({
    required String userId,
    required String text,
    required String label,
  }) async {
    final col = _firestore
        .collection('users')
        .doc(userId)
        .collection('journal');
    // generează un id nou pentru jurnal
    final newDocRef = col.doc();
    final entryId = newDocRef.id;

    final now = DateTime.now();
    final entry = JournalEntryModel(
      id: entryId,
      text: text,
      timestamp: now,
      label: label,
    );
    // Scrie în /users/{uid}/journal/{entryId}
    await newDocRef.set(entry.toJson());
    // Scrie simultan în /users/{uid}/journal_documents/{entryId}
    final docCopy = {
      'name': 'Note: $label',
      'url': text, // stocare tocmai textul notei
      'type': 'text/plain',
      'addedAt': Timestamp.fromDate(now),
    };
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('journal_documents')
        .doc(entryId)
        .set(docCopy);
  }

  // actualizează atât în journal, cât și în journal_documents
  Future<void> updateEntry({
    required String userId,
    required String entryId,
    required String text,
    required String label,
  }) async {
    final journalRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('journal')
        .doc(entryId);
    final now = DateTime.now();

    // Actualizează în /users/{uid}/journal/{entryId}
    await journalRef.update({
      'text': text,
      'label': label,
      'timestamp': Timestamp.fromDate(now),
    });

    // Actualizează și în /users/{uid}/journal_documents/{entryId}
    final docRefCopy = _firestore
        .collection('users')
        .doc(userId)
        .collection('journal_documents')
        .doc(entryId);

    await docRefCopy.update({
      'name': 'Note: $label',
      'url': text,
      'addedAt': Timestamp.fromDate(now),
      // Păstrăm type = 'text/plain'
    });
  }

  // șterge atât din journal, cât și din journal_documents
  Future<void> deleteEntry({
    required String userId,
    required String entryId,
  }) async {
    final journalRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('journal')
        .doc(entryId);
    final docRefCopy = _firestore
        .collection('users')
        .doc(userId)
        .collection('journal_documents')
        .doc(entryId);

    // Șterge din jurnal
    await journalRef.delete();
    // Șterge și din journal_documents
    await docRefCopy.delete();
  }
}
