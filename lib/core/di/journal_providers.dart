import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:renal_care_app/features/auth/data/models/journal_document_model.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:renal_care_app/features/journal/data/repositories/journal_repository_impl.dart';
import 'package:renal_care_app/features/journal/data/services/journal_remote_service.dart';
import 'package:renal_care_app/features/journal/domain/entities/journal_entry.dart';
import 'package:renal_care_app/features/journal/domain/usecases/add_journal_entry.dart';
import 'package:renal_care_app/features/journal/domain/usecases/delete_journal_entry.dart';
import 'package:renal_care_app/features/journal/domain/usecases/list_journal_entries.dart';
import 'package:renal_care_app/features/journal/domain/usecases/update_journal_entry.dart';
import 'package:renal_care_app/features/journal/presentation/viewmodels/journal_viewmodel.dart';

// pentru documentele de jurnal ale oricărui userId
final journalDocsForUserProvider = StreamProvider.autoDispose
    .family<List<JournalDocument>, String>((ref, userId) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('journal_documents')
          .orderBy('addedAt', descending: true)
          .snapshots()
          .map(
            (snap) =>
                snap.docs.map((doc) {
                  final data = doc.data();
                  return JournalDocument(
                    id: doc.id,
                    name: data['name'] as String,
                    url: data['url'] as String,
                    type: data['type'] as String,
                    addedAt: (data['addedAt'] as Timestamp).toDate(),
                  );
                }).toList(),
          );
    });

/// Scurtătură pentru documentele jurnal ale user-ului curent
final journalDocsProvider = Provider.autoDispose<
  AsyncValue<List<JournalDocument>>
>((ref) {
  final authState = ref.watch(authViewModelProvider);
  final uid = authState.user?.uid;
  if (uid == null) {
    // Dacă nu e utilizator logat, returnăm o AsyncValue.data goală
    return const AsyncValue.data(<JournalDocument>[]);
  }
  // WATCH direct pe journalDocsForUserProvider, care deja e un StreamProvider
  return ref.watch(journalDocsForUserProvider(uid));
});

final journalViewModelProvider =
    StateNotifierProvider<JournalViewModel, AsyncValue<List<JournalEntry>>>((
      ref,
    ) {
      //final userId = ref.watch(authViewModelProvider).user!.uid;
      final listUC = ref.watch(listJournalEntriesUseCaseProvider);
      return JournalViewModel(ref, listUC);
    });

final listJournalEntriesUseCaseProvider = Provider<ListJournalEntries>((ref) {
  return ListJournalEntries(ref.watch(journalRepositoryProvider));
});

final addJournalEntryUseCaseProvider = Provider<AddJournalEntry>((ref) {
  return AddJournalEntry(ref.watch(journalRepositoryProvider));
});

final journalRepositoryProvider = Provider((ref) {
  return JournalRepositoryImpl(JournalRemoteService());
});

final deleteJournalEntryUseCaseProvider = Provider<DeleteJournalEntry>((ref) {
  return DeleteJournalEntry(ref.watch(journalRepositoryProvider));
});

final updateJournalEntryUseCaseProvider = Provider<UpdateJournalEntry>((ref) {
  return UpdateJournalEntry(ref.watch(journalRepositoryProvider));
});
