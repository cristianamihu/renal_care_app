import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:renal_care_app/features/home/domain/entities/allergy.dart';

class AllergyModel {
  final String id;
  final String name;
  final Timestamp createdAt;
  AllergyModel({required this.id, required this.name, required this.createdAt});

  factory AllergyModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return AllergyModel(
      id: doc.id,
      name: d['name'] as String,
      createdAt: d['createdAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'createdAt': createdAt};

  Allergy toEntity() =>
      Allergy(id: id, name: name, createdAt: createdAt.toDate());
}
