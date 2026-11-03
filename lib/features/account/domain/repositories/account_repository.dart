import 'package:petworld_app/features/account/domain/entities/account.dart';

abstract interface class AccountRepository {
  /// Tài khoản đã đăng ký trên máy này, null nếu chưa có.
  Future<Account?> getAccount();

  /// [phoneNumber] ở dạng E.164. [password] chỉ dùng để tạo mã băm, không
  /// được lưu nguyên văn.
  Future<Account> createAccount({
    required String phoneNumber,
    required String password,
  });
}
