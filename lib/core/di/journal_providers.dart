import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:renal_care_app/features/journal/domain/usecases/delete_journal_entry.dart';
import 'package:renal_care_app/features/journal/domain/usecases/update_journal_entry.dart';
import 'package:renal_care_app/features/journal/presentation/viewmodels/journal_viewmodel.dart';

final deleteJournalEntryUseCaseProvider = Provider<DeleteJournalEntry>((ref) {
  return DeleteJournalEntry(ref.watch(journalRepositoryProvider));
});

final updateJournalEntryUseCaseProvider = Provider<UpdateJournalEntry>((ref) {
  return UpdateJournalEntry(ref.watch(journalRepositoryProvider));
});
