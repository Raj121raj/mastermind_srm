import 'package:shared_preferences/shared_preferences.dart';

class CacheManager {
  static const String dbmKey = 'dbm_input';
  static const String wattsKey = 'watts_input';
  static const String freqKey = 'freq_input';
  static const String wavelengthKey = 'wavelength_input';
  static const String realKey = 'real_input';
  static const String imagKey = 'imag_input';
  static const String magKey = 'mag_input';
  static const String angleKey = 'angle_input';

  static Future<void> saveCache(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> loadCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
}
