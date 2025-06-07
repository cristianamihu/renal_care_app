import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:renal_care_app/core/di/medication_provider.dart';
import 'package:renal_care_app/core/utils/notification_helper.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:renal_care_app/features/medications/domain/entities/medication.dart';
import 'package:renal_care_app/features/medications/domain/usecases/add_medication.dart';
import 'package:renal_care_app/features/medications/domain/usecases/delete_medication.dart';
import 'package:renal_care_app/features/medications/domain/usecases/get_all_medications.dart';
import 'package:renal_care_app/features/medications/domain/usecases/update_medication.dart';
import 'package:renal_care_app/features/medications/presentation/viewmodels/medication_state.dart';

/// Un StateNotifier care menține lista de medicamente, încărcare, eroare
class MedicationViewModel extends StateNotifier<MedicationState> {
  final Ref _ref;
  final GetAllMedications _getAllMedications;
  final AddMedication _addMedication;
  final UpdateMedication _updateMedication;
  final DeleteMedication _deleteMedication;
  static const int _horizonDays = 30;

  MedicationViewModel(
    this._ref,
    this._getAllMedications,
    this._addMedication,
    this._updateMedication,
    this._deleteMedication,
  ) : super(MedicationState(medications: [])) {
    _loadAll();
  }

  /// Încarcă toate medicamentele din Firestore și setează state.medications
  Future<void> _loadAll() async {
    try {
      state = state.copyWith(loading: true, error: null);
      final uid = _ref.read(authViewModelProvider).user!.uid;
      final meds = await _getAllMedications.call(uid);
      state = state.copyWith(medications: meds, loading: false);

      // După ce am obținut lista completă, reprogramez ALARMELE
      await _rescheduleAllAlarms();
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  /// Adaugă un medicament: scrie în Firestore, resetează lista și programează notificări
  Future<void> addNewMedication(Medication m) async {
    final uid = _ref.read(authViewModelProvider).user!.uid;

    // Scriem în Firestore
    await _addMedication.call(uid, m);

    // Re-încărcăm lista
    await _loadAll();
  }

  /// Actualizează un medicament: șterge vechile notificări și programează din nou
  Future<void> updateExistingMedication(Medication m) async {
    final uid = _ref.read(authViewModelProvider).user!.uid;

    // Scriem modificările în Firestore
    await _updateMedication.call(uid, m);

    _ref.invalidate(singleMedicationProvider(m.id));

    // Re-încărcăm lista
    await _loadAll();
  }

  /// Șterge un medicament: șterge din Firestore, cancel notificările
  Future<void> deleteMedicationById(String medId) async {
    final uid = _ref.read(authViewModelProvider).user!.uid;

    // Șterge din Firestore
    await _deleteMedication.call(uid, medId);

    // Re-încărcăm lista
    await _loadAll();
  }

  /// Anulează TOATE alarmele actuale și programăm din nou, GRUPAT pe fiecare oră.
  Future<void> _rescheduleAllAlarms() async {
    // Anulăm toate alarmele pe care le aveam
    await NotificationHelper.cancelAllAlarms();

    final allMeds = state.medications;
    if (allMeds.isEmpty) return;

    // Harta (DateTime → List<Medication>) pentru a grupa medicamentele care pică la aceeași dată+oră
    final Map<DateTime, List<Medication>> mapDateTimeToMeds = {};
    final DateTime now = DateTime.now();

    for (final med in allMeds) {
      if (!med.notificationsEnabled) continue;

      // 1) Obținem azi la miezul nopții (fără oră/minut/secundă)
      final DateTime todayMidnight = DateTime(now.year, now.month, now.day);

      // 2) Stabilim “prima zi validă” (doar data, fără oră):
      DateTime firstPossibleDay;
      final DateTime medStartDateOnly = DateTime(
        med.startDate.year,
        med.startDate.month,
        med.startDate.day,
      );

      if (medStartDateOnly.isAfter(todayMidnight)) {
        // dacă startDate e în viitor, folosim fix data aia
        firstPossibleDay = medStartDateOnly;
      } else {
        // altfel (startDate ≤ azi la 00:00), calculăm în continuare în funcție de frequency / specificWeekdays
        final int diffDays = todayMidnight.difference(medStartDateOnly).inDays;

        if (med.specificWeekdays.isEmpty) {
          // pași de frequency (1 zi, 2 zile etc.)
          final int r = diffDays % med.frequency;
          firstPossibleDay =
              (r == 0)
                  ? todayMidnight
                  : todayMidnight.add(Duration(days: med.frequency - r));
        } else {
          // există zile specifice ale săptămânii → începem de la azi
          firstPossibleDay = todayMidnight;
        }
      }

      // 3) Determinăm “ultima zi” până la care vrem să programăm (fără oră)
      DateTime lastDate;
      if (med.endDate != null) {
        lastDate = DateTime(
          med.endDate!.year,
          med.endDate!.month,
          med.endDate!.day,
        );
      } else {
        // Dacă nu are endDate, limităm la azi + _horizonDays
        lastDate = todayMidnight.add(const Duration(days: _horizonDays));
      }

      // 4) Dacă există zile specifice (specificWeekdays), iterăm zi de zi și verificăm weekday
      if (med.specificWeekdays.isNotEmpty) {
        DateTime candidate = firstPossibleDay;
        while (!candidate.isAfter(lastDate)) {
          if (med.specificWeekdays.contains(candidate.weekday)) {
            for (final dt in med.times) {
              final DateTime dateTimeForAlarm = DateTime(
                candidate.year,
                candidate.month,
                candidate.day,
                dt.hour,
                dt.minute,
              );
              if (dateTimeForAlarm.isAfter(now) ||
                  dateTimeForAlarm.isAtSameMomentAs(now)) {
                mapDateTimeToMeds
                    .putIfAbsent(dateTimeForAlarm, () => [])
                    .add(med);
              }
            }
          }
          candidate = candidate.add(const Duration(days: 1));
        }
      } else {
        // 5) Altfel (fără specificWeekdays), în funcție de frequency
        DateTime occurrenceDate = firstPossibleDay;
        while (!occurrenceDate.isAfter(lastDate)) {
          for (final dt in med.times) {
            final DateTime dateTimeForAlarm = DateTime(
              occurrenceDate.year,
              occurrenceDate.month,
              occurrenceDate.day,
              dt.hour,
              dt.minute,
            );
            if (dateTimeForAlarm.isAfter(now) ||
                dateTimeForAlarm.isAtSameMomentAs(now)) {
              mapDateTimeToMeds
                  .putIfAbsent(dateTimeForAlarm, () => [])
                  .add(med);
            }
          }
          occurrenceDate = occurrenceDate.add(Duration(days: med.frequency));
        }
      }
    }

    // 6) Sortăm toate DateTime-urile și programăm câte o notificare unică cu lista de medicamente
    final sortedDateTimes = mapDateTimeToMeds.keys.toList()..sort();

    for (final dateTimeKey in sortedDateTimes) {
      final medsAtThisDateTime = mapDateTimeToMeds[dateTimeKey]!;
      final String medsDescription = medsAtThisDateTime
          .map((m) => '${m.name} ${m.dose} ${m.unit}')
          .join('\n');

      // Generăm un notificationId pe baza hashCode-ului string-ului compus (data+ora)
      // Astfel evităm coliziuni cu hashCode-urile private
      final String composite =
          '${dateTimeKey.year}'
          '${dateTimeKey.month}'
          '${dateTimeKey.day}'
          '${dateTimeKey.hour}'
          '${dateTimeKey.minute}';
      final int notificationId = composite.hashCode;

      await NotificationHelper.scheduleExactAlarm(
        notificationId: notificationId,
        scheduledTime: dateTimeKey,
        medsDescription: medsDescription,
      );
    }
  }
}
