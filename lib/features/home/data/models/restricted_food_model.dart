import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:renal_care_app/features/home/domain/entities/restricted_food.dart';

class RestrictedFoodModel {
  final String id;
  final String name;
  final String category;
  final String note;

  RestrictedFoodModel({
    required this.id,
    required this.name,
    required this.category,
    required this.note,
  });

  factory RestrictedFoodModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data()!;
    return RestrictedFoodModel(
      id: doc.id,
      name: d['name'] as String,
      category: d['category'] as String? ?? '',
      note: d['note'] as String? ?? '',
    );
  }

  RestrictedFood toEntity() =>
      RestrictedFood(id: id, name: name, category: category, note: note);
}
