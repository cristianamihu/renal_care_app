import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget separat pentru afișarea conținutului unei note text.
class NoteViewer extends StatelessWidget {
  final String title;
  final String textContent;
  final DateTime addedAt;

  const NoteViewer({
    super.key,
    required this.title,
    required this.textContent,
    required this.addedAt,
  });

  @override
  Widget build(BuildContext context) {
    final dateString = DateFormat('dd MMM yyyy, HH:mm').format(addedAt);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateString, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  textContent,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
