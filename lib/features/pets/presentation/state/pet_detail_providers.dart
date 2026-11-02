import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petworld_app/features/pets/di.dart';
import 'package:petworld_app/features/pets/domain/entities/pet.dart';
import 'package:petworld_app/features/pets/domain/entities/pet_photo.dart';

/// Một thú cưng theo id, null nếu không tìm thấy.
final petProvider = FutureProvider.family<Pet?, String>(
  (ref, id) => ref.watch(petRepositoryProvider).getPet(id),
);

/// Ảnh của một thú cưng theo id, ảnh mới nhất đứng đầu.
final petPhotosProvider =
    AsyncNotifierProvider.family<PetPhotosNotifier, List<PetPhoto>, String>(
      PetPhotosNotifier.new,
    );

class PetPhotosNotifier extends AsyncNotifier<List<PetPhoto>> {
  PetPhotosNotifier(this.petId);

  final String petId;

  @override
  Future<List<PetPhoto>> build() =>
      ref.watch(petRepositoryProvider).getPhotos(petId);

  Future<void> addPhoto(String sourcePath) async {
    final photo = await ref
        .read(petRepositoryProvider)
        .addPhoto(petId: petId, sourcePath: sourcePath);
    state = AsyncData([photo, ...state.value ?? const []]);
  }
}
