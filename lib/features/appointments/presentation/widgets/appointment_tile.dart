import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:renal_care_app/core/theme/app_colors.dart';

import 'package:renal_care_app/features/appointments/domain/entities/appointment.dart';

class AppointmentTile extends StatelessWidget {
  final Appointment appointment;
  final String patientName;
  final String doctorName;
  final bool isEditable;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const AppointmentTile({
    required this.appointment,
    required this.patientName,
    required this.doctorName,
    this.isEditable = false,
    this.onEdit,
    this.onDelete,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dt = DateFormat('dd MMM yyyy, HH:mm').format(appointment.dateTime);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(appointment.description),
          subtitle: Text(dt),
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          children: [
            // aici pui detaliile
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 20,
                  color: AppColors.gradient1,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text('Pacient: $patientName')),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.medical_services_outlined,
                  size: 20,
                  color: AppColors.gradient1,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text('Doctor: $doctorName')),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: AppColors.gradient1,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text('Adresă: ${appointment.doctorAddress}')),
              ],
            ),
            const SizedBox(height: 6),
            // butoane de edit/delete doar când e permis
            if (isEditable)
              OverflowBar(
                alignment: MainAxisAlignment.end,
                spacing: 8,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.gradient3),
                    onPressed: onDelete,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
