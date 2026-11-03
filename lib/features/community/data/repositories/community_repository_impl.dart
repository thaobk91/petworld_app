import 'package:petworld_app/features/community/data/datasources/community_local_datasource.dart';
import 'package:petworld_app/features/community/data/models/community_dtos.dart';
import 'package:petworld_app/features/community/domain/entities/community_group.dart';
import 'package:petworld_app/features/community/domain/entities/group_post.dart';
import 'package:petworld_app/features/community/domain/repositories/community_repository.dart';
import 'package:uuid/uuid.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  CommunityRepositoryImpl(this._local, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  static const _uuid = Uuid();

  final CommunityLocalDataSource _local;
  final DateTime Function() _now;

  @override
  Future<List<CommunityGroup>> getGroups() async {
    final created = _local.readGroups()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return [
      for (final dto in CommunityLocalDataSource.builtInGroups) dto.toEntity(),
      for (final dto in created) dto.toEntity(),
    ];
  }

  @override
  Future<CommunityGroup> createGroup(GroupDraft draft) async {
    final dto = GroupDto(
      id: _uuid.v4(),
      name: draft.name,
      description: draft.description,
      topic: draft.topic.name,
      createdAt: _now().toIso8601String(),
    );
    await _local.saveGroups([..._local.readGroups(), dto]);
    return dto.toEntity();
  }

  @override
  Future<Set<String>> getJoinedGroupIds() async => _local.readJoinedGroupIds();

  @override
  Future<void> joinGroup(String groupId) =>
      _local.saveJoinedGroupIds({..._local.readJoinedGroupIds(), groupId});

  @override
  Future<void> leaveGroup(String groupId) =>
      _local.saveJoinedGroupIds(_local.readJoinedGroupIds()..remove(groupId));

  @override
  Future<List<GroupPost>> getPosts(String groupId) async {
    final posts =
        _local.readPosts().where((post) => post.groupId == groupId).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return [for (final dto in posts) dto.toEntity()];
  }

  @override
  Future<Map<String, int>> getPostCounts() async {
    final counts = <String, int>{};
    for (final post in _local.readPosts()) {
      counts.update(post.groupId, (count) => count + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  @override
  Future<GroupPost> addPost({
    required String groupId,
    required String authorHouseId,
    required String authorName,
    required String text,
  }) async {
    final dto = GroupPostDto(
      id: _uuid.v4(),
      groupId: groupId,
      authorHouseId: authorHouseId,
      authorName: authorName,
      text: text,
      createdAt: _now().toIso8601String(),
    );
    await _local.savePosts([..._local.readPosts(), dto]);
    return dto.toEntity();
  }

  @override
  Future<void> deletePost(String postId) => _local.savePosts(
    _local.readPosts().where((post) => post.id != postId).toList(),
  );
}
