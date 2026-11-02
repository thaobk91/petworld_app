class PetPhoto {
  const PetPhoto({
    required this.id,
    required this.petId,
    required this.path,
    required this.createdAt,
  });

  final String id;
  final String petId;

  /// Đường dẫn tới file ảnh trên máy.
  final String path;

  final DateTime createdAt;
}
