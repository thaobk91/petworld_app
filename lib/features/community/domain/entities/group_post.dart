/// Một bài viết trong nhóm. Hiện chỉ có chữ.
class GroupPost {
  const GroupPost({
    required this.id,
    required this.groupId,
    required this.authorHouseId,
    required this.authorName,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String groupId;

  /// Người đăng được nhận diện bằng ngôi nhà của họ.
  final String authorHouseId;

  /// Tên ngôi nhà lúc đăng, để hiện mà không phải tra lại nhà.
  final String authorName;
  final String text;
  final DateTime createdAt;
}
