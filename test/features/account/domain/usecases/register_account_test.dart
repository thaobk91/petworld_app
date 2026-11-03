import 'package:flutter_test/flutter_test.dart';
import 'package:petworld_app/core/error/failures.dart';
import 'package:petworld_app/features/account/domain/entities/account.dart';
import 'package:petworld_app/features/account/domain/repositories/account_repository.dart';
import 'package:petworld_app/features/account/domain/usecases/register_account.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

class _FakeAccountRepository implements AccountRepository {
  Account? account;
  String? savedPassword;

  @override
  Future<Account?> getAccount() async => account;

  @override
  Future<Account> createAccount({
    required String phoneNumber,
    required String password,
  }) async {
    savedPassword = password;
    return account = Account(
      id: 'a1',
      phoneNumber: phoneNumber,
      createdAt: DateTime(2026, 11, 3),
    );
  }
}

void main() {
  late _FakeAccountRepository repository;
  late RegisterAccount registerAccount;

  setUp(() {
    repository = _FakeAccountRepository();
    registerAccount = RegisterAccount(repository);
  });

  Future<Account> register({
    IsoCode country = IsoCode.VN,
    String phoneNumber = '0912 345 678',
    String password = 'Milu@2026',
    String? confirmPassword,
  }) => registerAccount(
    country: country,
    phoneNumber: phoneNumber,
    password: password,
    confirmPassword: confirmPassword ?? password,
  );

  Future<void> expectRejected(Future<Account> attempt, String message) async {
    await expectLater(
      attempt,
      throwsA(
        isA<ValidationFailure>().having((e) => e.message, 'message', message),
      ),
    );
  }

  test('lưu số điện thoại dạng E.164', () async {
    final account = await register();

    expect(account.phoneNumber, '+84912345678');
    expect(repository.savedPassword, 'Milu@2026');
  });

  test('từ chối số điện thoại sai', () async {
    await expectRejected(
      register(phoneNumber: '0912'),
      'Số điện thoại di động không đúng',
    );
    expect(repository.account, isNull);
  });

  test('từ chối mật khẩu thiếu ký tự đặc biệt', () async {
    await expectRejected(
      register(password: 'Milu2026'),
      'Mật khẩu cần có ít nhất 1 ký tự đặc biệt',
    );
    expect(repository.account, isNull);
  });

  test('từ chối khi mật khẩu nhập lại không khớp', () async {
    await expectRejected(
      register(confirmPassword: 'Milu@2027'),
      'Mật khẩu nhập lại không khớp',
    );
    expect(repository.account, isNull);
  });

  test('mỗi máy chỉ đăng ký một tài khoản', () async {
    await register();

    await expectRejected(
      register(phoneNumber: '0987 654 321'),
      'Máy này đã có tài khoản',
    );
    expect(repository.account!.phoneNumber, '+84912345678');
  });
}
