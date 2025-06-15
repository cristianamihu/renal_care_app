import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:renal_care_app/core/di/measurements_providers.dart';

class MeasurementReportTab extends ConsumerWidget {
  final String userId;
  final bool canDelete;

  const MeasurementReportTab({
    super.key,
    required this.userId,
    this.canDelete = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref
        .watch(measurementDocsForUserProvider(userId))
        .whenData(
          (all) => all.where((d) => d.reportType == 'measurements').toList(),
        );

    return docsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (e, _) => Center(
            child: Text(
              'Loading error: $e',
              style: const TextStyle(color: Colors.red),
            ),
          ),
      data: (docs) {
        if (docs.isEmpty) {
          return const Center(
            child: Text(
              'No measurements',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          separatorBuilder: (_, __) => const Divider(color: Colors.grey),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final d = docs[i];
            final date = DateFormat('dd MMM yyyy').format(d.addedAt);
            final time = DateFormat('HH:mm').format(d.addedAt);
            final w = (d.data['weight'] as num).toDouble();
            final h = (d.data['height'] as num).toDouble();
            final bmi = (d.data['bmi'] as num).toDouble();
            final gl = (d.data['glucose'] as num).toDouble();
            final sys = d.data['systolic'] as int;
            final dia = d.data['diastolic'] as int;
            final temp = (d.data['temperature'] as num).toDouble();
            final moment = d.data['moment'] as String;

            return ListTile(
              leading: const Icon(
                Icons.straighten,
                size: 40,
                color: Colors.white70,
              ),
              title: Text(
                moment,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '$date · $time',
                style: const TextStyle(color: Colors.grey),
              ),
              onTap:
                  () => showDialog(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: const Text('Measurement Details'),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Date: $date'),
                                Text('Time: $time'),
                                const SizedBox(height: 8),
                                Text('Weight: ${w.toStringAsFixed(1)} kg'),
                                Text('Height: ${h.toStringAsFixed(0)} cm'),
                                Text('BMI: ${bmi.toStringAsFixed(1)}'),
                                Text('Glucose: ${gl.toStringAsFixed(0)}'),
                                Text('Blood Pressure: $sys/$dia mmHg'),
                                Text(
                                  'Temperature: ${temp.toStringAsFixed(1)} °C',
                                ),
                              ],
                            ),
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
