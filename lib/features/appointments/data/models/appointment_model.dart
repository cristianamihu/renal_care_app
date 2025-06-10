import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:renal_care_app/features/appointments/domain/entities/appointment.dart';

class AppointmentModel {
  final String id;
  final String patientId;
  final Timestamp dateTime;
  final String doctorId;
  final String description;
  final String doctorAddress;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.dateTime,
    required this.doctorId,
    required this.description,
    required this.doctorAddress,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json, String id) =>
      AppointmentModel(
        id: id,
        patientId: json['patientId'] as String,
        dateTime: json['dateTime'] as Timestamp,
        doctorId: json['doctorId'] as String,
        description: json['description'] as String? ?? '',
        doctorAddress: json['doctorAddress'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
    'patientId': patientId,
    'dateTime': dateTime,
    'doctorId': doctorId,
    'description': description,
    'doctorAddress': doctorAddress,
  };

  Appointment toEntity() => Appointment(
    id: id,
    patientId: patientId,
    dateTime: dateTime.toDate(),
    doctorId: doctorId,
    description: description,
    doctorAddress: doctorAddress,
  );
}
