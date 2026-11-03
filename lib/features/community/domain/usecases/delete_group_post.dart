import 'package:petworld_app/core/error/failures.dart';
import 'package:petworld_app/features/community/domain/entities/group_post.dart';
import 'package:petworld_app/features/community/domain/repositories/community_repository.dart';

class DeleteGroupPost {
  DeleteGroupPost(this._repository);

  final CommunityRepository _repository;

  /// Chỉ người đăng mới xoá được bài của mình. Ném [ValidationFailure] nếu
  /// không phải.
  Future<void> call({
    required GroupPost post,
    required String requesterHouseId,
  }) async {
    if (post.authorHouseId != requesterHouseId) {
      throw const ValidationFailure('Bạn chỉ xoá được bài của mình');
    }
    await _repository.deletePost(post.id);
  }
}
