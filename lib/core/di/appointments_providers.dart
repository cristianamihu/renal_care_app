import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:renal_care_app/features/appointments/data/repositories/appointment_repository_impl.dart';
import 'package:renal_care_app/features/appointments/data/services/appointment_remote_service.dart';
import 'package:renal_care_app/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:renal_care_app/features/appointments/domain/usecases/create_appointment.dart';
import 'package:renal_care_app/features/appointments/domain/usecases/delete_appointment.dart';
import 'package:renal_care_app/features/appointments/domain/usecases/get_doctor_appointments.dart';
import 'package:renal_care_app/features/appointments/domain/usecases/get_upcoming_appointments.dart';
import 'package:renal_care_app/features/appointments/domain/usecases/update_appointment.dart';
import 'package:renal_care_app/features/appointments/presentation/viewmodels/appointment_state.dart';
import 'package:renal_care_app/features/appointments/presentation/viewmodels/appointment_viewmodel.dart';

final appointmentRemoteServiceProvider = Provider(
  (ref) => AppointmentRemoteService(firestore: FirebaseFirestore.instance),
);

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepositoryImpl(
    ref.read(appointmentRemoteServiceProvider),
    ref,
  );
});

final getUpcomingAppointmentsProvider = Provider(
  (ref) => GetUpcomingAppointments(ref.read(appointmentRepositoryProvider)),
);

final getDoctorAppointmentsProvider = Provider(
  (ref) => GetDoctorAppointments(ref.watch(appointmentRepositoryProvider)),
);

final createAppointmentProvider = Provider(
  (ref) => CreateAppointment(ref.read(appointmentRepositoryProvider)),
);

final updateAppointmentProvider = Provider(
  (ref) => UpdateAppointment(ref.read(appointmentRepositoryProvider)),
);

final deleteAppointmentProvider = Provider(
  (ref) => DeleteAppointment(ref.read(appointmentRepositoryProvider)),
);

final appointmentViewModelProvider =
    StateNotifierProvider<AppointmentViewModel, AppointmentState>(
      (ref) => AppointmentViewModel(
        ref,
        ref.read(getUpcomingAppointmentsProvider),
        ref.watch(getDoctorAppointmentsProvider),
        ref.read(createAppointmentProvider),
        ref.read(updateAppointmentProvider),
        ref.read(deleteAppointmentProvider),
      ),
    );
