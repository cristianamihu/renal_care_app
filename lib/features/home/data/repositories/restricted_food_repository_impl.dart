import 'package:renal_care_app/features/home/data/services/restricted_food_remote_service.dart';
import 'package:renal_care_app/features/home/domain/entities/restricted_food.dart';
import 'package:renal_care_app/features/home/domain/repositories/restricted_food_repository.dart';

class RestrictedFoodRepositoryImpl implements RestrictedFoodRepository {
  final RestrictedFoodRemoteService _remote;
  RestrictedFoodRepositoryImpl(this._remote);

  @override
  Future<List<RestrictedFood>> getAll() async {
    final models = await _remote.fetchAll();
    return models.map((m) => m.toEntity()).toList();
  }
}
