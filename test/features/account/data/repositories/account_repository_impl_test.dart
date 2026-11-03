import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:petworld_app/core/security/password_hasher.dart';
import 'package:petworld_app/features/account/data/datasources/account_local_datasource.dart';
import 'package:petworld_app/features/account/data/repositories/account_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final hasher = Pbkdf2PasswordHasher(iterations: 1000);

  Future<AccountRepositoryImpl> createRepository() async {
    final prefs = await SharedPreferences.getInstance();
    return AccountRepositoryImpl(AccountLocalDataSource(prefs), hasher);
  }

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('chưa đăng ký thì chưa có tài khoản', () async {
    expect(await (await createRepository()).getAccount(), isNull);
  });

  test('lưu mã băm, không lưu mật khẩu nguyên văn', () async {
    await (await createRepository()).createAccount(
      phoneNumber: '+84912345678',
      password: 'Milu@2026',
    );

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('account')!;
    final saved = jsonDecode(raw) as Map<String, dynamic>;
    expect(raw, isNot(contains('Milu@2026')));
    expect(saved['phone_number'], '+84912345678');
    expect(
      await hasher.verify('Milu@2026', saved['password_hash'] as String),
      isTrue,
    );
  });

  test('đọc lại đúng tài khoản đã lưu', () async {
    final created = await (await createRepository()).createAccount(
      phoneNumber: '+84912345678',
      password: 'Milu@2026',
    );

    final account = await (await createRepository()).getAccount();

    expect(account!.id, created.id);
    expect(account.phoneNumber, '+84912345678');
    expect(account.createdAt, created.createdAt);
  });
}
