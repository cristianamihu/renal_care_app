import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:renal_care_app/features/home/domain/entities/sleep_record.dart';

class SleepRecordModel {
  final Timestamp date;
  final double hours;
  final Timestamp start;
  final Timestamp end;

  SleepRecordModel({
    required this.date,
    required this.hours,
    required this.start,
    required this.end,
  });

  factory SleepRecordModel.fromJson(Map<String, dynamic> json) {
    // grab fields out, but only cast when actually a Timestamp
    final dateField = json['date'];
    final startField = json['start'];
    final endField = json['end'];

    return SleepRecordModel(
      date: dateField is Timestamp ? dateField : Timestamp.now(),
      hours: (json['hours'] as num?)?.toDouble() ?? 0.0,
      start: startField is Timestamp ? startField : Timestamp.now(),
      end: endField is Timestamp ? endField : Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'hours': hours,
    'start': start,
    'end': end,
  };

  SleepRecord toEntity() => SleepRecord(
    date: date.toDate(),
    hours: hours,
    start: start.toDate(),
    end: end.toDate(),
  );
}
