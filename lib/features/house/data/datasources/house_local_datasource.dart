import 'dart:convert';

import 'package:petworld_app/features/house/data/models/house_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lưu ngôi nhà của người dùng dạng JSON trên máy.
class HouseLocalDataSource {
  HouseLocalDataSource(this._prefs);

  static const _key = 'house';

  final SharedPreferences _prefs;

  HouseDto? read() {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    return HouseDto.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(HouseDto house) async {
    await _prefs.setString(_key, jsonEncode(house.toJson()));
  }
}
