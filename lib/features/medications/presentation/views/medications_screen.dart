import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:renal_care_app/core/di/medication_provider.dart';
import 'package:renal_care_app/core/theme/app_colors.dart';
import 'package:renal_care_app/features/medications/domain/entities/medication.dart';
import 'package:renal_care_app/features/medications/presentation/viewmodels/medication_viewmodel.dart';
import 'package:renal_care_app/features/medications/presentation/widgets/medication_tile.dart';
import 'package:renal_care_app/features/medications/presentation/widgets/weekly_calendar.dart';

class MedicationsScreen extends ConsumerStatefulWidget {
  const MedicationsScreen({super.key});

  @override
  ConsumerState<MedicationsScreen> createState() => MedicationsScreenState();
}

class MedicationsScreenState extends ConsumerState<MedicationsScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
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
          children: [
            WeeklyCalendar(
              initialSelectedDate: selectedDate,
              onDateSelected: (d) => setState(() => selectedDate = d),
            ),
            const SizedBox(height: 48),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.medication_outlined,
                      size: 80,
                      color: Colors.white38,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "No doses scheduled this day.",
                      style: TextStyle(fontSize: 18, color: Colors.white54),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: _buildAddButton(context),
      );
    }

    // Filtrezi medicamentele pentru selectedDate:
    final Map<String, List<Medication>> medsByTime = {};
    for (final med in medState.medications) {
      // sară dacă selectedDate nu e în interval
      final dateOnly = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );
      final startOnly = DateTime(
        med.startDate.year,
        med.startDate.month,
        med.startDate.day,
      );
      final endOnly =
          med.endDate != null
              ? DateTime(
                med.endDate!.year,
                med.endDate!.month,
                med.endDate!.day,
              )
              : null;

      if (dateOnly.isBefore(startOnly)) continue;
      if (endOnly != null && dateOnly.isAfter(endOnly)) continue;

      final diffDays = dateOnly.difference(startOnly).inDays;
      if (med.specificWeekdays.isNotEmpty) {
        if (!med.specificWeekdays.contains(dateOnly.weekday)) continue;
      } else {
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
          WeeklyCalendar(
            initialSelectedDate: selectedDate,
            onDateSelected: (d) => setState(() => selectedDate = d),
          ),
          const SizedBox(height: 8),

          // Dacă nu există doze în ziua selectată → placeholder
          if (sortedTimeKeys.isEmpty) ...[
            const SizedBox(height: 48),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.medication_outlined,
                      size: 80,
                      color: Colors.white38,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "No doses scheduled this day.",
                      style: TextStyle(fontSize: 18, color: Colors.white54),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ] else
            // Altfel, lista cu doze
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
                  final displayedTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
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
