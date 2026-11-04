import 'package:petworld_app/core/error/failures.dart';
import 'package:petworld_app/core/utils/text_search.dart';
import 'package:petworld_app/features/community/domain/entities/community_group.dart';
import 'package:petworld_app/features/community/domain/repositories/community_repository.dart';

class CreateGroup {
  CreateGroup(this._repository);

  static const minNameLength = 3;
  static const maxNameLength = 50;
  static const maxDescriptionLength = 300;

  final CommunityRepository _repository;

  /// Tạo nhóm rồi cho người tạo tham gia luôn. Ném [ValidationFailure] khi
  /// dữ liệu không hợp lệ hoặc đã có nhóm trùng tên.
  Future<CommunityGroup> call(GroupDraft draft) async {
    final name = draft.name.trim();
    final nameLength = name.runes.length;
    if (nameLength == 0) {
      throw const ValidationFailure('Hãy đặt tên cho nhóm');
    }
    if (nameLength < minNameLength) {
      throw const ValidationFailure(
        'Tên nhóm cần ít nhất $minNameLength ký tự',
      );
    }
    if (nameLength > maxNameLength) {
      throw const ValidationFailure('Tên nhóm tối đa $maxNameLength ký tự');
    }

    final description = draft.description.trim();
    if (description.runes.length > maxDescriptionLength) {
      throw const ValidationFailure('Mô tả tối đa $maxDescriptionLength ký tự');
    }

    // So tên không phân biệt hoa thường và dấu: "Yêu Mèo" trùng "yeu meo",
    // tránh nhiều nhóm gần như cùng tên.
    final key = foldForSearch(name);
    final groups = await _repository.getGroups();
    if (groups.any((group) => foldForSearch(group.name) == key)) {
      throw ValidationFailure('Đã có nhóm tên "$name"');
    }

    final group = await _repository.createGroup(
      GroupDraft(name: name, topic: draft.topic, description: description),
    );
    await _repository.joinGroup(group.id);
    return group;
  }
}
