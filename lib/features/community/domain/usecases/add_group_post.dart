import 'package:petworld_app/core/error/failures.dart';
import 'package:petworld_app/features/community/domain/entities/group_post.dart';
import 'package:petworld_app/features/community/domain/repositories/community_repository.dart';

class AddGroupPost {
  AddGroupPost(this._repository);

  static const maxLength = 1000;

  final CommunityRepository _repository;

  /// Đăng bài vào nhóm dưới tên ngôi nhà của người đăng. Chỉ thành viên mới
  /// đăng được. Ném [ValidationFailure] khi không hợp lệ.
  Future<GroupPost> call({
    required String groupId,
    required String authorHouseId,
    required String authorName,
    required String text,
  }) async {
    final content = text.trim();
    if (content.isEmpty) {
      throw const ValidationFailure('Bài viết chưa có nội dung');
    }
    if (content.runes.length > maxLength) {
      throw const ValidationFailure('Bài viết tối đa $maxLength ký tự');
    }

    final joined = await _repository.getJoinedGroupIds();
    if (!joined.contains(groupId)) {
      throw const ValidationFailure('Hãy tham gia nhóm trước khi đăng bài');
    }

    return _repository.addPost(
      groupId: groupId,
      authorHouseId: authorHouseId,
      authorName: authorName,
      text: content,
    );
  }
}
