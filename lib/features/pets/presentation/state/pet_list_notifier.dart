import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petworld_app/features/pets/di.dart';
import 'package:petworld_app/features/pets/domain/entities/pet.dart';

/// Thú cưng của một ngôi nhà, theo id nhà.
final petListProvider =
    AsyncNotifierProvider.family<PetListNotifier, List<Pet>, String>(
      PetListNotifier.new,
    );

class PetListNotifier extends AsyncNotifier<List<Pet>> {
  PetListNotifier(this.houseId);

  final String houseId;

  // Chỉ đọc danh sách, không có quy tắc gì, nên gọi thẳng repository.
  @override
  Future<List<Pet>> build() =>
      ref.watch(petRepositoryProvider).getPets(houseId);

  /// Ném lại [ValidationFailure] từ use case để màn hình hiện lỗi.
  Future<Pet> addPet(PetDraft draft) async {
    final pet = await ref.read(addPetProvider)(draft);
    state = AsyncData([...state.value ?? const [], pet]);
    return pet;
  }
}
