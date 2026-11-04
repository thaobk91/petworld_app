import 'dart:convert';

import 'package:petworld_app/features/community/data/models/community_dtos.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lưu nhóm người dùng tạo, nhóm đã tham gia và bài viết dạng JSON trên máy.
/// Nhóm chủ đề có sẵn nằm trong code ([builtInGroups]).
class CommunityLocalDataSource {
  CommunityLocalDataSource(this._prefs);

  static const _groupsKey = 'community_groups';
  static const _joinedKey = 'community_joined_groups';
  static const _postsKey = 'community_posts';

  /// Nhóm chủ đề có sẵn để tab Cộng đồng không trống lúc đầu. Id cố định để
  /// bài viết và việc tham gia vẫn khớp sau khi cập nhật app.
  static const builtInGroups = [
    GroupDto(
      id: 'builtin-dogs',
      name: 'Hội yêu chó',
      description: 'Khoe các bé cún, hỏi đáp chuyện nuôi chó.',
      topic: 'dogs',
      createdAt: '2026-11-03T00:00:00.000',
      isBuiltIn: true,
    ),
    GroupDto(
      id: 'builtin-cats',
      name: 'Hội yêu mèo',
      description: 'Nơi các con sen khoe hoàng thượng và chia sẻ kinh nghiệm.',
      topic: 'cats',
      createdAt: '2026-11-03T00:00:00.000',
      isBuiltIn: true,
    ),
    GroupDto(
      id: 'builtin-lost-found',
      name: 'Tìm thú cưng thất lạc',
      description:
          'Đăng tin khi bé đi lạc hoặc khi bạn nhặt được thú cưng của ai đó.',
      topic: 'lostAndFound',
      createdAt: '2026-11-03T00:00:00.000',
      isBuiltIn: true,
    ),
    GroupDto(
      id: 'builtin-care',
      name: 'Hỏi đáp chăm sóc',
      description:
          'Ăn uống, tiêm phòng, tẩy giun, tắm rửa... hỏi gì cũng được.',
      topic: 'care',
      createdAt: '2026-11-03T00:00:00.000',
      isBuiltIn: true,
    ),
    GroupDto(
      id: 'builtin-small-pets',
      name: 'Thú cưng nhỏ',
      description: 'Hamster, thỏ, chim, cá và các bé nhỏ xinh khác.',
      topic: 'smallPets',
      createdAt: '2026-11-03T00:00:00.000',
      isBuiltIn: true,
    ),
  ];

  final SharedPreferences _prefs;

  List<GroupDto> readGroups() => _readList(_groupsKey, GroupDto.fromJson);

  Future<void> saveGroups(List<GroupDto> groups) => _prefs.setString(
    _groupsKey,
    jsonEncode(groups.map((g) => g.toJson()).toList()),
  );

  Set<String> readJoinedGroupIds() =>
      (_prefs.getStringList(_joinedKey) ?? const []).toSet();

  Future<void> saveJoinedGroupIds(Set<String> ids) =>
      _prefs.setStringList(_joinedKey, ids.toList());

  List<GroupPostDto> readPosts() => _readList(_postsKey, GroupPostDto.fromJson);

  Future<void> savePosts(List<GroupPostDto> posts) => _prefs.setString(
    _postsKey,
    jsonEncode(posts.map((p) => p.toJson()).toList()),
  );

  List<T> _readList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((item) => fromJson(item as Map<String, dynamic>)).toList();
  }
}
