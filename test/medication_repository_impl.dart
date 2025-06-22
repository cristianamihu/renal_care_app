import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:renal_care_app/features/medications/data/models/medication_model.dart';
import 'package:renal_care_app/features/medications/data/services/medication_remote_service.dart';
import 'package:renal_care_app/features/medications/data/repositories/medication_repository_impl.dart';
import 'package:renal_care_app/features/medications/domain/entities/medication.dart';

// stub pentru remote service
class MockRemote extends Mock implements MedicationRemoteService {}

void main() {
  late MockRemote remote;
  late MedicationRepositoryImpl repo;
  final now = DateTime(2023, 01, 01, 12, 00);

  setUp(() {
    remote = MockRemote();
    repo = MedicationRepositoryImpl(remote);
  });

  test('getAllMedications() transformă corect modelele în entități', () async {
    final now = DateTime.now();
    final ts = Timestamp.fromDate(now);
    final model = MedicationModel(
      id: 'm1',
      name: 'X',
      dose: 10,
      unit: 'mg',
      startDate: ts,
      endDate: null,
      frequency: 1,
      times: [ts],
      notificationsEnabled: true,
      createdAt: ts,
      updatedAt: ts,
      specificWeekdays: [],
    );
    when(() => remote.fetchAll('u1')).thenAnswer((_) async => [model]);

    final meds = await repo.getAllMedications('u1');
    expect(meds, isA<List<Medication>>());
    expect(meds.first.id, 'm1');
    expect(meds.first.startDate, now);
  });

  test('addMedication() apelează remote.add cu model din entitate', () async {
    when(() => remote.add(any(), any())).thenAnswer((_) async {});

    final ent = Medication(
      id: '',
      name: 'N',
      dose: 5,
      unit: 'ml',
      startDate: now,
      endDate: now,
      frequency: 1,
      times: [now],
      notificationsEnabled: true,
      createdAt: now,
      updatedAt: now,
      specificWeekdays: [],
    );
    await repo.addMedication('u2', ent);

    verify(() => remote.add('u2', any(that: isA<MedicationModel>()))).called(1);
  });

  test(
    'updateMedication() apelează remote.update cu model din entitate',
    () async {
      when(() => remote.update(any(), any())).thenAnswer((_) async {});

      final ent = Medication(
        id: 'mid',
        name: 'Y',
        dose: 2,
        unit: 'pill',
        startDate: now,
        endDate: now,
        frequency: 2,
        times: [now],
        notificationsEnabled: false,
        createdAt: now,
        updatedAt: now,
        specificWeekdays: [1, 2],
      );
      await repo.updateMedication('u3', ent);

      verify(
        () => remote.update(
          'u3',
          any(that: predicate<MedicationModel>((m) => m.id == 'mid')),
        ),
      ).called(1);
    },
  );

  test('deleteMedication() apelează remote.delete cu uid și id', () async {
    when(() => remote.delete(any(), any())).thenAnswer((_) async {});

    await repo.deleteMedication('u4', 'mid4');
    verify(() => remote.delete('u4', 'mid4')).called(1);
  });
}
