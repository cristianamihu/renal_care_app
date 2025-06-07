import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:renal_care_app/features/medications/domain/entities/medication.dart';

class MedicationModel {
  final String id;
  final String name;
  final double dose;
  final String unit;
  final Timestamp startDate;
  final Timestamp? endDate;
  final int frequency;
  final List<Timestamp> times;
  final bool notificationsEnabled;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final List<int> specificWeekdays;

  MedicationModel({
    required this.id,
    required this.name,
    required this.dose,
    required this.unit,
    required this.startDate,
    this.endDate,
    required this.frequency,
    required this.times,
    required this.notificationsEnabled,
    required this.createdAt,
    required this.updatedAt,
    this.specificWeekdays = const [],
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json, String docId) {
    final rawTimes = json['times'] as List<dynamic>? ?? <dynamic>[];
    final rawWeekdays =
        json['specificWeekdays'] as List<dynamic>? ?? <dynamic>[];
    return MedicationModel(
      id: docId,
      name: json['name'] as String,
      dose: (json['dose'] as num).toDouble(),
      unit: json['unit'] as String,
      startDate: json['startDate'] as Timestamp,
      endDate: json['endDate'] as Timestamp?,
      frequency: json['frequency'] as int,
      times: rawTimes.map((t) => t as Timestamp).toList(),
      notificationsEnabled: json['notificationsEnabled'] as bool,
      createdAt: json['createdAt'] as Timestamp,
      updatedAt: json['updatedAt'] as Timestamp,
      specificWeekdays: rawWeekdays.map((e) => (e as num).toInt()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dose': dose,
      'unit': unit,
      'startDate': startDate,
      'endDate': endDate,
      'frequency': frequency,
      'times': times,
      'notificationsEnabled': notificationsEnabled,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'specificWeekdays': specificWeekdays,
    };
  }

  // Conversia în Entitate de Domeniu
  Medication toEntity() {
    return Medication(
      id: id,
      name: name,
      dose: dose,
      unit: unit,
      startDate: startDate.toDate(),
      endDate: endDate?.toDate(),
      frequency: frequency,
      times: times.map((t) => t.toDate()).toList(),
      notificationsEnabled: notificationsEnabled,
      createdAt: createdAt.toDate(),
      updatedAt: updatedAt.toDate(),
      specificWeekdays: specificWeekdays,
    );
  }

  // Factory pentru a crea un model nou înainte de scrierea în Firestore
  static MedicationModel fromEntity(Medication m) {
    return MedicationModel(
      id: m.id,
      name: m.name,
      dose: m.dose,
      unit: m.unit,
      startDate: Timestamp.fromDate(m.startDate),
      endDate: m.endDate != null ? Timestamp.fromDate(m.endDate!) : null,
      frequency: m.frequency,
      times: m.times.map((d) => Timestamp.fromDate(d)).toList(),
      notificationsEnabled: m.notificationsEnabled,
      createdAt: Timestamp.fromDate(m.createdAt),
      updatedAt: Timestamp.fromDate(m.updatedAt),
      specificWeekdays: m.specificWeekdays,
    );
  }
}
