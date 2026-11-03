import 'package:flutter/material.dart';
import 'package:petworld_app/features/community/domain/entities/community_group.dart';

extension GroupTopicLabel on GroupTopic {
  String get label => switch (this) {
    GroupTopic.dogs => 'Chó',
    GroupTopic.cats => 'Mèo',
    GroupTopic.smallPets => 'Thú cưng nhỏ',
    GroupTopic.lostAndFound => 'Tìm thú lạc',
    GroupTopic.care => 'Chăm sóc',
    GroupTopic.meetup => 'Gặp gỡ',
    GroupTopic.other => 'Khác',
  };

  String get emoji => switch (this) {
    GroupTopic.dogs => '🐶',
    GroupTopic.cats => '🐱',
    GroupTopic.smallPets => '🐹',
    GroupTopic.lostAndFound => '🔎',
    GroupTopic.care => '💡',
    GroupTopic.meetup => '🎉',
    GroupTopic.other => '🐾',
  };

  /// Màu pastel làm nền ảnh đại diện của nhóm.
  Color get color => switch (this) {
    GroupTopic.dogs => const Color(0xFFFFE2C6),
    GroupTopic.cats => const Color(0xFFE7DEFF),
    GroupTopic.smallPets => const Color(0xFFFFF0BF),
    GroupTopic.lostAndFound => const Color(0xFFFFDAD3),
    GroupTopic.care => const Color(0xFFD3F1FF),
    GroupTopic.meetup => const Color(0xFFFFDDEA),
    GroupTopic.other => const Color(0xFFEAE3D9),
  };
}

/// Ảnh đại diện của nhóm: emoji chủ đề trên nền pastel.
class GroupAvatar extends StatelessWidget {
  const GroupAvatar({super.key, required this.topic, this.size = 52});

  final GroupTopic topic;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: topic.color,
      borderRadius: BorderRadius.circular(size * 0.32),
    ),
    child: Text(topic.emoji, style: TextStyle(fontSize: size * 0.5)),
  );
}

/// Thẻ nhóm trong danh sách. Nhóm chưa tham gia có nút "Tham gia".
class GroupCard extends StatelessWidget {
  const GroupCard({
    super.key,
    required this.group,
    required this.postCount,
    required this.onTap,
    this.onJoin,
  });

  final CommunityGroup group;
  final int postCount;
  final VoidCallback onTap;

  /// Null khi đã tham gia.
  final VoidCallback? onJoin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final onJoin = this.onJoin;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              GroupAvatar(topic: group.topic),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    if (group.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        group.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      '${group.topic.label} · $postCount bài viết',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (onJoin != null)
                FilledButton.tonal(
                  // Nút mặc định của app rộng hết chiều ngang, ở đây cần nút nhỏ.
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  onPressed: onJoin,
                  child: const Text('Tham gia'),
                )
              else
                Icon(Icons.chevron_right_rounded, color: muted),
            ],
          ),
        ),
      ),
    );
  }
}
