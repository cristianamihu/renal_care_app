import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:renal_care_app/core/di/measurements_providers.dart';

class SleepReportTab extends ConsumerWidget {
  final String userId;
  final bool canDelete;

  const SleepReportTab({
    super.key,
    required this.userId,
    this.canDelete = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref
        .watch(measurementDocsForUserProvider(userId))
        .whenData((all) => all.where((d) => d.reportType == 'sleep').toList());

    return docsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (e, _) => Center(
            child: Text(
              'Loading error: $e',
              style: const TextStyle(color: Colors.red),
            ),
          ),
      data: (sleepDocs) {
        if (sleepDocs.isEmpty) {
          return const Center(
            child: Text(
              'No sleep records',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          separatorBuilder: (_, __) => const Divider(color: Colors.grey),
          itemCount: sleepDocs.length,
          itemBuilder: (_, i) {
            final d = sleepDocs[i];
            final start = (d.data['start'] as Timestamp).toDate();
            final end = (d.data['end'] as Timestamp).toDate();
            final dur = end.difference(start);
            final h = dur.inHours;
            final m = dur.inMinutes % 60;

            final date = DateFormat('dd MMM yyyy').format(start);
            final sStr = DateFormat.Hm().format(start);
            final eStr = DateFormat.Hm().format(end);

            return ListTile(
              leading: const Icon(
                Icons.bedtime,
                size: 40,
                color: Colors.white70,
              ),
              title: Text(
                date,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '$h h $m m  ·  $sStr - $eStr',
                style: const TextStyle(color: Colors.grey),
              ),
              onTap:
                  () => showDialog(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: const Text('Sleep Details'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date: $date'),
                              Text('Duration: $h h $m m'),
                              Text('Bed time: $sStr'),
                              Text('Wake time: $eStr'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Închide'),
                            ),
                          ],
                        ),
                  ),
              trailing:
                  canDelete
                      ? IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .collection('measurement_documents')
                              .doc(d.id)
                              .delete();
                        },
                      )
                      : null,
            );
          },
        );
      },
    );
  }
}
