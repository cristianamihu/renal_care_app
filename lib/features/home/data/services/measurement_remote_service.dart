import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:renal_care_app/features/home/data/models/allergy_model.dart';

import 'package:renal_care_app/features/home/data/models/measurement_model.dart';
import 'package:renal_care_app/features/home/data/models/water_intake_model.dart';
import 'package:renal_care_app/features/home/data/models/sleep_record_model.dart';

class MeasurementRemoteService {
  final FirebaseFirestore _firestore;

  MeasurementRemoteService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<MeasurementModel?> fetchLatestMeasurement(String uid) async {
    final snap =
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('measurements')
            .orderBy('date', descending: true)
            .limit(1)
            .get();
    if (snap.docs.isEmpty) return null;
    return MeasurementModel.fromJson(snap.docs.first.data());
  }

  Future<void> updateMeasurement(String uid, MeasurementModel model) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('measurements')
        .doc(model.date.millisecondsSinceEpoch.toString())
        .set(model.toJson());
  }

  Future<WaterIntakeModel> fetchTodayWater(String uid) async {
    final todayKey = DateTime.now().toIso8601String().split('T').first;
    final doc =
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('water')
            .doc(todayKey)
            .get();
    if (!doc.exists) {
      return WaterIntakeModel(date: Timestamp.now(), glasses: 0);
    }
    return WaterIntakeModel.fromJson(doc.data()!);
  }

  Future<void> saveTodayWater(String uid, WaterIntakeModel model) async {
    final key = model.date.toDate().toIso8601String().split('T').first;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('water')
        .doc(key)
        .set(model.toJson());
  }

  Future<SleepRecordModel> fetchTodaySleep(String uid) async {
    final todayKey = DateTime.now().toIso8601String().split('T').first;
    final doc =
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('sleep')
            .doc(todayKey)
            .get();
    if (!doc.exists) {
      final nowTs = Timestamp.now();
      // pentru default, pornim și terminăm la momentul apelului
      return SleepRecordModel(date: nowTs, hours: 0, start: nowTs, end: nowTs);
    }
    return SleepRecordModel.fromJson(doc.data()!);
  }

  Future<void> saveTodaySleep(String uid, SleepRecordModel model) async {
    final key = model.date.toDate().toIso8601String().split('T').first;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('sleep')
        .doc(key)
        .set(model.toJson());
  }

  /// Stream de alergii ale user-ului
  Stream<List<AllergyModel>> watchAllergies(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('allergies')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(AllergyModel.fromDoc).toList());
  }

  /// Adaugă o alergie nouă în Firestore
  Future<void> addAllergy(String uid, String name) {
    final col = _firestore.collection('users').doc(uid).collection('allergies');
    return col.doc().set({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Şterge o alergie după ID
  Future<void> deleteAllergy(String uid, String allergyId) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('allergies')
        .doc(allergyId)
        .delete();
  }

  /// Fetch water history between două date
  Future<List<WaterIntakeModel>> fetchWaterHistory(
    String uid,
    DateTime from,
    DateTime to,
  ) async {
    final fromTs = Timestamp.fromDate(from);
    final toTs = Timestamp.fromDate(to);
    final snap =
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('water')
            .where('date', isGreaterThanOrEqualTo: fromTs)
            .where('date', isLessThanOrEqualTo: toTs)
            .get();
    return snap.docs.map((d) => WaterIntakeModel.fromJson(d.data())).toList();
  }

  /// Fetch sleep records between two dates (inclusive)
  Future<List<SleepRecordModel>> fetchSleepHistory(
    String uid,
    DateTime from,
    DateTime to,
  ) async {
    // we name docs by yyyy-MM-dd, so we can query by ID
    final fromKey = from.toIso8601String().split('T').first;
    final toKey = to.toIso8601String().split('T').first;
    final snap =
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('sleep')
            .where(FieldPath.documentId, isGreaterThanOrEqualTo: fromKey)
            .where(FieldPath.documentId, isLessThanOrEqualTo: toKey)
            .get();
    return snap.docs.map((d) => SleepRecordModel.fromJson(d.data())).toList();
  }
}
