import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:renal_care_app/features/auth/data/models/measurement_document_model.dart';
import 'package:renal_care_app/core/di/measurements_providers.dart';

class WaterReportTab extends ConsumerWidget {
  final String userId;
  final bool canDelete;

  const WaterReportTab({
    super.key,
    required this.userId,
    this.canDelete = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref
        .watch(measurementDocsForUserProvider(userId))
        .whenData((all) => all.where((d) => d.reportType == 'water').toList());

    return docsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (e, _) => Center(
            child: Text(
              'Loading error: $e',
              style: const TextStyle(color: Colors.red),
            ),
          ),
      data: (waterDocs) {
        if (waterDocs.isEmpty) {
          return const Center(
            child: Text(
              'No water records',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        // grupare pe zi
        final Map<String, List<MeasurementDocument>> byDay = {};
        for (var d in waterDocs) {
          final key = DateFormat('yyyy-MM-dd').format(d.addedAt);
          byDay.putIfAbsent(key, () => []).add(d);
        }
        final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          separatorBuilder: (_, __) => const Divider(color: Colors.grey),
          itemCount: days.length,
          itemBuilder: (_, idx) {
            final dayKey = days[idx];
            final entries = byDay[dayKey]!;
            final totalMl = entries.fold<int>(0, (acc, d) {
              if (d.data['ml'] != null) {
                return acc + (d.data['ml'] as num).toInt();
              }
              final g = d.data['glasses'] as int;
              final gs = ref.read(measurementViewModelProvider).glassSizeMl;
              return acc + g * gs;
            });
            final date = DateFormat(
              'dd MMM yyyy',
            ).format(DateTime.parse(dayKey));

            return ListTile(
              leading: const Icon(
                Icons.local_drink,
                size: 40,
                color: Colors.white70,
              ),
              title: Text(
                '$totalMl ml',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(date, style: const TextStyle(color: Colors.grey)),
              onTap:
                  () => showDialog(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: const Text('Detalii apă'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Data: $date'),
                              Text('Total: $totalMl ml'),
                              const SizedBox(height: 8),
                              const Text('Intrări:'),
                              ...entries.map((d) {
                                final t = DateFormat.Hm().format(d.addedAt);
                                final ml =
                                    d.data['ml'] ??
                                    (d.data['glasses'] as int) *
                                        ref
                                            .read(measurementViewModelProvider)
                                            .glassSizeMl;
                                return Text('- $ml ml la $t');
                              }),
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
                          final batch = FirebaseFirestore.instance.batch();
                          for (var d in entries) {
                            batch.delete(
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .collection('measurement_documents')
                                  .doc(d.id),
                            );
                          }
                          await batch.commit();
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
