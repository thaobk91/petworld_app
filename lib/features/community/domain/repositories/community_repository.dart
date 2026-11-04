import 'package:petworld_app/features/community/domain/entities/community_group.dart';
import 'package:petworld_app/features/community/domain/entities/group_post.dart';

abstract interface class CommunityRepository {
  /// Nhóm có sẵn trước, rồi tới nhóm người dùng tạo (mới nhất trước).
  Future<List<CommunityGroup>> getGroups();

  Future<CommunityGroup> createGroup(GroupDraft draft);

  /// Id các nhóm người dùng đã tham gia.
  Future<Set<String>> getJoinedGroupIds();

  Future<void> joinGroup(String groupId);

  Future<void> leaveGroup(String groupId);

  /// Bài viết của nhóm, mới nhất trước.
  Future<List<GroupPost>> getPosts(String groupId);

  /// Số bài viết theo id nhóm. Nhóm chưa có bài thì không có trong map.
  Future<Map<String, int>> getPostCounts();

  Future<GroupPost> addPost({
    required String groupId,
    required String authorHouseId,
    required String authorName,
    required String text,
  });

  Future<void> deletePost(String postId);
}
