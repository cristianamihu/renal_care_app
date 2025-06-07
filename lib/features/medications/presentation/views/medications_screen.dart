import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:renal_care_app/core/di/medication_provider.dart';
import 'package:renal_care_app/core/theme/app_colors.dart';
import 'package:renal_care_app/features/medications/domain/entities/medication.dart';
import 'package:renal_care_app/features/medications/presentation/viewmodels/medication_viewmodel.dart';
import 'package:renal_care_app/features/medications/presentation/widgets/medication_tile.dart';
import 'package:renal_care_app/features/medications/presentation/widgets/weekly_calendar.dart';

class MedicationsScreen extends ConsumerWidget {
  const MedicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medState = ref.watch(medicationViewModelProvider);
    final medVM = ref.read(medicationViewModelProvider.notifier);

    // Situaţia “încărcare”
    if (medState.loading) {
      return Scaffold(
        appBar: _buildGradientAppBar(),
        body: const Center(child: CircularProgressIndicator()),
        floatingActionButton: _buildAddButton(context),
      );
    }

    // Situaţia “eroare”
    if (medState.error != null) {
      return Scaffold(
        appBar: _buildGradientAppBar(),
        body: Center(child: Text('Error: ${medState.error}')),
        floatingActionButton: _buildAddButton(context),
      );
    }

    // Listă goală
    if (medState.medications.isEmpty) {
      return Scaffold(
        appBar: _buildGradientAppBar(),
        body: Column(
          children: const [
            WeeklyCalendar(), // Calendarul de sus
            Expanded(child: Center(child: Text('No added medications'))),
          ],
        ),
        floatingActionButton: _buildAddButton(context),
      );
    }

    final Map<String, List<Medication>> medsByTime = {};
    final DateTime today = DateTime.now();

    for (final med in medState.medications) {
      // 1) Dacă azi e după endDate, sară peste
      if (med.endDate != null && today.isAfter(med.endDate!)) continue;

      // 2) Dacă azi e înainte de startDate, sară peste
      if (today.isBefore(med.startDate)) continue;

      // Dacă sunt `specificWeekdays`, atunci verifici pur și simplu:
      if (med.specificWeekdays.isNotEmpty) {
        if (!med.specificWeekdays.contains(today.weekday)) {
          continue;
        }
      } else {
        // Altfel (fără zile specifice) folosești logică pe frequency
        final int diffDays =
            DateTime(today.year, today.month, today.day)
                .difference(
                  DateTime(
                    med.startDate.year,
                    med.startDate.month,
                    med.startDate.day,
                  ),
                )
                .inDays;
        if (diffDays % med.frequency != 0) continue;
      }

      // Dacă a trecut de toate condițiile, adaugă orele din med.times
      for (final dt in med.times) {
        final String key =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
        medsByTime.putIfAbsent(key, () => []).add(med);
      }
    }

    // sortăm cheile “HH:mm” în ordine cronologică
    final List<String> sortedTimeKeys =
        medsByTime.keys.toList()..sort((a, b) {
          final partsA = a.split(':');
          final partsB = b.split(':');
          final int hourA = int.parse(partsA[0]);
          final int minA = int.parse(partsA[1]);
          final int hourB = int.parse(partsB[0]);
          final int minB = int.parse(partsB[1]);
          if (hourA != hourB) return hourA.compareTo(hourB);
          return minA.compareTo(minB);
        });

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
        title: const Text('Medications'),
      ),

      body: Column(
        children: [
          // Calendarul orizontal
          const WeeklyCalendar(),
          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              itemCount: sortedTimeKeys.length,
              itemBuilder: (ctx, index) {
                final String timeKey = sortedTimeKeys[index];
                final List<Medication> medsAtThisTime = medsByTime[timeKey]!;

                // Parse “HH:mm” în DateTime, doar pentru afişare în widget
                final parts = timeKey.split(':');
                final hour = int.parse(parts[0]);
                final minute = int.parse(parts[1]);
                final now = DateTime.now();
                final displayedTime = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  hour,
                  minute,
                );

                // onEdit & onDelete pentru primul medicament din listă
                final String firstMedId = medsAtThisTime.first.id;

                return MedicationTile(
                  medsAtThisTime: medsAtThisTime,
                  time: displayedTime,
                  onEdit: () {
                    context.go('/medications/edit/$firstMedId');
                  },
                  onDelete: () {
                    _confirmDelete(context, medVM, firstMedId);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildAddButton(context),
    );
  }

  PreferredSizeWidget _buildGradientAppBar() {
    return AppBar(
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
    );
  }

  FloatingActionButton _buildAddButton(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: AppColors.gradient3,
      foregroundColor: Colors.white,
      onPressed: () {
        context.go('/medications/add');
      },
      child: const Icon(Icons.add),
    );
  }
}

void _confirmDelete(
  BuildContext context,
  MedicationViewModel vm,
  String medId,
) {
  showDialog<bool>(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: const Text('Are you deleting this medication?'),
          content: const Text(
            'You are about to delete this medication, which means you will no longer receive reminders for it.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
  ).then((confirmed) {
    if (confirmed == true) {
      vm.deleteMedicationById(medId);
    }
  });
}
