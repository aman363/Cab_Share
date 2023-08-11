import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static Future<bool> getBoolValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  static Future<void> setBoolValue(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
  static Future<void> updateBoolValue(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('_isBoolValue', value);
  }
}
