import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petworld_app/core/storage/shared_preferences_provider.dart';
import 'package:petworld_app/features/house/data/datasources/house_local_datasource.dart';
import 'package:petworld_app/features/house/data/repositories/house_repository_impl.dart';
import 'package:petworld_app/features/house/domain/repositories/house_repository.dart';
import 'package:petworld_app/features/house/domain/services/location_fuzzer.dart';
import 'package:petworld_app/features/house/domain/usecases/register_house.dart';

// Chỗ duy nhất nối interface của domain với implementation của data.
// Presentation chỉ dùng các provider ở đây, không import thẳng lớp data.

final houseLocalDataSourceProvider = Provider<HouseLocalDataSource>(
  (ref) => HouseLocalDataSource(ref.watch(sharedPreferencesProvider)),
);

final houseRepositoryProvider = Provider<HouseRepository>(
  (ref) => HouseRepositoryImpl(ref.watch(houseLocalDataSourceProvider)),
);

final locationFuzzerProvider = Provider<LocationFuzzer>(
  (ref) => LocationFuzzer(),
);

final registerHouseProvider = Provider<RegisterHouse>(
  (ref) => RegisterHouse(
    ref.watch(houseRepositoryProvider),
    ref.watch(locationFuzzerProvider),
  ),
);
