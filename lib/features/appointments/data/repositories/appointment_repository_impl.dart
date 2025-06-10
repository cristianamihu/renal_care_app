import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:renal_care_app/features/appointments/data/models/appointment_model.dart';
import 'package:renal_care_app/features/appointments/data/services/appointment_remote_service.dart';
import 'package:renal_care_app/features/appointments/domain/entities/appointment.dart';
import 'package:renal_care_app/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteService _remote;
  final Ref _ref;
  AppointmentRepositoryImpl(this._remote, this._ref);

  @override
  Future<List<Appointment>> fetchUpcoming(String userId) async {
    final models = await _remote.fetchUpcoming(userId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> create(Appointment appt) async {
    final model = AppointmentModel(
      id: appt.id,
      patientId: appt.patientId,
      dateTime: Timestamp.fromDate(appt.dateTime),
      doctorId: appt.doctorId,
      description: appt.description,
      doctorAddress: appt.doctorAddress,
    );
    return _remote.create(model, appt.patientId);
  }

  @override
  Future<void> update(Appointment appt) async {
    final model = AppointmentModel(
      id: appt.id,
      patientId: appt.patientId,
      dateTime: Timestamp.fromDate(appt.dateTime),
      doctorId: appt.doctorId,
      description: appt.description,
      doctorAddress: appt.doctorAddress,
    );
    return _remote.update(model, appt.patientId);
  }

  @override
  Future<void> delete(String id) async {
    final uid = _ref.read(authViewModelProvider).user!.uid;
    await _remote.delete(id, uid);
  }

  @override
  Future<List<String>> getBookedSlots(String doctorId, String dayKey) {
    return _remote.fetchSlotsForDoctor(doctorId, dayKey);
  }

  @override
  Future<List<Appointment>> fetchByDoctor(
    String doctorId,
    String dayKey,
  ) async {
    final models = await _remote.fetchByDoctor(doctorId, dayKey);
    return models.map((m) => m.toEntity()).toList();
  }
}
