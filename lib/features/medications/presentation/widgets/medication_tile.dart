import 'package:flutter/material.dart';

import 'package:renal_care_app/features/medications/domain/entities/medication.dart';

class MedicationTile extends StatelessWidget {
  final List<Medication> medsAtThisTime;
  final DateTime time;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MedicationTile({
    required this.medsAtThisTime,
    required this.time,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final oraString =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1) Titlul cu ora (HH:mm)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            oraString,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        // 2) Pentru fiecare medicament din această oră, afișăm câte un Card separat
        ...medsAtThisTime.map((med) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Card(
              color: const Color(
                0xFF2A2A2E,
              ), // gri-închis (sau oricare se potrivește temei tale)
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: ListTile(
                // Poți schimba icon-ul în funcție de unitate (ex. „pill” vs. „mg”), după cum dorești:
                leading:
                    med.unit.toLowerCase().contains('pill')
                        ? const Icon(Icons.circle, color: Colors.white)
                        : const Icon(Icons.invert_colors, color: Colors.white),
                title: Text(
                  med.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Take ${med.dose.toString()} ${med.unit}',
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (choice) {
                    if (choice == 'edit') onEdit();
                    if (choice == 'delete') onDelete();
                  },
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  itemBuilder:
                      (ctx) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
