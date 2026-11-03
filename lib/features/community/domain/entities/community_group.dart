/// Chủ đề của nhóm, quyết định emoji và màu của nhóm.
enum GroupTopic { dogs, cats, smallPets, lostAndFound, care, meetup, other }

/// Một nhóm trong Cộng đồng.
class CommunityGroup {
  const CommunityGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.topic,
    required this.isBuiltIn,
    required this.createdAt,
  });

  final String id;
  final String name;

  /// Có thể rỗng.
  final String description;
  final GroupTopic topic;

  /// Nhóm chủ đề có sẵn của PetWorld, không phải do người dùng tạo.
  final bool isBuiltIn;
  final DateTime createdAt;
}

/// Thông tin nhập vào khi tạo nhóm, chưa có id.
class GroupDraft {
  const GroupDraft({
    required this.name,
    required this.topic,
    this.description = '',
  });

  final String name;
  final GroupTopic topic;
  final String description;
}
