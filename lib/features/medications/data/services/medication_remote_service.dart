import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:renal_care_app/features/medications/data/models/medication_model.dart';

class MedicationRemoteService {
  final FirebaseFirestore _firestore;

  MedicationRemoteService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Returnează lista de modele din colecția /users/{uid}/medications, ordonat după createdAt desc
  Future<List<MedicationModel>> fetchAll(String uid) async {
    final querySnap =
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('medications')
            .orderBy('createdAt', descending: true)
            .get();

    return querySnap.docs
        .map((doc) => MedicationModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  /// Adaugă un medicament nou; if med.id == '', atunci generăm doc id nou
  Future<void> add(String uid, MedicationModel model) async {
    final medsCol = _firestore
        .collection('users')
        .doc(uid)
        .collection('medications');
    if (model.id.isEmpty) {
      // Generăm un doc nou
      final newDocRef = medsCol.doc();
      final now = Timestamp.now();
      final newModel = MedicationModel(
        id: newDocRef.id,
        name: model.name,
        dose: model.dose,
        unit: model.unit,
        startDate: model.startDate,
        endDate: model.endDate,
        frequency: model.frequency,
        times: model.times,
        notificationsEnabled: model.notificationsEnabled,
        createdAt: now,
        updatedAt: now,
        specificWeekdays: model.specificWeekdays,
      );
      await newDocRef.set(newModel.toJson());
    } else {
      // Dacă id există, facem override complet (poate vrem să păstrăm createdAt, updatedAt)
      final now = Timestamp.now();
      final updatedMap = model.toJson()..['updatedAt'] = now;
      await medsCol.doc(model.id).set(updatedMap, SetOptions(merge: true));
    }
  }

  /// Actualizează un medicament existent
  Future<void> update(String uid, MedicationModel model) async {
    final medsCol = _firestore
        .collection('users')
        .doc(uid)
        .collection('medications');
    final now = Timestamp.now();
    final updatedMap = model.toJson()..['updatedAt'] = now;
    await medsCol.doc(model.id).update(updatedMap);
  }

  /// Șterge un medicament
  Future<void> delete(String uid, String medicationId) async {
    final medsCol = _firestore
        .collection('users')
        .doc(uid)
        .collection('medications');
    await medsCol.doc(medicationId).delete();
  }
}
