import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:petworld_app/core/storage/photo_storage.dart';
import 'package:petworld_app/features/pets/data/datasources/pet_local_datasource.dart';
import 'package:petworld_app/features/pets/data/repositories/pet_repository_impl.dart';
import 'package:petworld_app/features/pets/domain/entities/pet.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('petworld_test');
  });

  tearDown(() => tempDir.delete(recursive: true));

  Future<PetRepositoryImpl> createRepository([
    Map<String, Object>? initialValues,
  ]) async {
    if (initialValues != null) {
      SharedPreferences.setMockInitialValues(initialValues);
    }
    final prefs = await SharedPreferences.getInstance();
    return PetRepositoryImpl(
      PetLocalDataSource(prefs),
      PhotoStorage(tempDir.path),
    );
  }

  Future<String> createImage(String name) async {
    final file = File(p.join(tempDir.path, name));
    await file.writeAsBytes([1, 2, 3]);
    return file.path;
  }

  test('ảnh đại diện được sao chép vào bộ nhớ của app', () async {
    final repository = await createRepository({});
    final source = await createImage('picked.jpg');

    final pet = await repository.addPet(
      PetDraft(
        houseId: 'h1',
        name: 'Milu',
        species: PetSpecies.dog,
        avatarSourcePath: source,
      ),
    );

    final avatar = pet.avatarPath!;
    expect(avatar, isNot(source));
    expect(p.isWithin(p.join(tempDir.path, 'photos'), avatar), isTrue);
    expect(await File(avatar).readAsBytes(), [1, 2, 3]);

    final reloaded = await (await createRepository()).getPet(pet.id);
    expect(reloaded!.avatarPath, avatar);
  });

  test('đọc lại đủ các thông tin đã lưu', () async {
    final repository = await createRepository({});
    final added = await repository.addPet(
      PetDraft(
        houseId: 'h1',
        name: 'Mướp',
        species: PetSpecies.cat,
        gender: PetGender.female,
        breed: 'Mèo mướp',
        birthDate: DateTime(2024, 8, 1),
        weightKg: 4.5,
        description: 'Thích nằm phơi nắng',
      ),
    );

    final pet = (await (await createRepository()).getPet(added.id))!;

    expect(pet.species, PetSpecies.cat);
    expect(pet.gender, PetGender.female);
    expect(pet.breed, 'Mèo mướp');
    expect(pet.birthDate, DateTime(2024, 8, 1));
    expect(pet.weightKg, 4.5);
    expect(pet.description, 'Thích nằm phơi nắng');
    expect(pet.avatarPath, isNull);
  });

  test('chỉ trả về thú cưng của đúng nhà', () async {
    final repository = await createRepository({});
    await repository.addPet(
      const PetDraft(houseId: 'h1', name: 'Milu', species: PetSpecies.dog),
    );
    await repository.addPet(
      const PetDraft(houseId: 'h2', name: 'Mướp', species: PetSpecies.cat),
    );

    final pets = await repository.getPets('h1');

    expect(pets.map((pet) => pet.name), ['Milu']);
  });

  test('đọc được dữ liệu cũ thiếu khoá, loài lạ đọc thành "other"', () async {
    final repository = await createRepository({
      'pets': '[{"id":"1","name":"Tí","species":"capybara"}]',
    });

    final pet = (await repository.getPet('1'))!;

    expect(pet.houseId, '');
    expect(pet.species, PetSpecies.other);
    expect(pet.gender, PetGender.unknown);
  });

  test('ảnh mới nhất đứng đầu', () async {
    final repository = await createRepository({});
    final first = await repository.addPhoto(
      petId: 'p1',
      sourcePath: await createImage('a.jpg'),
    );
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final second = await repository.addPhoto(
      petId: 'p1',
      sourcePath: await createImage('b.jpg'),
    );
    await repository.addPhoto(
      petId: 'p2',
      sourcePath: await createImage('c.jpg'),
    );

    final photos = await repository.getPhotos('p1');

    expect(photos.map((photo) => photo.id), [second.id, first.id]);
    expect(await File(photos.first.path).exists(), isTrue);
  });
}
