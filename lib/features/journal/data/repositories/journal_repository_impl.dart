import 'package:renal_care_app/features/journal/domain/entities/journal_entry.dart';
import 'package:renal_care_app/features/journal/domain/repositories/journal_repository.dart';
import 'package:renal_care_app/features/journal/data/services/journal_remote_service.dart';

class JournalRepositoryImpl implements JournalRepository {
  final JournalRemoteService _remote;
  JournalRepositoryImpl(this._remote);

  @override
  Stream<List<JournalEntry>> watchEntries(String userId) {
    return _remote
        .watchEntries(userId)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<void> addEntry({
    required String userId,
    required String text,
    required String label,
  }) {
    return _remote.addEntry(userId: userId, text: text, label: label);
  }

  @override
  Future<void> updateEntry({
    required String userId,
    required String entryId,
    required String text,
    required String label,
  }) => _remote.updateEntry(
    userId: userId,
    entryId: entryId,
    text: text,
    label: label,
  );

  @override
  Future<void> deleteEntry({required String userId, required String entryId}) =>
      _remote.deleteEntry(userId: userId, entryId: entryId);
}
