import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:renal_care_app/features/journal/domain/entities/journal_entry.dart';
import 'package:renal_care_app/features/journal/domain/repositories/journal_repository.dart';
import 'package:renal_care_app/features/journal/domain/usecases/add_journal_entry.dart';
import 'package:renal_care_app/features/journal/domain/usecases/delete_journal_entry.dart';
import 'package:renal_care_app/features/journal/domain/usecases/update_journal_entry.dart';
import 'package:renal_care_app/features/journal/domain/usecases/list_journal_entries.dart';

// Mock pentru JournalRepository
class MockJournalRepository extends Mock implements JournalRepository {}

void main() {
  late MockJournalRepository repo;

  setUp(() {
    repo = MockJournalRepository();
  });

  test(
    'AddJournalEntry apelează repo.addEntry() cu parametri corecți',
    () async {
      when(
        () => repo.addEntry(
          userId: any(named: 'userId'),
          text: any(named: 'text'),
          label: any(named: 'label'),
        ),
      ).thenAnswer((_) async {});

      final uc = AddJournalEntry(repo);
      await uc.call(userId: 'u1', text: 'abc', label: 'Gen');

      verify(
        () => repo.addEntry(userId: 'u1', text: 'abc', label: 'Gen'),
      ).called(1);
    },
  );

  test(
    'DeleteJournalEntry apelează repo.deleteEntry() cu parametri corecți',
    () async {
      when(
        () => repo.deleteEntry(
          userId: any(named: 'userId'),
          entryId: any(named: 'entryId'),
        ),
      ).thenAnswer((_) async {});

      final uc = DeleteJournalEntry(repo);
      await uc.call(userId: 'u1', entryId: 'e1');

      verify(() => repo.deleteEntry(userId: 'u1', entryId: 'e1')).called(1);
    },
  );

  test(
    'UpdateJournalEntry apelează repo.updateEntry() cu parametri corecți',
    () async {
      when(
        () => repo.updateEntry(
          userId: any(named: 'userId'),
          entryId: any(named: 'entryId'),
          text: any(named: 'text'),
          label: any(named: 'label'),
        ),
      ).thenAnswer((_) async {});

      final uc = UpdateJournalEntry(repo);
      await uc.call(userId: 'u1', entryId: 'e1', text: 'xyz', label: 'Emg');

      verify(
        () => repo.updateEntry(
          userId: 'u1',
          entryId: 'e1',
          text: 'xyz',
          label: 'Emg',
        ),
      ).called(1);
    },
  );

  test('ListJournalEntries emite exact ce repo.watchEntries() emite', () {
    final now = DateTime.now();
    final sample = [
      JournalEntry(id: 'i1', text: 't1', timestamp: now, label: 'L1'),
    ];
    when(() => repo.watchEntries('u1')).thenAnswer((_) => Stream.value(sample));

    final uc = ListJournalEntries(repo);
    expectLater(uc.call('u1'), emits(sample));
  });
}
