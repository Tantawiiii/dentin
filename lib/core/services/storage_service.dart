
import 'package:shared_preferences/shared_preferences.dart';


class StorageService {
  static const String _keyToken = 'auth_token';

  final SharedPreferences _prefs;


  StorageService(this._prefs,);

  Future<void> saveToken(String token) async {
    await _prefs.setString(_keyToken, token);
  }

  String? getToken() {
    return _prefs.getString(_keyToken);
  }

  Future<void> removeToken() async {
    await _prefs.remove(_keyToken);
  }


}
