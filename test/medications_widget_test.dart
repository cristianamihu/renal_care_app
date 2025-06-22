import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:renal_care_app/features/medications/domain/entities/medication.dart';
import 'package:renal_care_app/features/medications/presentation/viewmodels/medication_state.dart';
import 'package:renal_care_app/features/medications/presentation/viewmodels/medication_viewmodel.dart';
import 'package:renal_care_app/features/medications/presentation/views/medications_screen.dart';
import 'package:renal_care_app/features/medications/presentation/views/add_edit_medication_screen.dart';
import 'package:renal_care_app/features/medications/presentation/widgets/frequency_piker.dart';
import 'package:renal_care_app/features/medications/presentation/widgets/medication_tile.dart';
import 'package:renal_care_app/core/di/medication_provider.dart';

/// Fake simplu care nu face nimic, doar ține un `state`
class FakeMedicationVm extends StateNotifier<MedicationState>
    implements MedicationViewModel {
  FakeMedicationVm(super.state);

  @override
  Future<void> addNewMedication(Medication m) async {}

  @override
  Future<void> updateExistingMedication(Medication m) async {}

  @override
  Future<void> deleteMedicationById(String medId) async {}
}

void main() {
  group('MedicationsScreen', () {
    testWidgets('- loading: afișează indicator de încărcare', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // override cu FakeMedicationVm prin overrideWith
            medicationViewModelProvider.overrideWith(
              (ref) => FakeMedicationVm(
                MedicationState(medications: [], loading: true),
              ),
            ),
          ],
          child: MaterialApp(home: const MedicationsScreen()),
        ),
      );

      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('- empty: afișează placeholder când nu sunt doze', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            medicationViewModelProvider.overrideWith(
              (ref) => FakeMedicationVm(
                MedicationState(medications: [], loading: false),
              ),
            ),
          ],
          child: MaterialApp(home: const MedicationsScreen()),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text("No doses scheduled this day."), findsOneWidget);
      expect(find.byIcon(Icons.medication_outlined), findsOneWidget);
    });

    testWidgets('- with data: afișează cel puțin un MedicationTile', (
      tester,
    ) async {
      final now = DateTime(2023, 1, 1, 8, 0);
      final med = Medication(
        id: 'm1',
        name: 'Paracetamol',
        dose: 500,
        unit: 'mg',
        startDate: now,
        endDate: null,
        frequency: 1,
        times: [now],
        notificationsEnabled: true,
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            medicationViewModelProvider.overrideWith(
              (ref) => FakeMedicationVm(
                MedicationState(medications: [med], loading: false),
              ),
            ),
          ],
          child: MaterialApp(home: const MedicationsScreen()),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(MedicationTile), findsWidgets);
      expect(find.text('Paracetamol'), findsOneWidget);
    });
  });

  group('AddEditMedicationScreen', () {
    testWidgets('- ADD mode: câmpuri goale și buton ADD', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const AddEditMedicationScreen(),
            routes: {'/medications': (_) => const SizedBox()},
            navigatorKey: GlobalKey<NavigatorState>(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Add Medication'), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, 'Medication name'),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextFormField, 'Take'), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, 'Unit (e.g. pill, mg, ml)'),
        findsOneWidget,
      );
      expect(find.byType(FrequencyPicker), findsOneWidget);
      expect(find.text('ADD'), findsOneWidget);
    });

    testWidgets('- EDIT mode: pre-populare câmpuri și buton SAVE', (
      tester,
    ) async {
      final now = DateTime(2023, 1, 1, 8, 0);
      final initial = Medication(
        id: 'x',
        name: 'Ibuprofen',
        dose: 200,
        unit: 'mg',
        startDate: now,
        endDate: now,
        frequency: 2,
        times: [now],
        notificationsEnabled: true,
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: AddEditMedicationScreen(initialMedication: initial),
            routes: {'/medications': (_) => const SizedBox()},
            navigatorKey: GlobalKey<NavigatorState>(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Edit Medication'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Ibuprofen'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '200.0'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'mg'), findsOneWidget);
      expect(find.text('SAVE'), findsOneWidget);
    });
  });

  group('FrequencyPicker', () {
    testWidgets('- afișează & schimbă frecvența corect', (tester) async {
      FrequencyOption chosen = FrequencyOption.everyDay;

      // Împachetăm într-o MaterialApp + Scaffold pentru ListTile
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FrequencyPicker(
              initialOption: FrequencyOption.everyXDays,
              initialEveryXDays: 3,
              initialSelectedWeekdays: const [],
              onFrequencyChanged: (opt, _, __) {
                chosen = opt;
              },
            ),
          ),
        ),
      );

      // Primul build
      await tester.pumpAndSettle();

      // Verificăm subtitlul inițial
      expect(find.text('Every 3 days'), findsOneWidget);

      // Deschidem dialogul
      await tester.tap(find.byType(FrequencyPicker));
      await tester.pumpAndSettle();

      // Alegem "Every day" și confirmăm
      await tester.tap(find.text('Every day').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Verificăm că callback-ul ne-a dat frecvența corectă
      expect(chosen, FrequencyOption.everyDay);
    });
  });
}
