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
  static const String historyKey = 'conversion_history';

  static Future<void> saveCache(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> loadCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> addToHistory(String entry) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(historyKey) ?? [];
    history.insert(0, entry);
    if (history.length > 10) history = history.sublist(0, 10); // Limit to 10
    await prefs.setStringList(historyKey, history);
  }

  static Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(historyKey) ?? [];
  }
}
