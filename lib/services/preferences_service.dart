import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyStayLoggedIn = 'stay_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';

  // Login preferences
  Future<void> setStayLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyStayLoggedIn, value);
  }

  Future<bool> getStayLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyStayLoggedIn) ?? false;
  }

  Future<void> saveUserCredentials(String userId, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUserEmail, email);
  }

  Future<void> clearUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyStayLoggedIn);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  // Clear all preferences
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
