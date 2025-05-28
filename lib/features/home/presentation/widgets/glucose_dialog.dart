import 'package:flutter/material.dart';

import 'package:renal_care_app/features/home/presentation/widgets/moment_chips.dart';

enum GlucoseUnit { mgdL, mmol }

class GlucoseDialog extends StatefulWidget {
  final void Function(double value, GlucoseUnit unit, String moment) onSave;
  const GlucoseDialog({required this.onSave, super.key});

  @override
  GlucoseDialogState createState() => GlucoseDialogState();
}

class GlucoseDialogState extends State<GlucoseDialog> {
  double _value = 0;
  GlucoseUnit _unit = GlucoseUnit.mgdL;
  String _moment = 'Dimineața';

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    return AlertDialog(
      title: const Text('Glucose'),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenH * 0.5),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(labelText: 'Value'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _value = double.tryParse(v) ?? 0.0,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // **Dropped the const on the items list here**
                  DropdownButton<GlucoseUnit>(
                    value: _unit,
                    items: [
                      DropdownMenuItem<GlucoseUnit>(
                        value: GlucoseUnit.mgdL,
                        child: const Text('mg/dL'),
                      ),
                      DropdownMenuItem<GlucoseUnit>(
                        value: GlucoseUnit.mmol,
                        child: const Text('mmol/L'),
                      ),
                    ],
                    onChanged: (u) {
                      if (u != null) setState(() => _unit = u);
                    },
                  ),
                ],
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
            widget.onSave(_value, _unit, _moment);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
