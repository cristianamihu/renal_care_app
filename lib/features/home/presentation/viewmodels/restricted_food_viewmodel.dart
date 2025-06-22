import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diacritic/diacritic.dart';

import 'package:renal_care_app/core/di/measurements_providers.dart';
import 'package:renal_care_app/features/home/data/services/barcode_product_service.dart';
import 'package:renal_care_app/features/home/domain/usecases/get_restricted_foods.dart';
import 'package:renal_care_app/features/home/presentation/viewmodels/restricted_food_state.dart';

class RestrictedFoodViewModel extends StateNotifier<RestrictedFoodState> {
  final Ref _ref;
  final GetRestrictedFoods _getAll;
  final _barcodeService = BarcodeProductService();

  RestrictedFoodViewModel(this._ref, this._getAll)
    : super(RestrictedFoodState()) {
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

  /// Metodă publică pentru retry
  Future<void> reload() => _load();

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

  Future<void> scanBarcodeAndCheck(String code) async {
    state = state.copyWith(loading: true, resultMessage: null);
    try {
      final ingredients = await _barcodeService.fetchIngredients(code);

      if (ingredients.isEmpty) {
        // nu avem ingrediente → poate cod invalid sau produs necunoscut
        state = state.copyWith(
          loading: false,
          resultMessage: '❌ Could not fetch ingredients for this barcode.',
        );
        return;
      }

      // verifică listei de alimente restricționate
      final bads = <String>[];
      for (final f in state.all) {
        if (ingredients.any(
          (ing) => ing.toLowerCase().contains(f.name.toLowerCase()),
        )) {
          bads.add(f.name);
        }
      }

      // verifică alergiile utilizatorului (din MeasurementViewModel)
      final alergii = _ref
          .read(measurementViewModelProvider)
          .allergies
          .map((a) => a.name.toLowerCase());
      for (final alerg in alergii) {
        if (ingredients.any((ing) => ing.toLowerCase().contains(alerg))) {
          bads.add(alerg);
        }
      }

      final msg =
          bads.isEmpty
              ? '✅ The product is safe for you.'
              : '❌ Contain: ${bads.toSet().join(', ')}';

      state = state.copyWith(loading: false, resultMessage: msg);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  /// Resetează rezultatul (ex. când ctrl-ul text se golește)
  void clear() {
    state = state.copyWith(filtered: [], resultMessage: null, loading: false);
  }
}
