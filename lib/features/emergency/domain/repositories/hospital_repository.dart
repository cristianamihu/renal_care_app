import 'package:renal_care_app/features/emergency/domain/entities/hospital.dart';

abstract class HospitalRepository {
  Future<List<Hospital>> fetchNearby(double lat, double lng);
}
