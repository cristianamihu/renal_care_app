import 'package:renal_care_app/features/emergency/domain/entities/hospital.dart';

/// DTO pentru rezultatele API-ului Places (Nearby Search)
class HospitalModel {
  final String id;
  final String name;
  final String vicinity;
  final double lat;
  final double lng;

  HospitalModel({
    required this.id,
    required this.name,
    required this.vicinity,
    required this.lat,
    required this.lng,
  });

  /// Creează un HospitalModel din JSON-ul primit de la Google Places
  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    final location =
        (json['geometry']['location'] as Map).cast<String, dynamic>();
    return HospitalModel(
      id: json['place_id'] as String,
      name: json['name'] as String,
      vicinity: json['vicinity'] as String? ?? '',
      lat: (location['lat'] as num).toDouble(),
      lng: (location['lng'] as num).toDouble(),
    );
  }

  /// Convertește modelul într-o entitate de domain
  Hospital toEntity() {
    return Hospital(id: id, name: name, vicinity: vicinity, lat: lat, lng: lng);
  }
}
