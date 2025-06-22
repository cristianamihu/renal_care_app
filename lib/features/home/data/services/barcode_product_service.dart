import 'dart:convert';

import 'package:http/http.dart' as http;

class BarcodeProductService {
  Future<List<String>> fetchIngredients(String barcode) async {
    final resp = await http.get(
      Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json'),
    );

    if (resp.statusCode != 200) {
      throw Exception('Network error: ${resp.statusCode}');
    }

    final Map<String, dynamic> body = jsonDecode(resp.body);
    final Map<String, dynamic>? product =
        body['product'] as Map<String, dynamic>?;

    if (product == null) {
      // produsul nu există în baza de date
      return [];
    }

    // încearcă lista standard de ingrediente
    final List<dynamic>? rawList = product['ingredients'] as List<dynamic>?;
    if (rawList != null && rawList.isNotEmpty) {
      return rawList
          .whereType<Map<String, dynamic>>()
          .map((e) => e['text'] as String? ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }

    // fallback pe câmpuri text (în engleză/română/orice limbă)
    final String? textRo = product['ingredients_text_ro'] as String?;
    final String? textEn = product['ingredients_text_en'] as String?;
    final String? textAny = product['ingredients_text'] as String?;
    final String? fallback = textRo ?? textEn ?? textAny;

    if (fallback != null && fallback.trim().isNotEmpty) {
      return fallback
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return []; // dacă tot nu găsim nimic
  }
}
