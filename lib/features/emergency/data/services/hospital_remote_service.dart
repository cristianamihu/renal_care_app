import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:renal_care_app/features/emergency/data/models/hospital_model.dart';

class HospitalRemoteService {
  // Cheia Google Places
  static const _googleApiKey = 'AIzaSyC5P7W7EMfx3O0axZaECuYZBkrNCIuqFMw';

  /// fetch paginat spitale (20 rezultate/page, token-ul devine activ după ~0s)
  /// Primește coordonatele și returnează lista de modele
  Future<List<HospitalModel>> fetch(double lat, double lng) async {
    List<HospitalModel> all = [];
    String? nextPage;

    do {
      final params = {
        'location': '$lat,$lng',
        'radius': '15000',
        'type': 'hospital',
        'key': _googleApiKey,
        if (nextPage != null) 'pagetoken': nextPage,
      };
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/nearbysearch/json',
        params,
      );
      final res = await http.get(uri);
      if (res.statusCode != 200) break;

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final results = body['results'] as List<dynamic>? ?? [];
      all.addAll(
        results.map((j) => HospitalModel.fromJson(j as Map<String, dynamic>)),
      );

      nextPage = body['next_page_token'] as String?;
      if (nextPage != null) await Future.delayed(const Duration(seconds: 0));
    } while (nextPage != null);

    return all;
  }
}
