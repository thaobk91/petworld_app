import 'package:petworld_app/features/community/domain/entities/community_group.dart';
import 'package:petworld_app/features/community/domain/entities/group_post.dart';

/// Dạng dữ liệu khi lưu trữ hoặc trao đổi với API.
/// Tên khoá viết kiểu snake_case cho khớp với cột của bảng khi lên backend.
class GroupDto {
  const GroupDto({
    required this.id,
    required this.name,
    required this.description,
    required this.topic,
    required this.createdAt,
    this.isBuiltIn = false,
  });

  factory GroupDto.fromJson(Map<String, dynamic> json) => GroupDto(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    topic: json['topic'] as String,
    createdAt: json['created_at'] as String,
  );

  final String id;
  final String name;
  final String description;
  final String topic;
  final String createdAt;

  /// Không lưu: nhóm có sẵn nằm trong code, không nằm trong dữ liệu.
  final bool isBuiltIn;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'topic': topic,
    'created_at': createdAt,
  };

  CommunityGroup toEntity() => CommunityGroup(
    id: id,
    name: name,
    description: description,
    topic: GroupTopic.values.asNameMap()[topic] ?? GroupTopic.other,
    isBuiltIn: isBuiltIn,
    createdAt: DateTime.parse(createdAt),
  );
}

class GroupPostDto {
  const GroupPostDto({
    required this.id,
    required this.groupId,
    required this.authorHouseId,
    required this.authorName,
    required this.text,
    required this.createdAt,
  });

  factory GroupPostDto.fromJson(Map<String, dynamic> json) => GroupPostDto(
    id: json['id'] as String,
    groupId: json['group_id'] as String,
    authorHouseId: json['author_house_id'] as String,
    authorName: json['author_name'] as String,
    text: json['text'] as String,
    createdAt: json['created_at'] as String,
  );

  final String id;
  final String groupId;
  final String authorHouseId;
  final String authorName;
  final String text;
  final String createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'group_id': groupId,
    'author_house_id': authorHouseId,
    'author_name': authorName,
    'text': text,
    'created_at': createdAt,
  };

  GroupPost toEntity() => GroupPost(
    id: id,
    groupId: groupId,
    authorHouseId: authorHouseId,
    authorName: authorName,
    text: text,
    createdAt: DateTime.parse(createdAt),
  );
}
