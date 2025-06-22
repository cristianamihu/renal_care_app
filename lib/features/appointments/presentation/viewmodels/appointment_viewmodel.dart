import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:renal_care_app/core/utils/appointment_notification_storage.dart';
import 'package:renal_care_app/core/utils/notification_helper.dart';

import 'package:renal_care_app/features/appointments/domain/entities/appointment.dart';
import 'package:renal_care_app/features/appointments/domain/usecases/create_appointment.dart';
import 'package:renal_care_app/features/appointments/domain/usecases/delete_appointment.dart';
import 'package:renal_care_app/features/appointments/domain/usecases/get_doctor_appointments.dart';
import 'package:renal_care_app/features/appointments/domain/usecases/get_upcoming_appointments.dart';
import 'package:renal_care_app/features/appointments/domain/usecases/update_appointment.dart';
import 'package:renal_care_app/features/appointments/presentation/viewmodels/appointment_state.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';

class AppointmentViewModel extends StateNotifier<AppointmentState> {
  final Ref _ref;
  final GetUpcomingAppointments _getPatientUC;
  final GetDoctorAppointments _getDoctorUC;
  final CreateAppointment _createUC;
  final UpdateAppointment _updateUC;
  final DeleteAppointment _deleteUC;

  AppointmentViewModel(
    this._ref,
    this._getPatientUC,
    this._getDoctorUC,
    this._createUC,
    this._updateUC,
    this._deleteUC,
  ) : super(AppointmentState()) {
    loadUpcoming();
  }

  Future<void> loadUpcoming() async {
    state = state.copyWith(loading: true, error: null);
    final user = _ref.read(authViewModelProvider).user!;
    try {
      List<Appointment> list;
      if (user.role == 'doctor') {
        final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
        list = await _getDoctorUC(user.uid, todayKey);
      } else {
        list = await _getPatientUC(
          user.uid,
        ); // preia programările făcute de pacient
      }
      state = state.copyWith(loading: false, upcoming: list);

      _scheduleConsultationReminders(list);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  void _scheduleConsultationReminders(List<Appointment> appts) {
    final now = DateTime.now();
    for (var appt in appts) {
      final reminderTime = appt.dateTime.subtract(const Duration(hours: 24));
      // dacă reminder-ul e deja în trecut, sarim peste
      if (reminderTime.isBefore(now)) continue;

      final notifId = appt.id.hashCode;

      // programăm notificarea
      NotificationHelper.scheduleAppointmentNotification(
        notificationId: notifId,
        scheduledTime: reminderTime,
        title: 'Upcoming consultation',
        body:
            'Tomorrow at ${DateFormat('dd MMM yyyy, HH:mm').format(appt.dateTime)}, you have a consultation.',
      );

      AppointmentNotificationStorage.addNotificationId(appt.id, notifId);
    }
  }

  Future<void> create(Appointment appt) async {
    await _createUC(appt);
    // după create, programăm reminder-ul pentru acel appt
    final reminderTime = appt.dateTime.subtract(const Duration(hours: 24));
    if (reminderTime.isAfter(DateTime.now())) {
      final notifId = appt.id.hashCode;
      NotificationHelper.scheduleExactAlarm(
        notificationId: notifId,
        scheduledTime: reminderTime,
        medsDescription:
            'Reminder: tomorrow, ${DateFormat('dd MMM yyyy, HH:mm').format(appt.dateTime)}, you have a consultation.',
      );
      await AppointmentNotificationStorage.addNotificationId(appt.id, notifId);
    }
    await loadUpcoming();
  }

  Future<void> update(Appointment appt) async {
    // anulăm reminder-ul vechi
    final oldIds = await AppointmentNotificationStorage.removeNotificationIds(
      appt.id,
    );
    for (var notifId in oldIds) {
      await NotificationHelper.cancelAlarmById(notifId);
    }

    // actualizăm în Firestore
    await _updateUC(appt);

    // reload + reprogramează reminder-ul nou
    await loadUpcoming();
  }

  Future<void> delete(String id) async {
    // anulăm toate notificările planificate pentru această programare
    final ids = await AppointmentNotificationStorage.removeNotificationIds(id);
    for (var notifId in ids) {
      await NotificationHelper.cancelAlarmById(notifId);
    }

    // apoi ştergem din Firestore
    await _deleteUC(id);
    await loadUpcoming();
  }
}
