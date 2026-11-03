import 'package:petworld_app/core/error/failures.dart';
import 'package:petworld_app/features/account/domain/entities/account.dart';
import 'package:petworld_app/features/account/domain/repositories/account_repository.dart';
import 'package:petworld_app/features/account/domain/services/password_policy.dart';
import 'package:petworld_app/features/account/domain/services/phone_number_rules.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

class RegisterAccount {
  RegisterAccount(this._repository);

  final AccountRepository _repository;

  /// Ném [ValidationFailure] khi số điện thoại hoặc mật khẩu không hợp lệ,
  /// mật khẩu nhập lại không khớp, hoặc máy đã có tài khoản.
  Future<Account> call({
    required IsoCode country,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) async {
    final e164 = PhoneNumberRules.toE164(phoneNumber, country);
    if (PasswordPolicy.validate(password) case final error?) {
      throw ValidationFailure(error);
    }
    if (PasswordPolicy.validateConfirmation(password, confirmPassword)
        case final error?) {
      throw ValidationFailure(error);
    }
    if (await _repository.getAccount() != null) {
      throw const ValidationFailure('Máy này đã có tài khoản');
    }

    return _repository.createAccount(phoneNumber: e164, password: password);
  }
}
