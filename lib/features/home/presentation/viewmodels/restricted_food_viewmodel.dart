import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diacritic/diacritic.dart';

import 'package:renal_care_app/features/home/domain/usecases/get_restricted_foods.dart';
import 'package:renal_care_app/features/home/presentation/viewmodels/restricted_food_state.dart';

class RestrictedFoodViewModel extends StateNotifier<RestrictedFoodState> {
  final GetRestrictedFoods _getAll;

  RestrictedFoodViewModel(this._getAll) : super(RestrictedFoodState()) {
    _load();
  }

  Future<void> _load() async {
    try {
      state = state.copyWith(loading: true, error: null, resultMessage: null);
      final list = await _getAll();
      state = state.copyWith(all: list, filtered: [], loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  /// Caută în "all", apoi setează "filtered" și "resultMessage"
  Future<void> search(String query) async {
    if (query.trim().isEmpty) return clear();
    state = state.copyWith(loading: true, resultMessage: null);

    // normalizează query
    final rawQ = query.toLowerCase().trim();
    final normQ = removeDiacritics(rawQ);
    final singQ =
        normQ.endsWith('i') ? normQ.substring(0, normQ.length - 1) : normQ;

    // filtrează
    final matches =
        state.all.where((f) {
          final rawName = f.name.toLowerCase();
          final normName = removeDiacritics(rawName);
          final singName =
              normName.endsWith('i')
                  ? normName.substring(0, normName.length - 1)
                  : normName;

          // match diacritic-insensibil sau singular/plural
          return normName.contains(normQ) || singName.contains(singQ);
        }).toList();

    // verifică exact match (tot normalizat)
    final isExact = state.all.any((f) {
      final rawName = f.name.toLowerCase();
      final normName = removeDiacritics(rawName);
      final singName =
          normName.endsWith('i')
              ? normName.substring(0, normName.length - 1)
              : normName;

      return normName == normQ || singName == singQ;
    });

    // mesaj în funcție de rezultat
    final resultMsg =
        isExact
            ? '❌ You are not allowed to eat this food.'
            : '✅ It is safe to consume this food.';

    // actualizăm state-ul
    state = state.copyWith(
      filtered: matches,
      loading: false,
      resultMessage: resultMsg,
    );
  }

  /// Resetează rezultatul (ex. când ctrl-ul text se golește)
  void clear() {
    state = state.copyWith(filtered: [], resultMessage: null, loading: false);
  }
}
