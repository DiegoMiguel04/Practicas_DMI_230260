import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class VideoStatsLocalStorage {
  static const _storageKey = 'video_stats_v1';

  Future<Map<String, Map<String, dynamic>>> readAll() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw == null) return {};

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((id, value) => MapEntry(
        id,
        Map<String, dynamic>.from(value as Map),
      ));
    } on FormatException {
      return {};
    } on TypeError {
      return {};
    }
  }

  Future<void> writeAll(Map<String, Map<String, dynamic>> stats) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, jsonEncode(stats));
  }
}
