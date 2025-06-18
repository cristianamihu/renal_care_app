import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:renal_care_app/core/theme/app_colors.dart';
import 'package:renal_care_app/features/home/presentation/viewmodels/measurement_viewmodel.dart';

class AllergyForm extends ConsumerStatefulWidget {
  final MeasurementViewModel vm;
  const AllergyForm({super.key, required this.vm});

  @override
  ConsumerState<AllergyForm> createState() => _AllergyFormState();
}

class _AllergyFormState extends ConsumerState<AllergyForm> {
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Do you have one or more medication, food or other allergies?',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _ctrl,
          decoration: const InputDecoration(
            hintText: 'Enter allergy',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gradient3,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
          label: const Text('ADD'),
          onPressed: () {
            final name = _ctrl.text.trim();
            if (name.isNotEmpty) {
              widget.vm.addAllergy(name);
              _ctrl.clear();
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
