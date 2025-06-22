import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:renal_care_app/features/journal/data/models/journal_entry_model.dart';
import 'package:renal_care_app/features/journal/data/services/journal_remote_service.dart';
import 'package:renal_care_app/features/journal/data/repositories/journal_repository_impl.dart';
import 'package:renal_care_app/features/journal/domain/entities/journal_entry.dart';

// stub pentru remote service
class MockRemote extends Mock implements JournalRemoteService {}

void main() {
  final now = DateTime(2023, 1, 1, 12, 0);
  late MockRemote remote;
  late JournalRepositoryImpl repo;

  setUp(() {
    remote = MockRemote();
    repo = JournalRepositoryImpl(remote);
  });

  test(
    'watchEntries() transformă corect JournalEntryModel → JournalEntry',
    () async {
      // Construim modelul folosind DateTime pentru timestamp
      final model = JournalEntryModel(
        id: 'e1',
        text: 'nota',
        timestamp: now,
        label: 'General',
      );

      // stub-uim remote.watchEntries să emită acel model
      when(
        () => remote.watchEntries('u1'),
      ).thenAnswer((_) => Stream.value([model]));

      // obținem stream-ul de entități
      final stream = repo.watchEntries('u1');

      // verificăm că primim exact acel JournalEntry
      await expectLater(
        stream,
        emits([
          isA<JournalEntry>()
              .having((e) => e.id, 'id', 'e1')
              .having((e) => e.text, 'text', 'nota')
              .having((e) => e.timestamp, 'timestamp', now)
              .having((e) => e.label, 'label', 'General'),
        ]),
      );
    },
  );
}
