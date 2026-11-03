import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petworld_app/core/security/password_hasher.dart';
import 'package:petworld_app/core/storage/shared_preferences_provider.dart';
import 'package:petworld_app/features/account/data/datasources/account_local_datasource.dart';
import 'package:petworld_app/features/account/data/repositories/account_repository_impl.dart';
import 'package:petworld_app/features/account/domain/repositories/account_repository.dart';
import 'package:petworld_app/features/account/domain/usecases/register_account.dart';

// Chỗ duy nhất nối interface của domain với implementation của data.
// Presentation chỉ dùng các provider ở đây, không import thẳng lớp data.

final accountLocalDataSourceProvider = Provider<AccountLocalDataSource>(
  (ref) => AccountLocalDataSource(ref.watch(sharedPreferencesProvider)),
);

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => AccountRepositoryImpl(
    ref.watch(accountLocalDataSourceProvider),
    ref.watch(passwordHasherProvider),
  ),
);

final registerAccountProvider = Provider<RegisterAccount>(
  (ref) => RegisterAccount(ref.watch(accountRepositoryProvider)),
);
