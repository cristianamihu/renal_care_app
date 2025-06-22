import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:renal_care_app/core/di/medication_provider.dart';
import 'package:renal_care_app/core/theme/app_colors.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:renal_care_app/features/medications/domain/entities/medication.dart';
import 'package:renal_care_app/features/medications/presentation/widgets/frequency_piker.dart';

class AddEditMedicationScreen extends ConsumerStatefulWidget {
  /// Dacă venim de la edit, primim [initialMedication]
  final Medication? initialMedication;

  const AddEditMedicationScreen({this.initialMedication, super.key});

  @override
  ConsumerState<AddEditMedicationScreen> createState() =>
      _AddEditMedicationScreenState();
}

class _AddEditMedicationScreenState
    extends ConsumerState<AddEditMedicationScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _doseController;
  late TextEditingController _unitController;
  late FrequencyOption _frequencyOption;
  late int _everyXDays;
  late List<int> _selectedWeekdays;

  List<TimeOfDay> _times = []; // orele din zi
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    final m = widget.initialMedication;
    if (m != null) {
      // Suntem în modul „edit” → pre-umplem
      _nameController = TextEditingController(text: m.name);
      _doseController = TextEditingController(text: m.dose.toString());
      _unitController = TextEditingController(text: m.unit);
      _notificationsEnabled = m.notificationsEnabled;

      // Mapăm numeric
      if (m.frequency == 1) {
        _frequencyOption = FrequencyOption.everyDay;
        _everyXDays = 1;
      } else if (m.frequency == 2) {
        _frequencyOption = FrequencyOption.everyOtherDay;
        _everyXDays = 2;
      } else {
        _frequencyOption = FrequencyOption.everyXDays;
        _everyXDays = m.frequency;
      }

      if (m.specificWeekdays.isNotEmpty) {
        _frequencyOption = FrequencyOption.specificDaysOfWeek;
        _selectedWeekdays = List.from(m.specificWeekdays);
      } else {
        _selectedWeekdays = <int>[];
      }

      _times = m.times.map((dt) => TimeOfDay.fromDateTime(dt)).toList();
    } else {
      // Modul „add new”
      _nameController = TextEditingController();
      _doseController = TextEditingController();
      _unitController = TextEditingController();
      _frequencyOption = FrequencyOption.everyDay;
      _everyXDays = 1;
      _times = [];
      _notificationsEnabled = true;
      _selectedWeekdays = [];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: now);
    if (picked != null && !_times.contains(picked)) {
      setState(() => _times.add(picked));
    }
  }

  Future<void> _confirmClose() async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Are you giving up on changes?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Continue'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Quit', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    // Verificăm dacă widget-ul mai este montat înainte de a folosi context
    if (!mounted) return;
    if (result == true) {
      context.go('/medications');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one hour of administration'),
        ),
      );
      return;
    }

    final name = _nameController.text.trim();
    final dose = double.tryParse(_doseController.text.trim()) ?? 0.0;
    final unit = _unitController.text.trim();
    if (name.isEmpty || dose <= 0 || unit.isEmpty || _times.isEmpty) {
      // putem afișa un SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Fill in all fields and add at least one hour of administration',
          ),
        ),
      );
      return;
    }

    // Mapăm opțiunea de frecvență la acest număr de zile pentru entitatea Medication
    switch (_frequencyOption) {
      case FrequencyOption.everyDay:
        break;
      case FrequencyOption.everyOtherDay:
        break;
      case FrequencyOption.specificDaysOfWeek:
        // Poți modifica după cum ai nevoie (de ex. 7 zile, dar pur și simplu ca marcaj)
        break;
      case FrequencyOption.everyXDays:
        break;
    }

    // Conversia times
    final now = DateTime.now();
    final List<DateTime> timesAsDateTime =
        _times.map((tod) {
          return DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
        }).toList();

    final newMed = Medication(
      id: widget.initialMedication?.id ?? '',
      name: name,
      dose: dose,
      unit: unit,
      startDate: widget.initialMedication?.startDate ?? now,
      endDate: widget.initialMedication?.endDate,
      // strict legat de ce a ales userul:
      frequency:
          _frequencyOption == FrequencyOption.everyDay
              ? 1
              : _frequencyOption == FrequencyOption.everyOtherDay
              ? 2
              : (_frequencyOption == FrequencyOption.everyXDays
                  ? _everyXDays
                  : 7), // dacă e specificDaysOfWeek, punem 7 (oricum nu vom folosi)
      times: timesAsDateTime,
      notificationsEnabled: _notificationsEnabled,
      createdAt: widget.initialMedication?.createdAt ?? now,
      updatedAt: now,
      specificWeekdays:
          _frequencyOption == FrequencyOption.specificDaysOfWeek
              ? _selectedWeekdays
              : [], // dacă e altă opțiune, listă goală
    );

    try {
      final uid = ref.read(authViewModelProvider).user!.uid;

      if (widget.initialMedication == null) {
        await ref.read(addMedicationUseCaseProvider).call(uid, newMed);
      } else {
        await ref.read(updateMedicationUseCaseProvider).call(uid, newMed);
      }

      // forțăm reîncărcarea listei când ne întoarcem
      ref.invalidate(medicationViewModelProvider);

      if (!mounted) return;
      context.go('/medications');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialMedication != null;

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
        title: Text(isEditing ? 'Edit Medication' : 'Add Medication'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _confirmClose,
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Nume medicament
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Medication name',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'You must enter a name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Doză și unitate
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _doseController,
                        decoration: const InputDecoration(labelText: 'Take'),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final n = double.tryParse(v ?? '');
                          if (n == null || n <= 0) {
                            return 'Dose must be > 0';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: TextFormField(
                        controller: _unitController,
                        decoration: const InputDecoration(
                          labelText: 'Unit (e.g. pill, mg, ml)',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Unity is necessary';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Frecvența
                FrequencyPicker(
                  initialOption: _frequencyOption,
                  initialEveryXDays: _everyXDays,
                  initialSelectedWeekdays: _selectedWeekdays,
                  onFrequencyChanged: (chosenOption, everyX, selectedWeekdays) {
                    setState(() {
                      _frequencyOption = chosenOption;
                      _everyXDays = everyX;
                      _selectedWeekdays = selectedWeekdays;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Ore de administrare
                Row(
                  children: [
                    const Text(
                      'Administration hours:',
                      style: TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add time'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gradient3,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.gradient3.withValues(
                          alpha: 0.5,
                        ),
                        disabledForegroundColor: Colors.white.withValues(
                          alpha: 0.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                      onPressed: _times.isEmpty ? _pickTime : null,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  children:
                      _times.map((tod) {
                        final labelTime =
                            '${tod.hour.toString().padLeft(2, '0')}:${tod.minute.toString().padLeft(2, '0')}';
                        return Chip(
                          label: Text(labelTime),
                          onDeleted: () {
                            setState(() => _times.remove(tod));
                          },
                        );
                      }).toList(),
                ),
                const SizedBox(height: 12),

                // Switch notificări
                SwitchListTile(
                  title: const Text('Administration alarm'),
                  value: _notificationsEnabled,
                  onChanged: (v) => setState(() => _notificationsEnabled = v),
                ),

                const SizedBox(height: 24),

                // Buton Final „ADAUGĂ” sau „SALVEAZĂ”
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gradient3,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(isEditing ? 'SAVE' : 'ADD'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
