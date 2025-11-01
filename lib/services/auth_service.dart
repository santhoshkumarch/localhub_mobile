import 'package:shared_preferences/shared_preferences.dart';

// Authentication service for managing user sessions
class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';
  static const String _lastPhoneKey = 'last_phone';

  static Future<void> saveAuthData(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, phone);
    await prefs.setString(_lastPhoneKey, phone);
  }

  static Future<void> saveLastPhone(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastPhoneKey, phone);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString(_userKey);
    return phone != null ? {'phone': phone} : null;
  }

  static Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }

  static Future<String?> getLastPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastPhoneKey);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey) != null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    // Keep last phone for convenience
  }
}