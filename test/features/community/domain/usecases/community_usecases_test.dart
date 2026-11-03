import 'package:flutter_test/flutter_test.dart';
import 'package:petworld_app/core/error/failures.dart';
import 'package:petworld_app/features/community/data/datasources/community_local_datasource.dart';
import 'package:petworld_app/features/community/data/repositories/community_repository_impl.dart';
import 'package:petworld_app/features/community/domain/entities/community_group.dart';
import 'package:petworld_app/features/community/domain/usecases/add_group_post.dart';
import 'package:petworld_app/features/community/domain/usecases/create_group.dart';
import 'package:petworld_app/features/community/domain/usecases/delete_group_post.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late CommunityRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = CommunityRepositoryImpl(
      CommunityLocalDataSource(await SharedPreferences.getInstance()),
    );
  });

  Matcher failsWith(String message) => throwsA(
    isA<ValidationFailure>().having((e) => e.message, 'message', message),
  );

  group('CreateGroup', () {
    late CreateGroup createGroup;

    setUp(() => createGroup = CreateGroup(repository));

    test('tạo nhóm, cắt khoảng trắng, người tạo tự tham gia', () async {
      final group = await createGroup(
        const GroupDraft(
          name: '  Hội corgi Hà Nội  ',
          topic: GroupTopic.dogs,
          description: '  Chân ngắn tụ họp  ',
        ),
      );

      expect(group.name, 'Hội corgi Hà Nội');
      expect(group.description, 'Chân ngắn tụ họp');
      expect(group.isBuiltIn, isFalse);
      expect(await repository.getJoinedGroupIds(), {group.id});
    });

    test('tên trống, quá ngắn, quá dài thì báo lỗi', () async {
      expect(
        () =>
            createGroup(const GroupDraft(name: '   ', topic: GroupTopic.cats)),
        failsWith('Hãy đặt tên cho nhóm'),
      );
      expect(
        () => createGroup(const GroupDraft(name: 'Ab', topic: GroupTopic.cats)),
        failsWith('Tên nhóm cần ít nhất 3 ký tự'),
      );
      expect(
        () => createGroup(GroupDraft(name: 'a' * 51, topic: GroupTopic.cats)),
        failsWith('Tên nhóm tối đa 50 ký tự'),
      );
    });

    test('tên có dấu đếm theo ký tự, không theo đơn vị UTF-16', () async {
      // "Mèo 🐱" có 5 ký tự nhưng 6 đơn vị UTF-16.
      final group = await createGroup(
        const GroupDraft(name: 'Mèo 🐱', topic: GroupTopic.cats),
      );
      expect(group.name, 'Mèo 🐱');
    });

    test('mô tả quá dài thì báo lỗi', () async {
      expect(
        () => createGroup(
          GroupDraft(
            name: 'Hội mèo mướp',
            topic: GroupTopic.cats,
            description: 'x' * 301,
          ),
        ),
        failsWith('Mô tả tối đa 300 ký tự'),
      );
    });

    test('trùng tên nhóm có sẵn, không phân biệt hoa thường và dấu', () async {
      expect(
        () => createGroup(
          const GroupDraft(name: 'hoi yeu meo', topic: GroupTopic.cats),
        ),
        failsWith('Đã có nhóm tên "hoi yeu meo"'),
      );
    });
  });

  group('AddGroupPost', () {
    late AddGroupPost addPost;

    setUp(() => addPost = AddGroupPost(repository));

    Future<void> post(String text, {String groupId = 'builtin-cats'}) =>
        addPost(
          groupId: groupId,
          authorHouseId: 'h1',
          authorName: 'Nhà của Milu',
          text: text,
        );

    test('chưa tham gia nhóm thì không đăng được', () async {
      expect(
        () => post('Chào cả nhà'),
        failsWith('Hãy tham gia nhóm trước khi đăng bài'),
      );
    });

    test('đăng bài khi đã tham gia, nội dung được cắt khoảng trắng', () async {
      await repository.joinGroup('builtin-cats');
      await post('  Chào cả nhà  ');

      final posts = await repository.getPosts('builtin-cats');
      expect(posts.single.text, 'Chào cả nhà');
      expect(posts.single.authorName, 'Nhà của Milu');
    });

    test('nội dung trống hay quá dài thì báo lỗi', () async {
      await repository.joinGroup('builtin-cats');
      expect(() => post('   '), failsWith('Bài viết chưa có nội dung'));
      expect(() => post('x' * 1001), failsWith('Bài viết tối đa 1000 ký tự'));
    });
  });

  group('DeleteGroupPost', () {
    test('chỉ người đăng mới xoá được', () async {
      await repository.joinGroup('builtin-dogs');
      final post = await AddGroupPost(repository)(
        groupId: 'builtin-dogs',
        authorHouseId: 'h1',
        authorName: 'Nhà của Milu',
        text: 'Bé nhà mình biết bắt tay rồi',
      );
      final delete = DeleteGroupPost(repository);

      expect(
        () => delete(post: post, requesterHouseId: 'h2'),
        failsWith('Bạn chỉ xoá được bài của mình'),
      );
      expect(await repository.getPosts('builtin-dogs'), hasLength(1));

      await delete(post: post, requesterHouseId: 'h1');
      expect(await repository.getPosts('builtin-dogs'), isEmpty);
    });
  });
}
