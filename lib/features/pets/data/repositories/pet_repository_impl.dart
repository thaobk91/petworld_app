import 'package:petworld_app/core/storage/photo_storage.dart';
import 'package:petworld_app/features/pets/data/datasources/pet_local_datasource.dart';
import 'package:petworld_app/features/pets/data/models/pet_dto.dart';
import 'package:petworld_app/features/pets/data/models/pet_photo_dto.dart';
import 'package:petworld_app/features/pets/domain/entities/pet.dart';
import 'package:petworld_app/features/pets/domain/entities/pet_photo.dart';
import 'package:petworld_app/features/pets/domain/repositories/pet_repository.dart';
import 'package:uuid/uuid.dart';

class PetRepositoryImpl implements PetRepository {
  PetRepositoryImpl(this._local, this._photos);

  static const _uuid = Uuid();

  final PetLocalDataSource _local;
  final PhotoStorage _photos;

  @override
  Future<List<Pet>> getPets(String houseId) async => _local
      .readPets()
      .where((dto) => dto.houseId == houseId)
      .map(_toPet)
      .toList();

  @override
  Future<Pet?> getPet(String id) async {
    for (final dto in _local.readPets()) {
      if (dto.id == id) return _toPet(dto);
    }
    return null;
  }

  @override
  Future<Pet> addPet(PetDraft draft) async {
    final avatarSource = draft.avatarSourcePath;
    final dto = PetDto.fromDraft(
      draft,
      id: _uuid.v4(),
      avatarFile: avatarSource == null
          ? null
          : await _photos.save(avatarSource),
    );
    await _local.savePets([..._local.readPets(), dto]);
    return _toPet(dto);
  }

  @override
  Future<List<PetPhoto>> getPhotos(String petId) async {
    final photos = _local
        .readPhotos()
        .where((dto) => dto.petId == petId)
        .map(_toPhoto)
        .toList();
    photos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return photos;
  }

  @override
  Future<PetPhoto> addPhoto({
    required String petId,
    required String sourcePath,
  }) async {
    final dto = PetPhotoDto(
      id: _uuid.v4(),
      petId: petId,
      file: await _photos.save(sourcePath),
      createdAt: DateTime.now().toIso8601String(),
    );
    await _local.savePhotos([..._local.readPhotos(), dto]);
    return _toPhoto(dto);
  }

  Pet _toPet(PetDto dto) => dto.toEntity(_photos.pathOf);

  PetPhoto _toPhoto(PetPhotoDto dto) => dto.toEntity(_photos.pathOf);
}
