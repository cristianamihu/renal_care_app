import 'package:renal_care_app/features/journal/domain/repositories/journal_repository.dart';

class DeleteJournalEntry {
  final JournalRepository _repo;
  DeleteJournalEntry(this._repo);
  Future<void> call({required String userId, required String entryId}) =>
      _repo.deleteEntry(userId: userId, entryId: entryId);
}
