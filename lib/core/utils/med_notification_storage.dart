import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MedNotificationStorage {
  static const _prefsKey = 'medNotificationIdsMap';

  /// Citește mapa {medId: [notifId1, notifId2, ...]} din SharedPreferences
  static Future<Map<String, List<int>>> readMap() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString == null) return {};
    final Map<String, dynamic> decoded = jsonDecode(jsonString);
    final Map<String, List<int>> result = {};
    decoded.forEach((key, value) {
      final list =
          (value as List<dynamic>).map((e) => (e as num).toInt()).toList();
      result[key] = list;
    });
    return result;
  }

  /// Scrie mapa actualizată
  static Future<void> writeMap(Map<String, List<int>> map) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(map);
    await prefs.setString(_prefsKey, jsonString);
  }

  /// Adaugă un notificationId în lista pentru un anumit medId
  static Future<void> addNotificationIdForMed(
    String medId,
    int notificationId,
  ) async {
    final map = await readMap();
    final list = map[medId] ?? <int>[];
    if (!list.contains(notificationId)) {
      list.add(notificationId);
      map[medId] = list;
      await writeMap(map);
    }
  }

  /// Pregătește ștergerea notificărilor pentru un medId: returnează lista de notificationIds
  static Future<List<int>> removeNotificationIdsForMed(String medId) async {
    final map = await readMap();
    final ids = map[medId] ?? <int>[];
    map.remove(medId);
    await writeMap(map);
    return ids;
  }
}
