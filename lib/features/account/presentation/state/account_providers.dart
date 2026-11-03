import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petworld_app/features/account/di.dart';
import 'package:petworld_app/features/account/domain/entities/account.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

/// Tài khoản của người dùng, null khi chưa đăng ký.
final myAccountProvider = AsyncNotifierProvider<MyAccountNotifier, Account?>(
  MyAccountNotifier.new,
);

class MyAccountNotifier extends AsyncNotifier<Account?> {
  @override
  Future<Account?> build() => ref.watch(accountRepositoryProvider).getAccount();

  /// Ném lại [ValidationFailure] từ use case để màn hình hiện lỗi.
  Future<void> register({
    required IsoCode country,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) async {
    final account = await ref.read(registerAccountProvider)(
      country: country,
      phoneNumber: phoneNumber,
      password: password,
      confirmPassword: confirmPassword,
    );
    state = AsyncData(account);
  }
}
