import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:renal_care_app/features/home/data/models/restricted_food_model.dart';

class RestrictedFoodRemoteService {
  final FirebaseFirestore _firestore;
  RestrictedFoodRemoteService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<RestrictedFoodModel>> fetchAll() async {
    final snap =
        await _firestore.collection('restricted_foods').orderBy('name').get();
    return snap.docs.map((d) => RestrictedFoodModel.fromDoc(d)).toList();
  }
}
