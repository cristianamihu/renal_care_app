import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:renal_care_app/core/theme/app_colors.dart';
import 'package:renal_care_app/features/journal/domain/entities/journal_entry.dart';

class JournalEntryDetailScreen extends StatelessWidget {
  final JournalEntry entry;

  const JournalEntryDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final dateString = DateFormat(
      'dd MMM yyyy, HH:mm',
      'ro',
    ).format(entry.timestamp);

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
        title: const Text('Note Details'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label-ul și timestamp-ul în partea de sus
            Row(
              children: [
                // Poți prelua colorForLabel din AddJournalEntryScreen
                CircleAvatar(
                  radius: 6,
                  backgroundColor: colorForLabel(entry.label),
                ),
                const SizedBox(width: 8),
                Text(
                  entry.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(dateString, style: TextStyle(color: Colors.grey[600])),
              ],
            ),

            const SizedBox(height: 24),

            // Textul notei, scrollabil dacă e mai lung
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  entry.text,
                  style: const TextStyle(fontSize: 16, height: 1.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Copiază funcția de la AddJournalEntryScreen:
  Color colorForLabel(String label) {
    switch (label) {
      case 'Emergency':
        return Colors.pink;
      case 'General':
      default:
        return Colors.blue;
    }
  }
}
