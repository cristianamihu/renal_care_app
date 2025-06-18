import 'package:renal_care_app/features/home/domain/entities/restricted_food.dart';

class RestrictedFoodState {
  final List<RestrictedFood> all;
  final List<RestrictedFood> filtered;
  final bool loading;
  final String? resultMessage;
  final String? error;

  RestrictedFoodState({
    this.all = const [],
    this.filtered = const [],
    this.loading = false,
    this.resultMessage,
    this.error,
  });

  RestrictedFoodState copyWith({
    List<RestrictedFood>? all,
    List<RestrictedFood>? filtered,
    bool? loading,
    String? resultMessage,
    String? error,
  }) => RestrictedFoodState(
    all: all ?? this.all,
    filtered: filtered ?? this.filtered,
    loading: loading ?? this.loading,
    resultMessage: resultMessage,
    error: error,
  );
}
