import 'package:petworld_app/core/security/password_hasher.dart';
import 'package:petworld_app/features/account/data/datasources/account_local_datasource.dart';
import 'package:petworld_app/features/account/data/models/account_dto.dart';
import 'package:petworld_app/features/account/domain/entities/account.dart';
import 'package:petworld_app/features/account/domain/repositories/account_repository.dart';
import 'package:uuid/uuid.dart';

class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl(this._local, this._hasher);

  static const _uuid = Uuid();

  final AccountLocalDataSource _local;
  final PasswordHasher _hasher;

  @override
  Future<Account?> getAccount() async => _local.read()?.toEntity();

  @override
  Future<Account> createAccount({
    required String phoneNumber,
    required String password,
  }) async {
    final dto = AccountDto(
      id: _uuid.v4(),
      phoneNumber: phoneNumber,
      passwordHash: await _hasher.hash(password),
      createdAt: DateTime.now().toIso8601String(),
    );
    await _local.save(dto);
    return dto.toEntity();
  }
}
