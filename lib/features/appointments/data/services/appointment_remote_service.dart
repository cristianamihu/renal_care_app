import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:renal_care_app/features/appointments/data/models/appointment_model.dart';

class AppointmentRemoteService {
  final FirebaseFirestore _firestore;
  AppointmentRemoteService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<AppointmentModel>> fetchUpcoming(String userId) async {
    final now = DateTime.now();
    final snap =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('appointments')
            .where('dateTime', isGreaterThan: Timestamp.fromDate(now))
            .orderBy('dateTime')
            .get();

    return snap.docs
        .map((d) => AppointmentModel.fromJson(d.data(), d.id))
        .toList();
  }

  Future<void> create(AppointmentModel model, String patientId) async {
    final batch = _firestore.batch();

    // scriem în colecția pacientului
    final patientRef = _firestore
        .collection('users')
        .doc(patientId)
        .collection('appointments')
        .doc(model.id);
    batch.set(patientRef, model.toJson());

    // construim cheile pentru zi și slot
    final dt = model.dateTime.toDate();
    final dayKey = DateFormat('yyyy-MM-dd').format(dt);
    final slotKey = DateFormat('HH:mm').format(dt);

    // scriem slot-ul în colecția doctorului
    final slotRef = _firestore
        .collection('users')
        .doc(model.doctorId)
        .collection('appointments_by_day')
        .doc(dayKey)
        .collection('slots')
        .doc(slotKey);

    batch.set(slotRef, {
      'appointmentId': model.id,
      'patientId': patientId,
      'doctorId': model.doctorId,
      'dateTime': model.dateTime,
      'description': model.description,
      'doctorAddress': model.doctorAddress,
    });

    // commit
    await batch.commit();
  }

  Future<void> update(AppointmentModel model, String patientId) async {
    // preluăm vechiul doc
    final docRef = _firestore
        .collection('users')
        .doc(patientId)
        .collection('appointments')
        .doc(model.id);
    final oldSnap = await docRef.get();
    if (!oldSnap.exists) throw Exception('Appointment not found');

    final oldData = oldSnap.data()!;
    final oldDoctorId = oldData['doctorId'] as String;
    final oldDateTime = (oldData['dateTime'] as Timestamp).toDate();
    final oldDayKey = DateFormat('yyyy-MM-dd').format(oldDateTime);
    final oldSlotKey = DateFormat('HH:mm').format(oldDateTime);

    // calculăm cheile noi
    final newDt = model.dateTime.toDate();
    final newDayKey = DateFormat('yyyy-MM-dd').format(newDt);
    final newSlotKey = DateFormat('HH:mm').format(newDt);

    final batch = _firestore.batch();

    // actualizăm programarea pacientului
    batch.update(docRef, model.toJson());

    // ştergem slot-ul vechi (numai dacă doctorul sau ziua/ora s-a schimbat)
    if (oldDoctorId != model.doctorId ||
        oldDayKey != newDayKey ||
        oldSlotKey != newSlotKey) {
      final oldSlotRef = _firestore
          .collection('users')
          .doc(oldDoctorId)
          .collection('appointments_by_day')
          .doc(oldDayKey)
          .collection('slots')
          .doc(oldSlotKey);
      batch.delete(oldSlotRef);

      // setăm slot-ul nou
      final newSlotRef = _firestore
          .collection('users')
          .doc(model.doctorId)
          .collection('appointments_by_day')
          .doc(newDayKey)
          .collection('slots')
          .doc(newSlotKey);

      batch.set(newSlotRef, {
        'appointmentId': model.id,
        'patientId': patientId,
        'doctorId': model.doctorId,
        'dateTime': model.dateTime,
        'description': model.description,
        'doctorAddress': model.doctorAddress,
      });
    }

    await batch.commit();
  }

  Future<void> delete(String appointmentId, String patientId) async {
    // mai întâi încărcăm documentul ca să aflăm doctorId și dateTime
    final doc =
        await _firestore
            .collection('users')
            .doc(patientId)
            .collection('appointments')
            .doc(appointmentId)
            .get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final doctorId = data['doctorId'] as String;
    final dateTime = data['dateTime'] as Timestamp;
    final dt = dateTime.toDate();
    final dayKey = DateFormat('yyyy-MM-dd').format(dt);
    final slotKey = DateFormat('HH:mm').format(dt);

    final batch = _firestore.batch();

    // ștergem din colecția pacientului
    final patientRef = _firestore
        .collection('users')
        .doc(patientId)
        .collection('appointments')
        .doc(appointmentId);
    batch.delete(patientRef);

    // ștergem slot-ul din colecția doctorului
    final slotRef = _firestore
        .collection('users')
        .doc(doctorId)
        .collection('appointments_by_day')
        .doc(dayKey)
        .collection('slots')
        .doc(slotKey);
    batch.delete(slotRef);

    await batch.commit();
  }

  /// Aduce direct lista de modele pentru un doctor într-o zi.
  Future<List<AppointmentModel>> fetchByDoctor(
    String doctorId,
    String dayKey,
  ) async {
    // Ia toate slot‐urile pentru ziua respectivă
    final slotsSnap =
        await _firestore
            .collection('users')
            .doc(doctorId)
            .collection('appointments_by_day')
            .doc(dayKey)
            .collection('slots')
            .orderBy(FieldPath.documentId)
            .get();

    // Obţii listele de Future<DocumentSnapshot> (în paralel, nu secvenţial)
    return slotsSnap.docs.map((doc) {
      final data = doc.data();
      return AppointmentModel(
        id: data['appointmentId'] as String,
        patientId: data['patientId'] as String,
        dateTime: data['dateTime'] as Timestamp,
        doctorId: doctorId,
        description: data['description'] as String? ?? '',
        doctorAddress: data['doctorAddress'] as String? ?? '',
      );
    }).toList();
  }

  /// Returnează orele deja ocupate (HH:mm) pentru doctorul dat, într-o anumită zi (yyyy-MM-dd)
  Future<List<String>> fetchSlotsForDoctor(
    String doctorId,
    String dayKey,
  ) async {
    final snap =
        await _firestore
            .collection('users')
            .doc(doctorId)
            .collection('appointments_by_day')
            .doc(dayKey)
            .collection('slots')
            .orderBy(FieldPath.documentId)
            .get();
    return snap.docs.map((d) => d.id).toList();
  }
}
