import 'package:renal_care_app/features/home/domain/entities/restricted_food.dart';
import 'package:renal_care_app/features/home/domain/repositories/restricted_food_repository.dart';

class GetRestrictedFoods {
  final RestrictedFoodRepository _repo;
  GetRestrictedFoods(this._repo);
  Future<List<RestrictedFood>> call() => _repo.getAll();
}
