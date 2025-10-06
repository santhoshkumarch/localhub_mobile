// Authentication service for managing user sessions
class AuthService {
  static String? _token;
  static Map<String, dynamic>? _user;
  static String? _lastPhone;

  static Future<void> saveAuthData(String phone) async {
    _user = {'phone': phone};
    _lastPhone = phone;
  }

  static Future<void> saveLastPhone(String phone) async {
    _lastPhone = phone;
  }

  static Future<String?> getToken() async {
    return _token;
  }

  static Future<Map<String, dynamic>?> getUser() async {
    return _user;
  }

  static Future<String?> getPhone() async {
    return _user?['phone'];
  }

  static Future<String?> getLastPhone() async {
    return _lastPhone;
  }

  static Future<bool> isLoggedIn() async {
    return _user != null;
  }

  static Future<void> logout() async {
    _token = null;
    _user = null;
    _lastPhone = null;
  }
}