import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _userTokenKey = 'user_token';

  static Future<void> saveUserToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userTokenKey, token);
  }

  static Future<String> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    if(prefs.getString(_userTokenKey) == null ){
      return 'test';
    }else{
      return prefs.getString(_userTokenKey) ?? 'test';
      };
  }

  static Future<void> clearUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userTokenKey);
  }
}

