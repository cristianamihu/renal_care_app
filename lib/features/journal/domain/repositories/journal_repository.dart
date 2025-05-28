import 'package:renal_care_app/features/journal/domain/entities/journal_entry.dart';

abstract class JournalRepository {
  Stream<List<JournalEntry>> watchEntries(String userId);
  Future<void> addEntry({
    required String userId,
    required String text,
    required String label,
  });

  Future<void> updateEntry({
    required String userId,
    required String entryId,
    required String text,
    required String label,
  });

  Future<void> deleteEntry({required String userId, required String entryId});
}
