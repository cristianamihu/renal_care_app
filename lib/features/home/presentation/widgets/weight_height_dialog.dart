import 'package:flutter/material.dart';
import 'package:renal_care_app/features/home/presentation/widgets/moment_chips.dart';

class WeightHeightDialog extends StatefulWidget {
  final void Function(double weight, double height, String moment) onSave;
  const WeightHeightDialog({required this.onSave, super.key});

  @override
  WeightHeightDialogState createState() => WeightHeightDialogState();
}

class WeightHeightDialogState extends State<WeightHeightDialog> {
  double _weight = 0;
  double _height = 0;
  String _moment = 'Dimineața';

  @override
  Widget build(BuildContext context) {
    // Screen height
    final screenH = MediaQuery.of(context).size.height;

    return AlertDialog(
      title: const Text('Weight & Height'),
      content: ConstrainedBox(
        // limit to half the screen height
        constraints: BoxConstraints(maxHeight: screenH * 0.5),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => _weight = double.tryParse(v) ?? 0,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => _height = double.tryParse(v) ?? 0,
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
            widget.onSave(_weight, _height, _moment);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
