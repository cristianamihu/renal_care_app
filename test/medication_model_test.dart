import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:renal_care_app/features/medications/data/models/medication_model.dart';
import 'package:renal_care_app/features/medications/domain/entities/medication.dart';

void main() {
  group('MedicationModel ↔ Medication entity', () {
    final now = DateTime(2023, 1, 1, 12, 30);
    final ts = Timestamp.fromDate(now);

    final json = {
      'name': 'MedA',
      'dose': 2.5,
      'unit': 'mg',
      'startDate': ts,
      'endDate': null,
      'frequency': 1,
      'times': [ts],
      'notificationsEnabled': true,
      'createdAt': ts,
      'updatedAt': ts,
      'specificWeekdays': [1, 3, 5],
    };

    test('fromJson construieşte corect modelul', () {
      final model = MedicationModel.fromJson(json, 'doc123');
      expect(model.id, 'doc123');
      expect(model.name, 'MedA');
      expect(model.dose, 2.5);
      expect(model.unit, 'mg');
      expect(model.startDate, ts);
      expect(model.endDate, isNull);
      expect(model.frequency, 1);
      expect(model.times, [ts]);
      expect(model.notificationsEnabled, isTrue);
      expect(model.createdAt, ts);
      expect(model.updatedAt, ts);
      expect(model.specificWeekdays, [1, 3, 5]);
    });

    test('toEntity converteşte în Medication cu câmpuri DateTime', () {
      final model = MedicationModel.fromJson(json, 'idX');
      final ent = model.toEntity();

      expect(ent.id, 'idX');
      expect(ent.name, 'MedA');
      expect(ent.dose, 2.5);
      expect(ent.unit, 'mg');
      expect(ent.startDate, now);
      expect(ent.endDate, isNull);
      expect(ent.frequency, 1);
      expect(ent.times, [now]);
      expect(ent.notificationsEnabled, isTrue);
      expect(ent.createdAt, now);
      expect(ent.updatedAt, now);
      expect(ent.specificWeekdays, [1, 3, 5]);
    });

    test('fromEntity + toJson este simetric', () {
      final original = Medication(
        id: 'Z',
        name: 'MedB',
        dose: 1.0,
        unit: 'ml',
        startDate: now,
        endDate: now,
        frequency: 2,
        times: [now],
        notificationsEnabled: false,
        createdAt: now,
        updatedAt: now,
        specificWeekdays: [2, 4],
      );
      final model = MedicationModel.fromEntity(original);
      final backJson = model.toJson();
      // backJson păstrează toate câmpurile (format Timestamp)
      expect(backJson['name'], original.name);
      expect((backJson['dose'] as num).toDouble(), original.dose);
      expect(backJson['unit'], original.unit);
      expect(backJson['startDate'], isA<Timestamp>());
      expect((backJson['times'] as List).length, 1);
      expect(backJson['notificationsEnabled'], original.notificationsEnabled);
      expect(
        (backJson['specificWeekdays'] as List).cast<int>(),
        original.specificWeekdays,
      );
    });
  });
}
