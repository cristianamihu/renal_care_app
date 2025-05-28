import 'package:renal_care_app/features/emergency/data/services/hospital_remote_service.dart';
import 'package:renal_care_app/features/emergency/domain/entities/hospital.dart';
import 'package:renal_care_app/features/emergency/domain/repositories/hospital_repository.dart';

class HospitalRepositoryImpl implements HospitalRepository {
  final HospitalRemoteService _remote;
  HospitalRepositoryImpl(this._remote);

  @override
  Future<List<Hospital>> fetchNearby(double lat, double lng) async {
    final models = await _remote.fetch(lat, lng);
    return models.map((m) => m.toEntity()).toList();
  }
}
