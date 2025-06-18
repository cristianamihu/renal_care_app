import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedRestrictedFoods() async {
  final foods = <String>[
    'paste făinoase',
    'cartofi',
    'dulciuri',
    'mazăre',
    'fasole veche',
    'varză murată',
    'murături',
    'grapefruit',
    'ceai de sunătoare',
  ];

  final col = FirebaseFirestore.instance.collection('restricted_foods');
  for (final name in foods) {
    final existing = await col.where('name', isEqualTo: name).get();
    if (existing.docs.isEmpty) {
      await col.add({'name': name});
    }
  }
}
