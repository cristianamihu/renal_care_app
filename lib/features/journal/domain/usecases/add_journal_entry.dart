import 'package:renal_care_app/features/journal/domain/repositories/journal_repository.dart';

class AddJournalEntry {
  final JournalRepository _repo;
  AddJournalEntry(this._repo);

  Future<void> call({
    required String userId,
    required String text,
    required String label,
  }) => _repo.addEntry(userId: userId, text: text, label: label);
}
