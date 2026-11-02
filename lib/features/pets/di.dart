import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petworld_app/core/storage/photo_storage.dart';
import 'package:petworld_app/core/storage/shared_preferences_provider.dart';
import 'package:petworld_app/features/pets/data/datasources/pet_local_datasource.dart';
import 'package:petworld_app/features/pets/data/repositories/pet_repository_impl.dart';
import 'package:petworld_app/features/pets/domain/repositories/pet_repository.dart';
import 'package:petworld_app/features/pets/domain/usecases/add_pet.dart';

// Chỗ duy nhất nối interface của domain với implementation của data.
// Presentation chỉ dùng các provider ở đây, không import thẳng lớp data.

final petLocalDataSourceProvider = Provider<PetLocalDataSource>(
  (ref) => PetLocalDataSource(ref.watch(sharedPreferencesProvider)),
);

final petRepositoryProvider = Provider<PetRepository>(
  (ref) => PetRepositoryImpl(
    ref.watch(petLocalDataSourceProvider),
    ref.watch(photoStorageProvider),
  ),
);

final addPetProvider = Provider<AddPet>(
  (ref) => AddPet(ref.watch(petRepositoryProvider)),
);
