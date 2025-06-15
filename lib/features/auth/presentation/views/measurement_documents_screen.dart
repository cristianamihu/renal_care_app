import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:renal_care_app/core/di/measurements_providers.dart';

import 'package:renal_care_app/core/theme/app_colors.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:renal_care_app/features/auth/presentation/widgets/measurement_report_tab.dart';
import 'package:renal_care_app/features/auth/presentation/widgets/sleep_report_tab.dart';
import 'package:renal_care_app/features/auth/presentation/widgets/water_report_tab.dart';

class MeasurementDocumentsScreen extends ConsumerWidget {
  final String? userId;
  final bool canDelete;

  const MeasurementDocumentsScreen({
    super.key,
    this.userId,
    this.canDelete = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = userId ?? ref.read(authViewModelProvider).user!.uid;
    final docsAsync = ref.watch(measurementDocsForUserProvider(uid));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
          title: const Text('Measurements Reports'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Measurements', icon: Icon(Icons.straighten)),
              Tab(text: 'Water', icon: Icon(Icons.local_drink)),
              Tab(text: 'Sleep', icon: Icon(Icons.bedtime)),
            ],
          ),
        ),

        body: docsAsync.when(
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
                  'There are no measurements reports...',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return TabBarView(
              children: [
                MeasurementReportTab(userId: uid, canDelete: canDelete),
                WaterReportTab(userId: uid, canDelete: canDelete),
                SleepReportTab(userId: uid, canDelete: canDelete),
              ],
            );
          },
        ),
      ),
    );
  }
}
