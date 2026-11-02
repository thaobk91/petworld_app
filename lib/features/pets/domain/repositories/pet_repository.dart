import 'package:petworld_app/features/pets/domain/entities/pet.dart';
import 'package:petworld_app/features/pets/domain/entities/pet_photo.dart';

/// Domain cần dữ liệu gì. Lấy ở đâu, lấy thế nào là việc của lớp data.
abstract interface class PetRepository {
  Future<List<Pet>> getPets(String houseId);

  Future<Pet?> getPet(String id);

  Future<Pet> addPet(PetDraft draft);

  /// Ảnh mới nhất đứng đầu.
  Future<List<PetPhoto>> getPhotos(String petId);

  /// [sourcePath] là file tạm vừa chọn, sẽ được sao chép vào bộ nhớ của app.
  Future<PetPhoto> addPhoto({
    required String petId,
    required String sourcePath,
  });
}
