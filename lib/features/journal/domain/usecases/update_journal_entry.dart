import 'package:renal_care_app/features/journal/domain/repositories/journal_repository.dart';

class UpdateJournalEntry {
  final JournalRepository _repo;
  UpdateJournalEntry(this._repo);
  Future<void> call({
    required String userId,
    required String entryId,
    required String text,
    required String label,
  }) => _repo.updateEntry(
    userId: userId,
    entryId: entryId,
    text: text,
    label: label,
  );
}
