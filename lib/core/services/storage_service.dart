import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/login/data/models/login_response.dart';

class StorageService {
  static const String _keyToken = 'auth_token';
  static const String _keyUserData = 'user_data';
  static const String _keyFCMToken = 'fcm_token';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  Future<void> saveToken(String token) async {
    await _prefs.setString(_keyToken, token);
  }

  String? getToken() {
    return _prefs.getString(_keyToken);
  }

  Future<void> removeToken() async {
    await _prefs.remove(_keyToken);
  }

  Future<void> saveUserData(UserData userData) async {
    final jsonString = jsonEncode(userData.toJson());
    await _prefs.setString(_keyUserData, jsonString);
  }

  UserData? getUserData() {
    final jsonString = _prefs.getString(_keyUserData);
    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return UserData.fromJson(json);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> removeUserData() async {
    await _prefs.remove(_keyUserData);
  }

  Future<void> saveFCMToken(String token) async {
    await _prefs.setString(_keyFCMToken, token);
  }

  String? getFCMToken() {
    return _prefs.getString(_keyFCMToken);
  }

  Future<void> removeFCMToken() async {
    await _prefs.remove(_keyFCMToken);
  }

  Future<void> clearAll() async {
    await removeToken();
    await removeUserData();
    await removeFCMToken();
  }
}
