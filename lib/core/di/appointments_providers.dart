import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:renal_care_app/features/appointments/data/models/appointment_model.dart';

import 'package:renal_care_app/features/appointments/data/repositories/appointment_repository_impl.dart';
import 'package:renal_care_app/features/appointments/data/services/appointment_remote_service.dart';
import 'package:renal_care_app/features/appointments/domain/entities/appointment.dart';
import 'package:renal_care_app/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:renal_care_app/features/appointments/domain/usecases/create_appointment.dart';
import 'package:renal_care_app/features/appointments/domain/usecases/delete_appointment.dart';
import 'package:renal_care_app/features/appointments/domain/usecases/update_appointment.dart';

final appointmentRemoteServiceProvider = Provider(
  (ref) => AppointmentRemoteService(firestore: FirebaseFirestore.instance),
);

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepositoryImpl(
    ref.read(appointmentRemoteServiceProvider),
    ref,
  );
});

final createAppointmentProvider = Provider(
  (ref) => CreateAppointment(ref.read(appointmentRepositoryProvider)),
);

final updateAppointmentProvider = Provider(
  (ref) => UpdateAppointment(ref.read(appointmentRepositoryProvider)),
);

final deleteAppointmentProvider = Provider(
  (ref) => DeleteAppointment(ref.read(appointmentRepositoryProvider)),
);

/// Listează programările viitoare ale pacientului (din /users/{uid}/appointments)
final patientAppointmentsProvider = StreamProvider.autoDispose
    .family<List<Appointment>, String>((ref, patientId) {
      final now = DateTime.now();
      return FirebaseFirestore.instance
          .collection('users')
          .doc(patientId)
          .collection('appointments')
          .where('dateTime', isGreaterThan: Timestamp.fromDate(now))
          .orderBy('dateTime')
          .snapshots()
          .map(
            (snap) =>
                snap.docs
                    .map(
                      (d) =>
                          AppointmentModel.fromJson(d.data(), d.id).toEntity(),
                    )
                    .toList(),
          );
    });

/// Listează toate programările viitoare ale doctorului (cross‐day)
final doctorAppointmentsProvider = StreamProvider.autoDispose
    .family<List<Appointment>, String>((ref, doctorId) {
      final now = DateTime.now();
      return FirebaseFirestore.instance
          // caută în toate sub‐colecțiile numite “slots”
          .collectionGroup('slots')
          // filtrează după doctorId
          .where('doctorId', isEqualTo: doctorId)
          // filtrează doar ora viitoare
          .where('dateTime', isGreaterThan: Timestamp.fromDate(now))
          // ordonează cronologic
          .orderBy('dateTime')
          .snapshots()
          .map(
            (snap) =>
                snap.docs.map((d) {
                  final data = d.data();
                  return Appointment(
                    id: data['appointmentId'] as String,
                    patientId: data['patientId'] as String,
                    dateTime: (data['dateTime'] as Timestamp).toDate(),
                    doctorId: doctorId,
                    description: data['description'] as String? ?? '',
                    doctorAddress: data['doctorAddress'] as String? ?? '',
                  );
                }).toList(),
          );
    });
