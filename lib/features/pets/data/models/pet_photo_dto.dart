import 'package:petworld_app/features/pets/domain/entities/pet_photo.dart';

class PetPhotoDto {
  const PetPhotoDto({
    required this.id,
    required this.petId,
    required this.file,
    required this.createdAt,
  });

  factory PetPhotoDto.fromJson(Map<String, dynamic> json) => PetPhotoDto(
    id: json['id'] as String,
    petId: json['pet_id'] as String,
    file: json['file'] as String,
    createdAt: json['created_at'] as String,
  );

  final String id;
  final String petId;

  /// Chỉ là tên file trong bộ nhớ ảnh của app, không phải đường dẫn đầy đủ.
  final String file;

  final String createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'pet_id': petId,
    'file': file,
    'created_at': createdAt,
  };

  /// [resolvePhoto] đổi tên file ảnh thành đường dẫn đầy đủ.
  PetPhoto toEntity(String Function(String fileName) resolvePhoto) => PetPhoto(
    id: id,
    petId: petId,
    path: resolvePhoto(file),
    createdAt: DateTime.parse(createdAt),
  );
}
