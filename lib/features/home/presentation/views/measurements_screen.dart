import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:renal_care_app/core/di/chat_providers.dart';

import 'package:renal_care_app/core/di/measurements_providers.dart';
import 'package:renal_care_app/core/theme/app_colors.dart';
import 'package:renal_care_app/features/home/presentation/views/add_measurement_screen.dart';
import 'package:renal_care_app/features/home/presentation/widgets/allergy_form.dart';
import 'package:renal_care_app/features/home/presentation/widgets/drink_water_info_dialog.dart';
import 'package:renal_care_app/features/home/presentation/widgets/sleep_time_dialog.dart';

class MeasurementsScreen extends ConsumerStatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  ConsumerState<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends ConsumerState<MeasurementsScreen> {
  DateTime? _lastBackPress;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(measurementViewModelProvider);
    final vm = ref.read(measurementViewModelProvider.notifier);
    // urmărește numărul de chat rooms cu mesaje necitite
    final unreadAsync = ref.watch(unreadChatRoomsCountProvider);

    if (state.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.error != null) {
      return Scaffold(body: Center(child: Text('Error: ${state.error}')));
    }

    // Handle back press for exiting the app
    return PopScope(
      canPop: false, // Prevent default pop
      onPopInvokedWithResult: (_, __) async {
        final now = DateTime.now();
        if (_lastBackPress == null ||
            now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
          _lastBackPress = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press again to exit the application.'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // Exit the app on second back press
          SystemNavigator.pop();
        }
      },
      child: MediaQuery.removeViewInsets(
        context: context,
        removeTop: false,
        removeBottom: false,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
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
            title: const Text(
              'RenalCare',
              style: TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              // butonul de chat
              unreadAsync.when(
                data: (count) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline),
                          tooltip: 'Chat',
                          onPressed: () => context.go('/chat'),
                        ),
                        if (count > 0)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: AppColors.gradient2,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '$count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
                loading:
                    () => IconButton(
                      icon: const Icon(Icons.chat_bubble_outline),
                      tooltip: 'Chat',
                      onPressed: () => context.go('/chat'),
                    ),
                error:
                    (_, __) => IconButton(
                      icon: const Icon(Icons.chat_bubble_outline),
                      tooltip: 'Chat',
                      onPressed: () => context.go('/chat'),
                    ),
              ),
            ],
          ),

          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Emergency button in body
                Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.7,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(double.infinity, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => context.go('/emergency'),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 25,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Tap in Case of Emergency',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // General Measurements Card
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AddMeasurementScreen(),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.monitor_weight,
                            size: 48,
                            color: AppColors.gradient3,
                          ),
                          const SizedBox(height: 8),

                          const Text(
                            'General Measurements',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),

                          Text(
                            state.measurement != null
                                ? '${state.measurement!.moment}\n'
                                    'BMI: ${state.measurement!.bmi.toStringAsFixed(1)}\n'
                                    'Weight: ${state.measurement!.weight}kg, '
                                    'Height: ${state.measurement!.height}cm\n'
                                    'Glucose: ${state.measurement!.glucose}, '
                                    'Blood Preasure: ${state.measurement!.systolic}/${state.measurement!.diastolic}\n'
                                    'Temperature: ${state.measurement!.temperature.toStringAsFixed(1)}°C'
                                : 'Tap to enter',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Water Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [AppColors.gradient2, AppColors.gradient3],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(24),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Daily goal: ${state.waterGoalMl} ml',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(
                              Icons.info_outline,
                              size: 20,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => const DrinkWaterInfoDialog(),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Center(
                        child: Text(
                          '${state.water.glasses * state.glassSizeMl} ml',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Center(
                        child: Material(
                          color: Colors.transparent, // fundal transparent
                          child: InkWell(
                            borderRadius: BorderRadius.circular(9),
                            highlightColor: Colors.white.withValues(
                              alpha: 0.3,
                            ), // chenar semi-transparent la apăsat
                            splashColor: Colors.white.withValues(
                              alpha: 0.2,
                            ), // cercul de ripple
                            onTap: vm.addGlass,
                            child: SizedBox(
                              width: 56,
                              height: 56,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Semnul „+”
                                  const Icon(
                                    Icons.add_outlined,
                                    size: 30,
                                    color: Colors.white,
                                  ),

                                  // Paharul
                                  Icon(
                                    Icons.free_breakfast_outlined,
                                    size: 65,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Add a glass (${state.glassSizeMl} ml)',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton.icon(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: const Text(
                            'Change goal / glass size',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed:
                              () =>
                                  _showWaterSettingsDialog(context, state, vm),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Boton căutare alimente interzise
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gradient3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 6,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      icon: const Icon(Icons.restaurant, color: Colors.white),
                      label: const Text(
                        'Check restricted foods',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      onPressed: () {
                        // dacă folosești go_router:
                        context.go('/restricted-foods');

                        // altfel, cu Navigator:
                        // Navigator.of(context).push(
                        //   MaterialPageRoute(builder: (_) => const RestrictedFoodSearchScreen()),
                        // );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Allergy Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: ListTile(
                    leading: const Icon(Icons.warning, color: Colors.redAccent),
                    title: const Text('Allergies'),
                    subtitle:
                        state.allergies.isEmpty
                            ? const Text(
                              'None added',
                              style: TextStyle(color: Colors.grey),
                            )
                            : Wrap(
                              spacing: 8,
                              children:
                                  state.allergies.map((a) {
                                    return Chip(
                                      label: Text(a.name),
                                      onDeleted: () => vm.deleteAllergy(a.id),
                                    );
                                  }).toList(),
                            ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (ctx) => AlertDialog(
                              content: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: AllergyForm(vm: vm),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Sleep Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final times = await showDialog<TimeRange>(
                        context: context,
                        builder:
                            (_) => SleepTimeDialog(
                              initialStart: state.sleepStart,
                              initialEnd: state.sleepEnd,
                            ),
                      );
                      if (times != null) {
                        final diff = times.end.difference(times.start);
                        final hours =
                            diff.inHours + (diff.inMinutes % 60) / 60.0;
                        vm.setSleepTimes(times.start, times.end, hours);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 16,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.bedtime,
                                size: 32,
                                color: AppColors.gradient3,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child:
                                    state.sleep.hours > 0
                                        // dacă am introdus ore de somn
                                        ? Text(
                                          '${_formatTime(state.sleepStart!)} - ${_formatTime(state.sleepEnd!)}',
                                          style: const TextStyle(fontSize: 16),
                                        )
                                        // placeholder cu blank-uri
                                        : const Text(
                                          '__:__ - __:__',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                            fontFamily:
                                                'monospace', // ca să arate aliniat
                                          ),
                                        ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              state.sleep.hours > 0
                                  ? '${state.sleep.hours.floor()} h ${((state.sleep.hours % 1) * 60).round()} m'
                                  : '0 h 0 m',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  void _showWaterSettingsDialog(
    BuildContext context,
    dynamic state,
    dynamic vm,
  ) {
    int goal = state.waterGoalMl;
    int glass = state.glassSizeMl;

    showDialog<void>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Water Settings'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: goal.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Daily goal (ml)',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => goal = int.tryParse(v) ?? goal,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: glass.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Glass size (ml)',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => glass = int.tryParse(v) ?? glass,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  vm.updateWaterSettings(goal, glass);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }
}
