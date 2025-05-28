import 'package:renal_care_app/features/journal/domain/entities/journal_entry.dart';
import 'package:renal_care_app/features/journal/domain/repositories/journal_repository.dart';

class ListJournalEntries {
  final JournalRepository _repo;
  ListJournalEntries(this._repo);

  Stream<List<JournalEntry>> call(String userId) => _repo.watchEntries(userId);
}
