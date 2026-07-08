import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_save.dart';

/// โหลด/เซฟสถานะเกมลง local storage
class SaveService {
  static const _key = 'brew_rush_save';

  /// โหลดเซฟล่าสุด — ถ้าไม่มีหรือไฟล์เสีย ให้เริ่มเกมใหม่
  Future<GameSave> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return GameSave.fresh();
    try {
      return GameSave.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      return GameSave.fresh();
    }
  }

  Future<void> save(GameSave save) async {
    final prefs = await SharedPreferences.getInstance();
    // ประทับเวลาไว้คำนวณรายได้ออฟไลน์ตอนกลับมาเปิด
    save.lastSeenMs = DateTime.now().millisecondsSinceEpoch;
    await prefs.setString(_key, jsonEncode(save.toJson()));
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
