// lib/services/cache_service.dart
//
// Local cache manager using SharedPreferences.
// Prevents repeated Firebase reads.
// Developer: Sibnath Bairagi

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/cache_config.dart';

class CacheService {
  CacheService._();

  static SharedPreferences? _prefs;

  // =====================================================================
  // INIT — call once in main.dart
  // =====================================================================
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _p {
    if (_prefs == null) {
      throw StateError('CacheService.init() must be called first.');
    }
    return _prefs!;
  }

  // =====================================================================
  // SAVE
  // =====================================================================
  static Future<void> saveJson(String key, dynamic jsonData) async {
    await _p.setString(key, jsonEncode(jsonData));
    await _p.setInt(
      '$key${CacheConfig.tsSuffix}',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<void> saveString(String key, String value) async {
    await _p.setString(key, value);
    await _p.setInt(
      '$key${CacheConfig.tsSuffix}',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  // =====================================================================
  // READ
  // =====================================================================
  static dynamic readJson(String key, Duration validFor) {
    if (!isValid(key, validFor)) return null;
    final raw = _p.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  static String? readString(String key, Duration validFor) {
    if (!isValid(key, validFor)) return null;
    return _p.getString(key);
  }

  // =====================================================================
  // VALIDITY
  // =====================================================================
  static bool isValid(String key, Duration validFor) {
    final ts = _p.getInt('$key${CacheConfig.tsSuffix}');
    if (ts == null) return false;
    final cachedAt = DateTime.fromMillisecondsSinceEpoch(ts);
    return DateTime.now().difference(cachedAt) < validFor;
  }

  static Duration? cacheAge(String key) {
    final ts = _p.getInt('$key${CacheConfig.tsSuffix}');
    if (ts == null) return null;
    return DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(ts),
    );
  }

  // =====================================================================
  // CLEAR
  // =====================================================================
  static Future<void> remove(String key) async {
    await _p.remove(key);
    await _p.remove('$key${CacheConfig.tsSuffix}');
  }

  static Future<void> clearAll() async {
    await _p.clear();
  }

  static Future<void> clearByPrefix(String prefix) async {
    final keys =
        _p.getKeys().where((k) => k.startsWith(prefix)).toList();
    for (final k in keys) {
      await _p.remove(k);
    }
  }

  // =====================================================================
  // KEY BUILDERS
  // =====================================================================
  static String chaptersKey(String subjectId) =>
      '${CacheConfig.keyChaptersPrefix}$subjectId';

  static String videosKey(String chapterId) =>
      '${CacheConfig.keyVideosPrefix}$chapterId';

  static String leaderboardKey(String weekId) =>
      '${CacheConfig.keyLeaderboardPrefix}$weekId';

  static String userKey(String uid) =>
      '${CacheConfig.keyUserProfilePrefix}$uid';

  // =====================================================================
  // ISO WEEK HELPERS
  // =====================================================================
  static String currentWeekId() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final year = monday.year;
    final weekNumber = _isoWeekNumber(monday);
    return '$year-W${weekNumber.toString().padLeft(2, '0')}';
  }

  static int _isoWeekNumber(DateTime date) {
    final dayOfYear =
        int.parse(date.difference(DateTime(date.year, 1, 1)).inDays.toString()) +
            1;
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  static DateTime nextResetTime() {
    final now = DateTime.now();
    final daysUntilSunday = 7 - now.weekday;
    final reset = now.add(Duration(days: daysUntilSunday));
    return DateTime(
      reset.year,
      reset.month,
      reset.day,
      CacheConfig.leaderboardResetHour,
      CacheConfig.leaderboardResetMinute,
    );
  }
}