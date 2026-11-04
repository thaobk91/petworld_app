import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:petworld_app/features/community/data/datasources/community_local_datasource.dart';
import 'package:petworld_app/features/community/data/repositories/community_repository_impl.dart';
import 'package:petworld_app/features/community/domain/entities/community_group.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late DateTime now;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    now = DateTime(2026, 11, 3, 9);
  });

  CommunityRepositoryImpl repository() =>
      CommunityRepositoryImpl(CommunityLocalDataSource(prefs), now: () => now);

  test('chưa có gì thì vẫn có các nhóm chủ đề sẵn', () async {
    final groups = await repository().getGroups();
    expect(groups, hasLength(CommunityLocalDataSource.builtInGroups.length));
    expect(groups.every((group) => group.isBuiltIn), isTrue);
    expect(
      groups.map((group) => group.name),
      containsAll(['Hội yêu chó', 'Hội yêu mèo', 'Tìm thú cưng thất lạc']),
    );
  });

  test('nhóm tự tạo lưu lại, đứng sau nhóm có sẵn, mới nhất trước', () async {
    await repository().createGroup(
      const GroupDraft(name: 'Nhóm A', topic: GroupTopic.meetup),
    );
    now = now.add(const Duration(minutes: 5));
    await repository().createGroup(
      const GroupDraft(name: 'Nhóm B', topic: GroupTopic.other),
    );

    final groups = await repository().getGroups();
    final created = groups.where((group) => !group.isBuiltIn).toList();
    expect(created.map((group) => group.name), ['Nhóm B', 'Nhóm A']);
    expect(groups.first.isBuiltIn, isTrue);

    // Khoá JSON kiểu snake_case cho khớp cột bảng khi lên backend.
    final saved = jsonDecode(prefs.getString('community_groups')!) as List;
    expect((saved.first as Map).keys, contains('created_at'));
  });

  test('tham gia và rời nhóm được lưu lại', () async {
    await repository().joinGroup('builtin-dogs');
    await repository().joinGroup('builtin-cats');
    await repository().leaveGroup('builtin-dogs');

    expect(await repository().getJoinedGroupIds(), {'builtin-cats'});
  });

  test('bài viết theo nhóm, mới nhất trước, có đếm số bài', () async {
    Future<void> post(String groupId, String text) => repository().addPost(
      groupId: groupId,
      authorHouseId: 'h1',
      authorName: 'Nhà của Milu',
      text: text,
    );

    await post('builtin-cats', 'Bài 1');
    now = now.add(const Duration(hours: 1));
    await post('builtin-cats', 'Bài 2');
    await post('builtin-dogs', 'Bài chó');

    final cats = await repository().getPosts('builtin-cats');
    expect(cats.map((post) => post.text), ['Bài 2', 'Bài 1']);
    expect(await repository().getPostCounts(), {
      'builtin-cats': 2,
      'builtin-dogs': 1,
    });

    await repository().deletePost(cats.first.id);
    expect(await repository().getPostCounts(), {
      'builtin-cats': 1,
      'builtin-dogs': 1,
    });
  });
}
