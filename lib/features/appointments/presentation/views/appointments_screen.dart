import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:renal_care_app/core/di/appointments_providers.dart';
import 'package:renal_care_app/core/di/chat_providers.dart';
import 'package:renal_care_app/core/theme/app_colors.dart';
import 'package:renal_care_app/features/appointments/presentation/widgets/appointment_tile.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';

class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authViewModelProvider).user!;

    // Alege stream-ul corespunzător rolului
    final asyncAppts =
        user.role == 'doctor'
            ? ref.watch(doctorAppointmentsProvider(user.uid))
            : ref.watch(patientAppointmentsProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.gradient1,
                AppColors.gradient2,
                AppColors.gradient3,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('Upcoming appointments'),
      ),

      body: asyncAppts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.event_busy, size: 80, color: Colors.white38),
                  SizedBox(height: 16),
                  Text(
                    'You have no upcoming appointments.',
                    style: TextStyle(fontSize: 18, color: Colors.white54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final appt = list[i];
              final isPatient = user.role != 'doctor';

              // Încarcă pacientul
              final patientAsync = ref.watch(userProvider(appt.patientId));
              return patientAsync.when(
                loading: () => const ListTile(title: Text('Loading…')),
                error: (e, _) => ListTile(title: Text('Error: $e')),
                data: (patient) {
                  // După ce pacientul e gata, încarcă doctorul
                  final doctorAsync = ref.watch(userProvider(appt.doctorId));
                  return doctorAsync.when(
                    loading: () => const ListTile(title: Text('Loading…')),
                    error: (e, _) => ListTile(title: Text('Error: $e')),
                    data:
                        (doctor) => AppointmentTile(
                          appointment: appt,
                          patientName: patient.name,
                          doctorName: doctor.name,
                          onTap:
                              () => context.push(
                                '/appointments/detail/${appt.id}',
                              ),
                          isEditable: isPatient,
                          onEdit:
                              isPatient
                                  ? () => context.go(
                                    '/appointments/edit/${appt.id}',
                                  )
                                  : null,
                          onDelete:
                              isPatient
                                  ? () => ref.read(deleteAppointmentProvider)(
                                    appt.id,
                                  )
                                  : null,
                        ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton:
          user.role == 'patient'
              ? FloatingActionButton(
                onPressed: () => context.go('/appointments/new'),
                child: const Icon(Icons.add),
              )
              : null,
    );
  }
}
