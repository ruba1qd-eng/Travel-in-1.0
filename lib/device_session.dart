import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// هوية الجهاز — تُستخدم لربط تذاكر الدعم والصورة الشخصية
/// حتى بدون تسجيل دخول (سنربطها بالمستخدم لاحقاً عند إضافة Auth)
class DeviceSession {
  static String? _deviceId;

  static Future<String> deviceId() async {
    if (_deviceId != null) return _deviceId!;
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString('device_id');
    if (existing != null) {
      _deviceId = existing;
      return existing;
    }
    final r = Random.secure();
    final id = List.generate(
      16,
      (i) => r.nextInt(256).toString().padLeft(2, '0'),
    ).join();
    await prefs.setString('device_id', id);
    _deviceId = id;
    return id;
  }

  static Future<String> userName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name') ?? '';
  }

  static Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
  }
}
