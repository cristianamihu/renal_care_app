import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> create(Appointment appt) async {
    await _createUC(appt);
    await loadUpcoming();
  }

  Future<void> update(Appointment appt) async {
    await _updateUC(appt);
    await loadUpcoming();
  }

  Future<void> delete(String id) async {
    await _deleteUC(id);
    await loadUpcoming();
  }
}
