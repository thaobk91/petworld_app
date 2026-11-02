enum PetSpecies { dog, cat, bird, rabbit, hamster, fish, other }

enum PetGender { male, female, unknown }

class Pet {
  const Pet({
    required this.id,
    required this.houseId,
    required this.name,
    required this.species,
    this.gender = PetGender.unknown,
    this.breed,
    this.birthDate,
    this.weightKg,
    this.description,
    this.avatarPath,
  });

  final String id;
  final String houseId;
  final String name;
  final PetSpecies species;
  final PetGender gender;
  final String? breed;
  final DateTime? birthDate;
  final double? weightKg;
  final String? description;

  /// Đường dẫn tới ảnh đại diện trên máy, null nếu chưa có.
  final String? avatarPath;
}

/// Thông tin nhập vào khi thêm thú cưng, chưa có id.
class PetDraft {
  const PetDraft({
    required this.houseId,
    required this.name,
    required this.species,
    this.gender = PetGender.unknown,
    this.breed,
    this.birthDate,
    this.weightKg,
    this.description,
    this.avatarSourcePath,
  });

  final String houseId;
  final String name;
  final PetSpecies species;
  final PetGender gender;
  final String? breed;
  final DateTime? birthDate;
  final double? weightKg;
  final String? description;

  /// File ảnh vừa chọn (file tạm). Lớp data sẽ sao chép vào bộ nhớ của app.
  final String? avatarSourcePath;
}
