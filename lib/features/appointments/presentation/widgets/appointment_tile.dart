import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:renal_care_app/features/appointments/domain/entities/appointment.dart';

class AppointmentTile extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AppointmentTile({
    required this.appointment,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dt = DateFormat('dd MMM yyyy, HH:mm').format(appointment.dateTime);
    return ListTile(
      title: Text(appointment.description),
      subtitle: Text(dt),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: Icon(Icons.edit), onPressed: onEdit),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder:
                    (ctx) => AlertDialog(
                      title: const Text('Delete appointment'),
                      content: const Text(
                        'Are you sure you want to delete this appointment?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
              );

              if (confirmed == true) {
                onDelete();
              }
            },
          ),
        ],
      ),
    );
  }
}
