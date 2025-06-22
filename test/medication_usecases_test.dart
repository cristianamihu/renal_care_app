import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:renal_care_app/features/medications/domain/entities/medication.dart';
import 'package:renal_care_app/features/medications/domain/repositories/medication_repository.dart';
import 'package:renal_care_app/features/medications/domain/usecases/add_medication.dart';
import 'package:renal_care_app/features/medications/domain/usecases/delete_medication.dart';
import 'package:renal_care_app/features/medications/domain/usecases/get_all_medications.dart';
import 'package:renal_care_app/features/medications/domain/usecases/update_medication.dart';

// stub pentru repository
class MockMedRepo extends Mock implements MedicationRepository {}

void main() {
  late MockMedRepo repo;

  setUp(() {
    repo = MockMedRepo();
  });

  final sampleMed = Medication(
    id: 'x',
    name: 'A',
    dose: 1,
    unit: 'u',
    startDate: DateTime.now(),
    endDate: null,
    frequency: 1,
    times: [DateTime.now()],
    notificationsEnabled: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    specificWeekdays: [],
  );

  test('GetAllMedications returnează lista de la repo', () async {
    when(
      () => repo.getAllMedications('u1'),
    ).thenAnswer((_) async => [sampleMed]);

    final uc = GetAllMedications(repo);
    final result = await uc.call('u1');
    expect(result, [sampleMed]);
  });

  test('AddMedication apelează repo.addMedication()', () async {
    when(() => repo.addMedication('u2', sampleMed)).thenAnswer((_) async {});
    final uc = AddMedication(repo);
    await uc.call('u2', sampleMed);
    verify(() => repo.addMedication('u2', sampleMed)).called(1);
  });

  test('UpdateMedication apelează repo.updateMedication()', () async {
    when(() => repo.updateMedication('u3', sampleMed)).thenAnswer((_) async {});
    final uc = UpdateMedication(repo);
    await uc.call('u3', sampleMed);
    verify(() => repo.updateMedication('u3', sampleMed)).called(1);
  });

  test('DeleteMedication apelează repo.deleteMedication()', () async {
    when(() => repo.deleteMedication('u4', 'id4')).thenAnswer((_) async {});
    final uc = DeleteMedication(repo);
    await uc.call('u4', 'id4');
    verify(() => repo.deleteMedication('u4', 'id4')).called(1);
  });
}
