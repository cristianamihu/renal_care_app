import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:renal_care_app/core/di/journal_providers.dart';

import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:renal_care_app/features/journal/domain/entities/journal_entry.dart';
import 'package:renal_care_app/features/journal/domain/usecases/list_journal_entries.dart';

class JournalViewModel extends StateNotifier<AsyncValue<List<JournalEntry>>> {
  final Ref _ref;
  final ListJournalEntries _listUC;
  JournalViewModel(this._ref, this._listUC)
    : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    final userId = _ref.read(authViewModelProvider).user!.uid;
    _listUC.call(userId).listen((entries) {
      state = AsyncValue.data(entries);
    });
  }

  Future<void> addEntry(String text, String label) async {
    final userId = _ref.read(authViewModelProvider).user!.uid;
    await _ref
        .read(addJournalEntryUseCaseProvider)
        .call(userId: userId, text: text, label: label);
  }

  Future<void> updateEntry(
    JournalEntry e,
    String newText,
    String newLabel,
  ) async {
    final userId = _ref.read(authViewModelProvider).user!.uid;
    await _ref
        .read(updateJournalEntryUseCaseProvider)
        .call(userId: userId, entryId: e.id, text: newText, label: newLabel);
  }

  Future<void> deleteEntry(String entryId) async {
    final userId = _ref.read(authViewModelProvider).user!.uid;
    await _ref
        .read(deleteJournalEntryUseCaseProvider)
        .call(userId: userId, entryId: entryId);
  }
}
