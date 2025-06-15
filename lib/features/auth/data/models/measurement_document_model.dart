import 'package:cloud_firestore/cloud_firestore.dart';

class MeasurementDocument {
  final String id;
  final String name;
  final DateTime addedAt;
  final String reportType;
  final Map<String, dynamic> data;

  MeasurementDocument({
    required this.id,
    required this.name,
    required this.addedAt,
    required this.reportType,
    required this.data,
  });

  factory MeasurementDocument.fromJson(String id, Map<String, dynamic> json) {
    return MeasurementDocument(
      id: id,
      name: json['name'] as String,
      reportType: json['reportType'] as String,
      addedAt: (json['addedAt'] as Timestamp).toDate(),
      data: Map<String, dynamic>.from(json['data'] as Map),
    );
  }

  factory MeasurementDocument.fromDocument(DocumentSnapshot doc) {
    final json = doc.data()! as Map<String, dynamic>;
    return MeasurementDocument(
      id: doc.id,
      name: json['name'] as String,
      reportType: json['reportType'] as String,
      addedAt: (json['addedAt'] as Timestamp).toDate(),
      data: Map<String, dynamic>.from(json['data'] as Map),
    );
  }

  MeasurementDocument toEntity() => MeasurementDocument(
    id: id,
    name: name,
    reportType: reportType,
    data: data,
    addedAt: addedAt,
  );
}
