import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionManager {
  static const _userTokenKey = 'user_token';
  static final _storage = FlutterSecureStorage();

  static Future<void> saveUserToken(String token) async {
    await _storage.write(key: _userTokenKey, value: token);
  }

  static Future<String> getUserToken() async {
    return await _storage.read(key: _userTokenKey) ?? 'test';
  }

  static Future<void> clearUserToken() async {
    await _storage.delete(key: _userTokenKey);
  }
}
