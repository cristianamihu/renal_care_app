import 'package:intl/intl.dart';
import 'package:renal_care_app/core/utils/appointment_notification_storage.dart';
import 'package:renal_care_app/core/utils/notification_helper.dart';
import 'package:renal_care_app/features/appointments/domain/entities/appointment.dart';
import 'package:renal_care_app/features/appointments/domain/repositories/appointment_repository.dart';

class UpdateAppointment {
  final AppointmentRepository _repo;
  UpdateAppointment(this._repo);
  Future<void> call(Appointment appt) async {
    // Anulează vechile notificări
    final oldIds = await AppointmentNotificationStorage.removeNotificationIds(
      appt.id,
    );
    for (final id in oldIds) {
      await NotificationHelper.cancelAlarmById(id);
    }

    // Actualizează consultația în Firestore
    await _repo.update(appt);

    // Programează reminder-ul la 24h înainte, dacă e în viitor
    final reminderTime = appt.dateTime.subtract(const Duration(hours: 24));
    if (reminderTime.isAfter(DateTime.now())) {
      final notifId = appt.id.hashCode;
      await NotificationHelper.scheduleAppointmentNotification(
        notificationId: notifId,
        scheduledTime: reminderTime,
        title: 'Upcoming consultation',
        body:
            'Tomorrow at ${DateFormat('dd MMM yyyy, HH:mm').format(appt.dateTime)}, you have a consultation.',
      );
      await AppointmentNotificationStorage.addNotificationId(appt.id, notifId);
    }
  }
}
