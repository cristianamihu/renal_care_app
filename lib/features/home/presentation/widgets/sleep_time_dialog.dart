import 'package:flutter/material.dart';

/// Simple pair of DateTimes for start/end
class TimeRange {
  final DateTime start, end;
  TimeRange({required this.start, required this.end});
}

/// A dialog that lets you pick a bed‐time and wake‐time, then returns them as a TimeRange.
class SleepTimeDialog extends StatefulWidget {
  final DateTime? initialStart;
  final DateTime? initialEnd;

  const SleepTimeDialog({this.initialStart, this.initialEnd, super.key});

  @override
  State<SleepTimeDialog> createState() => _SleepTimeDialogState();
}

class _SleepTimeDialogState extends State<SleepTimeDialog> {
  late TimeOfDay _start;
  late TimeOfDay _end;

  @override
  void initState() {
    super.initState();
    final now = TimeOfDay.now();
    _start =
        widget.initialStart != null
            ? TimeOfDay.fromDateTime(widget.initialStart!)
            : now;
    _end =
        widget.initialEnd != null
            ? TimeOfDay.fromDateTime(widget.initialEnd!)
            : now;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Sleep Times'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.hotel),
            title: const Text('Bed time'),
            trailing: Text(_start.format(context)),
            onTap: () async {
              final t = await showTimePicker(
                context: context,
                initialTime: _start,
              );
              if (t != null) setState(() => _start = t);
            },
          ),

          ListTile(
            leading: const Icon(Icons.alarm),
            title: const Text('Wake time'),
            trailing: Text(_end.format(context)),
            onTap: () async {
              final t = await showTimePicker(
                context: context,
                initialTime: _end,
              );
              if (t != null) setState(() => _end = t);
            },
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
            final today = DateTime.now();
            final startDt = DateTime(
              today.year,
              today.month,
              today.day,
              _start.hour,
              _start.minute,
            );
            var endDt = DateTime(
              today.year,
              today.month,
              today.day,
              _end.hour,
              _end.minute,
            );
            if (!endDt.isAfter(startDt)) {
              endDt = endDt.add(const Duration(days: 1));
            }
            Navigator.pop(context, TimeRange(start: startDt, end: endDt));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
