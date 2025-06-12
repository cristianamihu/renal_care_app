import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:renal_care_app/core/di/appointments_providers.dart';
import 'package:renal_care_app/core/theme/app_colors.dart';
import 'package:renal_care_app/features/appointments/presentation/widgets/appointment_tile.dart';

class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appointmentViewModelProvider);
    final vm = ref.read(appointmentViewModelProvider.notifier);

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
      body:
          state.loading
              ? const Center(child: CircularProgressIndicator())
              : state.error != null
              ? Center(child: Text('Error: ${state.error}'))
              : state.upcoming.isEmpty
              ? Center(
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
              )
              : ListView.builder(
                itemCount: state.upcoming.length,
                itemBuilder: (_, i) {
                  final appt = state.upcoming[i];
                  return AppointmentTile(
                    appointment: appt,
                    onEdit: () => context.go('/appointments/edit/${appt.id}'),
                    onDelete: () => vm.delete(appt.id),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/appointments/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
