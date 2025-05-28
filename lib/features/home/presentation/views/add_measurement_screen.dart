import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:renal_care_app/core/di/measurement_providers.dart';
import 'package:renal_care_app/core/theme/app_colors.dart';

import 'package:renal_care_app/features/home/domain/entities/measurement.dart';
import 'package:renal_care_app/features/home/presentation/widgets/blood_pressure_dialog.dart';
import 'package:renal_care_app/features/home/presentation/widgets/glucose_dialog.dart';
import 'package:renal_care_app/features/home/presentation/widgets/temperature_dialog.dart';
import 'package:renal_care_app/features/home/presentation/widgets/weight_height_dialog.dart';

enum MeasurementType { weightHeight, bloodPressure, glucose, temperature }

class AddMeasurementScreen extends ConsumerWidget {
  const AddMeasurementScreen({super.key});

  // date pentru listarea cardurilor
  List<_TypeData> get _types => [
    _TypeData(
      type: MeasurementType.weightHeight,
      title: 'Weight & Height',
      icon: Icons.monitor_weight,
    ),
    _TypeData(
      type: MeasurementType.bloodPressure,
      title: 'Blood Pressure',
      icon: Icons.favorite,
    ),
    _TypeData(
      type: MeasurementType.glucose,
      title: 'Glucose',
      icon: Icons.opacity,
    ),
    _TypeData(
      type: MeasurementType.temperature,
      title: 'Temperature',
      icon: Icons.thermostat,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(measurementViewModelProvider);
    final vm = ref.read(measurementViewModelProvider.notifier);

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
        title: const Text('Add Measurement'),
      ),

      body: Column(
        children: [
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Which measurement would you like to add?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _types.length,
              itemBuilder: (ctx, i) {
                final item = _types[i];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(item.icon, size: 28),
                    title: Text(
                      item.title,
                      style: const TextStyle(fontSize: 16),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      switch (item.type) {
                        case MeasurementType.weightHeight:
                          showDialog(
                            context: context,
                            builder:
                                (_) => WeightHeightDialog(
                                  onSave: (w, h, moment) {
                                    final double bmi =
                                        h > 0
                                            ? w / ((h / 100) * (h / 100))
                                            : 0.0;
                                    vm.saveMeasurement(
                                      Measurement(
                                        weight: w,
                                        height: h,
                                        bmi: bmi,
                                        glucose:
                                            state.measurement?.glucose ?? 0,
                                        systolic:
                                            state.measurement?.systolic ?? 0,
                                        diastolic:
                                            state.measurement?.diastolic ?? 0,
                                        temperature:
                                            state.measurement?.temperature ??
                                            0.0,
                                        date: DateTime.now(),
                                      ),
                                    );
                                  },
                                ),
                          );
                          break;

                        case MeasurementType.bloodPressure:
                          showDialog(
                            context: context,
                            builder:
                                (_) => BloodPressureDialog(
                                  onSave: (sys, dia, pulse, moment) {
                                    vm.saveMeasurement(
                                      Measurement(
                                        weight: state.measurement?.weight ?? 0,
                                        height: state.measurement?.height ?? 0,
                                        bmi: state.measurement?.bmi ?? 0,
                                        glucose:
                                            state.measurement?.glucose ?? 0,
                                        systolic: sys,
                                        diastolic: dia,
                                        temperature:
                                            state.measurement?.temperature ??
                                            0.0,
                                        date: DateTime.now(),
                                      ),
                                    );
                                  },
                                ),
                          );
                          break;

                        case MeasurementType.glucose:
                          showDialog(
                            context: context,
                            builder:
                                (_) => GlucoseDialog(
                                  onSave: (value, unit, moment) {
                                    final double glucoseValue =
                                        unit == GlucoseUnit.mmol
                                            ? value * 18.0
                                            : value;
                                    vm.saveMeasurement(
                                      Measurement(
                                        weight: state.measurement?.weight ?? 0,
                                        height: state.measurement?.height ?? 0,
                                        bmi: state.measurement?.bmi ?? 0,
                                        glucose: glucoseValue,
                                        systolic:
                                            state.measurement?.systolic ?? 0,
                                        diastolic:
                                            state.measurement?.diastolic ?? 0,
                                        temperature:
                                            state.measurement?.temperature ??
                                            0.0,
                                        date: DateTime.now(),
                                      ),
                                    );
                                  },
                                ),
                          );
                          break;

                        case MeasurementType.temperature:
                          showDialog(
                            context: context,
                            builder:
                                (_) => TemperatureDialog(
                                  onSave: (temp, moment) {
                                    // salvează temperatura printr-un alt use-case dacă vrei,
                                    // aici doar păstrăm măsurătorile generale
                                    vm.saveMeasurement(
                                      Measurement(
                                        weight: state.measurement?.weight ?? 0,
                                        height: state.measurement?.height ?? 0,
                                        bmi: state.measurement?.bmi ?? 0,
                                        glucose:
                                            state.measurement?.glucose ?? 0,
                                        systolic:
                                            state.measurement?.systolic ?? 0,
                                        diastolic:
                                            state.measurement?.diastolic ?? 0,
                                        temperature: temp,
                                        date: DateTime.now(),
                                      ),
                                    );
                                  },
                                ),
                          );
                          break;
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Helper pentru titlu și icon
class _TypeData {
  final MeasurementType type;
  final String title;
  final IconData icon;
  _TypeData({required this.type, required this.title, required this.icon});
}
