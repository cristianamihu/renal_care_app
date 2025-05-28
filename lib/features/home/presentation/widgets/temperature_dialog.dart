import 'package:flutter/material.dart';
import 'moment_chips.dart';

typedef TemperatureSave = void Function(double temperature, String moment);

class TemperatureDialog extends StatefulWidget {
  final TemperatureSave onSave;
  const TemperatureDialog({required this.onSave, super.key});

  @override
  TemperatureDialogState createState() => TemperatureDialogState();
}

class TemperatureDialogState extends State<TemperatureDialog> {
  double _temp = 0;
  String _moment = 'Dimineața';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Temperature'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Temperature (°C)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => _temp = double.tryParse(v) ?? 0,
          ),
          const SizedBox(height: 12),
          MomentChips(
            selected: _moment,
            onSelected: (m) => setState(() => _moment = m),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_temp, _moment);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
