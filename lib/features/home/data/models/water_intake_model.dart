import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:renal_care_app/features/home/domain/entities/water_intake.dart';

class WaterIntakeModel {
  final Timestamp date;
  final int glasses;

  WaterIntakeModel({required this.date, required this.glasses});

  factory WaterIntakeModel.fromJson(Map<String, dynamic> json) {
    final dateField = json['date'];
    return WaterIntakeModel(
      date: dateField is Timestamp ? dateField : Timestamp.now(),
      glasses: (json['glasses'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'date': date, 'glasses': glasses};

  WaterIntake toEntity() => WaterIntake(date: date.toDate(), glasses: glasses);
}
