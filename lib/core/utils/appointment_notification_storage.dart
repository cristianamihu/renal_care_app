import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppointmentNotificationStorage {
  static const _prefsKey = 'apptNotificationIdsMap';

  /// Citește harta {apptId: [notifId1, notifId2, ...]}
  static Future<Map<String, List<int>>> readMap() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString == null) return {};
    final Map<String, dynamic> decoded = jsonDecode(jsonString);
    return decoded.map(
      (k, v) => MapEntry(k, (v as List<dynamic>).map((e) => e as int).toList()),
    );
  }

  /// Scrie harta actualizată
  static Future<void> writeMap(Map<String, List<int>> map) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(map));
  }

  /// Adaugă un notificationId pentru un appointmentId
  static Future<void> addNotificationId(String apptId, int notifId) async {
    final map = await readMap();
    final list = map[apptId] ?? <int>[];
    if (!list.contains(notifId)) {
      list.add(notifId);
      map[apptId] = list;
      await writeMap(map);
    }
  }

  /// Șterge și returnează toate notificationIds asociate unui apptId
  static Future<List<int>> removeNotificationIds(String apptId) async {
    final map = await readMap();
    final ids = map.remove(apptId) ?? <int>[];
    await writeMap(map);
    return ids;
  }
}
