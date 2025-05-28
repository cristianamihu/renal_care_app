import 'package:renal_care_app/features/emergency/domain/entities/hospital.dart';
import 'package:renal_care_app/features/emergency/domain/repositories/hospital_repository.dart';

class GetNearbyHospitals {
  final HospitalRepository _repo;
  GetNearbyHospitals(this._repo);
  Future<List<Hospital>> call(double lat, double lng) =>
      _repo.fetchNearby(lat, lng);
}
