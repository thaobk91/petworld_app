import 'package:flutter_test/flutter_test.dart';
import 'package:petworld_app/core/error/failures.dart';
import 'package:petworld_app/features/pets/domain/entities/pet.dart';
import 'package:petworld_app/features/pets/domain/entities/pet_photo.dart';
import 'package:petworld_app/features/pets/domain/repositories/pet_repository.dart';
import 'package:petworld_app/features/pets/domain/usecases/add_pet.dart';

class _FakePetRepository implements PetRepository {
  final pets = <Pet>[];

  @override
  Future<List<Pet>> getPets(String houseId) async =>
      pets.where((pet) => pet.houseId == houseId).toList();

  @override
  Future<Pet?> getPet(String id) async => null;

  @override
  Future<Pet> addPet(PetDraft draft) async {
    final pet = Pet(
      id: '${pets.length + 1}',
      houseId: draft.houseId,
      name: draft.name,
      species: draft.species,
      gender: draft.gender,
      breed: draft.breed,
      birthDate: draft.birthDate,
      weightKg: draft.weightKg,
      description: draft.description,
    );
    pets.add(pet);
    return pet;
  }

  @override
  Future<List<PetPhoto>> getPhotos(String petId) => throw UnimplementedError();

  @override
  Future<PetPhoto> addPhoto({
    required String petId,
    required String sourcePath,
  }) => throw UnimplementedError();
}

void main() {
  late _FakePetRepository repository;
  late AddPet addPet;

  setUp(() {
    repository = _FakePetRepository();
    addPet = AddPet(repository, now: () => DateTime(2026, 11, 3));
  });

  PetDraft draft({
    String houseId = 'h1',
    String name = 'Milu',
    String? breed,
    DateTime? birthDate,
    double? weightKg,
  }) => PetDraft(
    houseId: houseId,
    name: name,
    species: PetSpecies.dog,
    breed: breed,
    birthDate: birthDate,
    weightKg: weightKg,
  );

  test('cắt khoảng trắng, ô bỏ trống thì lưu là null', () async {
    final pet = await addPet(draft(name: '  Milu  ', breed: '   '));

    expect(pet.name, 'Milu');
    expect(pet.breed, isNull);
    expect(repository.pets.single.name, 'Milu');
  });

  test('từ chối tên trống', () async {
    await expectLater(
      addPet(draft(name: '   ')),
      throwsA(isA<ValidationFailure>()),
    );
    expect(repository.pets, isEmpty);
  });

  test('từ chối tên dài quá giới hạn', () async {
    await expectLater(
      addPet(draft(name: 'a' * (AddPet.maxNameLength + 1))),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test(
    'từ chối tên trùng trong cùng nhà, không phân biệt hoa thường',
    () async {
      await addPet(draft(name: 'Milu'));

      await expectLater(
        addPet(draft(name: 'milu')),
        throwsA(isA<ValidationFailure>()),
      );
      expect(repository.pets, hasLength(1));
    },
  );

  test('nhà khác được đặt trùng tên', () async {
    await addPet(draft(houseId: 'h1', name: 'Milu'));
    await addPet(draft(houseId: 'h2', name: 'Milu'));

    expect(repository.pets, hasLength(2));
  });

  test('từ chối cân nặng không hợp lệ', () async {
    for (final weight in [0.0, -1.0, AddPet.maxWeightKg + 0.5]) {
      await expectLater(
        addPet(draft(weightKg: weight)),
        throwsA(isA<ValidationFailure>()),
      );
    }
    expect(repository.pets, isEmpty);
  });

  test('từ chối ngày sinh ở tương lai', () async {
    await expectLater(
      addPet(draft(birthDate: DateTime(2026, 11, 4))),
      throwsA(isA<ValidationFailure>()),
    );
  });
}
