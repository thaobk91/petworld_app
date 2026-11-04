import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petworld_app/features/community/di.dart';
import 'package:petworld_app/features/community/domain/entities/community_group.dart';
import 'package:petworld_app/features/community/domain/entities/group_post.dart';
import 'package:petworld_app/features/house/domain/entities/house.dart';

/// Toàn bộ nhóm, nhóm đã tham gia và số bài viết của từng nhóm.
class CommunityOverview {
  const CommunityOverview({
    required this.groups,
    required this.joinedIds,
    required this.postCounts,
  });

  final List<CommunityGroup> groups;
  final Set<String> joinedIds;
  final Map<String, int> postCounts;

  List<CommunityGroup> get joined =>
      groups.where((group) => joinedIds.contains(group.id)).toList();

  List<CommunityGroup> get others =>
      groups.where((group) => !joinedIds.contains(group.id)).toList();

  bool isJoined(String groupId) => joinedIds.contains(groupId);

  int postCount(String groupId) => postCounts[groupId] ?? 0;

  CommunityGroup? group(String groupId) =>
      groups.where((group) => group.id == groupId).firstOrNull;
}

final communityProvider =
    AsyncNotifierProvider<CommunityNotifier, CommunityOverview>(
      CommunityNotifier.new,
    );

class CommunityNotifier extends AsyncNotifier<CommunityOverview> {
  @override
  Future<CommunityOverview> build() => _load();

  Future<CommunityOverview> _load() async {
    final repository = ref.read(communityRepositoryProvider);
    return CommunityOverview(
      groups: await repository.getGroups(),
      joinedIds: await repository.getJoinedGroupIds(),
      postCounts: await repository.getPostCounts(),
    );
  }

  /// Ném lại [ValidationFailure] từ use case để màn hình hiện lỗi.
  Future<CommunityGroup> createGroup(GroupDraft draft) async {
    final group = await ref.read(createGroupProvider)(draft);
    state = AsyncData(await _load());
    return group;
  }

  // Tham gia, rời nhóm chỉ là ghi dữ liệu, không có quy tắc, nên gọi thẳng
  // repository.
  Future<void> join(String groupId) async {
    await ref.read(communityRepositoryProvider).joinGroup(groupId);
    state = AsyncData(await _load());
  }

  Future<void> leave(String groupId) async {
    await ref.read(communityRepositoryProvider).leaveGroup(groupId);
    state = AsyncData(await _load());
  }

  /// Số bài viết đổi thì tải lại để thẻ nhóm hiện đúng.
  Future<void> refresh() async => state = AsyncData(await _load());
}

/// Bài viết của một nhóm, theo id nhóm, mới nhất trước.
final groupPostsProvider =
    AsyncNotifierProvider.family<GroupPostsNotifier, List<GroupPost>, String>(
      GroupPostsNotifier.new,
    );

class GroupPostsNotifier extends AsyncNotifier<List<GroupPost>> {
  GroupPostsNotifier(this.groupId);

  final String groupId;

  @override
  Future<List<GroupPost>> build() =>
      ref.watch(communityRepositoryProvider).getPosts(groupId);

  /// Đăng dưới tên ngôi nhà [author]. Ném lại [ValidationFailure].
  Future<void> addPost({required House author, required String text}) async {
    final post = await ref.read(addGroupPostProvider)(
      groupId: groupId,
      authorHouseId: author.id,
      authorName: author.name,
      text: text,
    );
    state = AsyncData([post, ...state.value ?? const []]);
    await ref.read(communityProvider.notifier).refresh();
  }

  Future<void> deletePost(GroupPost post, {required House requester}) async {
    await ref.read(deleteGroupPostProvider)(
      post: post,
      requesterHouseId: requester.id,
    );
    state = AsyncData([
      for (final item in state.value ?? const <GroupPost>[])
        if (item.id != post.id) item,
    ]);
    await ref.read(communityProvider.notifier).refresh();
  }
}
