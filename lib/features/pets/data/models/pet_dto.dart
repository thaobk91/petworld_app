import 'package:petworld_app/features/pets/domain/entities/pet.dart';

/// Dạng dữ liệu khi lưu trữ hoặc trao đổi với API.
/// Tên khoá viết kiểu snake_case cho khớp với cột của bảng khi lên backend.
class PetDto {
  const PetDto({
    required this.id,
    required this.houseId,
    required this.name,
    required this.species,
    required this.gender,
    this.breed,
    this.birthDate,
    this.weightKg,
    this.description,
    this.avatarFile,
  });

  // Dữ liệu cũ (trước khi có ngôi nhà) thiếu nhiều khoá, nên đọc mềm dẻo.
  factory PetDto.fromJson(Map<String, dynamic> json) => PetDto(
    id: json['id'] as String,
    houseId: json['house_id'] as String? ?? '',
    name: json['name'] as String,
    species: json['species'] as String,
    gender: json['gender'] as String? ?? PetGender.unknown.name,
    breed: json['breed'] as String?,
    birthDate: json['birth_date'] as String?,
    weightKg: (json['weight_kg'] as num?)?.toDouble(),
    description: json['description'] as String?,
    avatarFile: json['avatar_file'] as String?,
  );

  factory PetDto.fromDraft(
    PetDraft draft, {
    required String id,
    required String? avatarFile,
  }) => PetDto(
    id: id,
    houseId: draft.houseId,
    name: draft.name,
    species: draft.species.name,
    gender: draft.gender.name,
    breed: draft.breed,
    birthDate: draft.birthDate?.toIso8601String(),
    weightKg: draft.weightKg,
    description: draft.description,
    avatarFile: avatarFile,
  );

  final String id;
  final String houseId;
  final String name;
  final String species;
  final String gender;
  final String? breed;
  final String? birthDate;
  final double? weightKg;
  final String? description;

  /// Chỉ là tên file trong bộ nhớ ảnh của app, không phải đường dẫn đầy đủ.
  final String? avatarFile;

  Map<String, dynamic> toJson() => {
    'id': id,
    'house_id': houseId,
    'name': name,
    'species': species,
    'gender': gender,
    'breed': breed,
    'birth_date': birthDate,
    'weight_kg': weightKg,
    'description': description,
    'avatar_file': avatarFile,
  };

  /// [resolvePhoto] đổi tên file ảnh thành đường dẫn đầy đủ.
  Pet toEntity(String Function(String fileName) resolvePhoto) => Pet(
    id: id,
    houseId: houseId,
    name: name,
    species: PetSpecies.values.asNameMap()[species] ?? PetSpecies.other,
    gender: PetGender.values.asNameMap()[gender] ?? PetGender.unknown,
    breed: breed,
    birthDate: birthDate == null ? null : DateTime.parse(birthDate!),
    weightKg: weightKg,
    description: description,
    avatarPath: avatarFile == null ? null : resolvePhoto(avatarFile!),
  );
}
