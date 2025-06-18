import 'package:renal_care_app/features/home/domain/entities/restricted_food.dart';

abstract class RestrictedFoodRepository {
  Future<List<RestrictedFood>> getAll();
}
