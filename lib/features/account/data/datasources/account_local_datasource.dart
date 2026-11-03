import 'dart:convert';

import 'package:petworld_app/features/account/data/models/account_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lưu tài khoản của người dùng dạng JSON trên máy.
class AccountLocalDataSource {
  AccountLocalDataSource(this._prefs);

  static const _key = 'account';

  final SharedPreferences _prefs;

  AccountDto? read() {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    return AccountDto.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(AccountDto account) async {
    await _prefs.setString(_key, jsonEncode(account.toJson()));
  }
}
