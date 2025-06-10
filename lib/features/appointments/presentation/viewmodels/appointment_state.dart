import 'package:renal_care_app/features/appointments/domain/entities/appointment.dart';

class AppointmentState {
  final bool loading;
  final List<Appointment> upcoming;
  final String? error;

  AppointmentState({
    this.loading = false,
    this.upcoming = const [],
    this.error,
  });

  AppointmentState copyWith({
    bool? loading,
    List<Appointment>? upcoming,
    String? error,
  }) => AppointmentState(
    loading: loading ?? this.loading,
    upcoming: upcoming ?? this.upcoming,
    error: error,
  );
}
