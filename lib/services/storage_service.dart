import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const key = 'qs_history';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<Map<String, dynamic>>> readAll() async {
    final s = _prefs?.getString(key);
    if (s == null) return [];
    final List list = json.decode(s) as List;
    return list.cast<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> writeAll(List<Map<String, dynamic>> items) async {
    await _prefs?.setString(key, json.encode(items));
  }

  Future<void> clear() async { await _prefs?.remove(key); }
}
