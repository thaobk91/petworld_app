import 'package:petworld_app/core/error/failures.dart';
import 'package:petworld_app/features/pets/domain/entities/pet.dart';
import 'package:petworld_app/features/pets/domain/repositories/pet_repository.dart';

class AddPet {
  AddPet(this._repository, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  static const maxNameLength = 30;
  static const maxWeightKg = 150;

  final PetRepository _repository;
  final DateTime Function() _now;

  /// Ném [ValidationFailure] khi dữ liệu không hợp lệ hoặc trong nhà đã có
  /// thú cưng trùng tên.
  Future<Pet> call(PetDraft draft) async {
    final name = draft.name.trim();
    if (name.isEmpty) {
      throw const ValidationFailure('Tên thú cưng không được để trống');
    }
    if (name.length > maxNameLength) {
      throw const ValidationFailure('Tên thú cưng tối đa $maxNameLength ký tự');
    }

    final weight = draft.weightKg;
    if (weight != null && (weight <= 0 || weight > maxWeightKg)) {
      throw const ValidationFailure(
        'Cân nặng phải lớn hơn 0 và tối đa $maxWeightKg kg',
      );
    }

    final birthDate = draft.birthDate;
    if (birthDate != null && birthDate.isAfter(_now())) {
      throw const ValidationFailure('Ngày sinh không thể ở tương lai');
    }

    final existing = await _repository.getPets(draft.houseId);
    final duplicated = existing.any(
      (pet) => pet.name.toLowerCase() == name.toLowerCase(),
    );
    if (duplicated) {
      throw ValidationFailure('Trong nhà đã có thú cưng tên "$name"');
    }

    return _repository.addPet(
      PetDraft(
        houseId: draft.houseId,
        name: name,
        species: draft.species,
        gender: draft.gender,
        breed: _blankToNull(draft.breed),
        birthDate: birthDate,
        weightKg: weight,
        description: _blankToNull(draft.description),
        avatarSourcePath: draft.avatarSourcePath,
      ),
    );
  }

  static String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
