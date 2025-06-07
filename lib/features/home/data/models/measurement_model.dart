import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:renal_care_app/features/home/domain/entities/measurement.dart';

class MeasurementModel {
  final double weight;
  final double height;
  final double bmi;
  final double glucose;
  final int systolic;
  final int diastolic;
  final double temperature;
  final Timestamp date;
  final String moment;

  MeasurementModel({
    required this.weight,
    required this.height,
    required this.bmi,
    required this.glucose,
    required this.systolic,
    required this.diastolic,
    required this.temperature,
    required this.date,
    required this.moment,
  });

  factory MeasurementModel.fromJson(Map<String, dynamic> json) {
    final dateField = json['date'];
    return MeasurementModel(
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      bmi: (json['bmi'] as num).toDouble(),
      glucose: (json['glucose'] as num).toDouble(),
      systolic: json['systolic'] as int,
      diastolic: json['diastolic'] as int,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      date: dateField is Timestamp ? dateField : Timestamp.now(),
      moment: (json['moment'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'weight': weight,
    'height': height,
    'bmi': bmi,
    'glucose': glucose,
    'systolic': systolic,
    'diastolic': diastolic,
    'temperature': temperature,
    'date': date,
    'moment': moment,
  };

  Measurement toEntity() => Measurement(
    weight: weight,
    height: height,
    bmi: bmi,
    glucose: glucose,
    systolic: systolic,
    diastolic: diastolic,
    temperature: temperature,
    date: date.toDate(),
    moment: moment,
  );
}
