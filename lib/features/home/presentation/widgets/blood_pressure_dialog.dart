import 'package:flutter/material.dart';
import 'moment_chips.dart';

/// Callback când salvaţi: sistolic, diastolic, puls şi momentul zilei
typedef BloodPressureSave =
    void Function(int systolic, int diastolic, int pulse, String moment);

class BloodPressureDialog extends StatefulWidget {
  final BloodPressureSave onSave;
  const BloodPressureDialog({required this.onSave, super.key});

  @override
  BloodPressureDialogState createState() => BloodPressureDialogState();
}

class BloodPressureDialogState extends State<BloodPressureDialog> {
  int _systolic = 0;
  int _diastolic = 0;
  int _pulse = 0;
  String _moment = 'Dimineața';

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    return AlertDialog(
      title: const Text('Blood Pressure'),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenH * 0.5),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Systolic (mmHg)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => _systolic = int.tryParse(v) ?? 0,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Diastolic (mmHg)',
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => _diastolic = int.tryParse(v) ?? 0,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: 'Pulse (BPM)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => _pulse = int.tryParse(v) ?? 0,
              ),
              const SizedBox(height: 16),
              MomentChips(
                selected: _moment,
                onSelected: (m) => setState(() => _moment = m),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_systolic, _diastolic, _pulse, _moment);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
