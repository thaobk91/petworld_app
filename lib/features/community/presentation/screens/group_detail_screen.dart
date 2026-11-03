import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petworld_app/core/error/failures.dart';
import 'package:petworld_app/core/theme/app_theme.dart';
import 'package:petworld_app/features/community/domain/entities/community_group.dart';
import 'package:petworld_app/features/community/domain/entities/group_post.dart';
import 'package:petworld_app/features/community/presentation/state/community_providers.dart';
import 'package:petworld_app/features/community/presentation/widgets/group_widgets.dart';
import 'package:petworld_app/features/community/presentation/widgets/post_widgets.dart';
import 'package:petworld_app/features/house/domain/entities/house.dart';
import 'package:petworld_app/features/house/presentation/state/house_providers.dart';
import 'package:petworld_app/shared/widgets/empty_state.dart';
import 'package:petworld_app/shared/widgets/info_pill.dart';

class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(communityProvider).value;
    final group = overview?.group(groupId);
    if (overview == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (group == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(emoji: '🤔', title: 'Không tìm thấy nhóm'),
      );
    }

    final joined = overview.isJoined(group.id);
    final house = ref.watch(myHouseProvider).value;
    final postsAsync = ref.watch(groupPostsProvider(group.id));
    final posts = ref.read(groupPostsProvider(group.id).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _GroupHeader(
              group: group,
              joined: joined,
              postCount: overview.postCount(group.id),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Bài viết',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          ...postsAsync.when(
            data: (items) => items.isEmpty
                ? [
                    SliverToBoxAdapter(
                      child: EmptyState(
                        emoji: '💬',
                        title: 'Chưa có bài viết nào',
                        message: joined
                            ? 'Hãy là người mở đầu câu chuyện nhé!'
                            : 'Tham gia nhóm để đăng bài đầu tiên.',
                      ),
                    ),
                  ]
                : [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                      sliver: SliverList.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final post = items[index];
                          final mine =
                              house != null && post.authorHouseId == house.id;
                          return PostCard(
                            post: post,
                            onDelete: mine
                                ? () => _confirmDelete(context, post, house)
                                : null,
                          );
                        },
                      ),
                    ),
                  ],
            loading: () => const [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
            error: (error, _) => [
              SliverToBoxAdapter(
                child: Text('Không tải được bài viết: $error'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: joined && house != null
          ? FloatingActionButton.extended(
              onPressed: () => showPostComposer(
                context,
                groupName: group.name,
                onSubmit: (text) => posts.addPost(author: house, text: text),
              ),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Viết bài'),
            )
          : null,
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    GroupPost post,
    House house,
  ) async {
    final container = ProviderScope.containerOf(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoá bài viết?'),
        content: const Text('Bài viết sẽ bị xoá khỏi nhóm.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await container
          .read(groupPostsProvider(post.groupId).notifier)
          .deletePost(post, requester: house);
    } on ValidationFailure catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}

class _GroupHeader extends ConsumerWidget {
  const _GroupHeader({
    required this.group,
    required this.joined,
    required this.postCount,
  });

  final CommunityGroup group;
  final bool joined;
  final int postCount;

  Future<void> _confirmLeave(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rời nhóm?'),
        content: Text(
          'Bạn sẽ không đăng bài vào "${group.name}" được nữa. Có thể tham '
          'gia lại bất cứ lúc nào.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Rời nhóm'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(communityProvider.notifier).leave(group.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final pillColor = colors.surface.withValues(alpha: 0.75);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.softGradient(colors),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GroupAvatar(topic: group.topic, size: 64),
          const SizedBox(height: 12),
          Text(group.name, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InfoPill(
                leading: Text(group.topic.emoji),
                label: group.topic.label,
                color: pillColor,
              ),
              InfoPill(
                leading: const Text('💬'),
                label: '$postCount bài viết',
                color: pillColor,
              ),
              if (group.isBuiltIn)
                InfoPill(
                  leading: const Text('⭐'),
                  label: 'Nhóm của PetWorld',
                  color: pillColor,
                ),
            ],
          ),
          if (group.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(group.description, style: theme.textTheme.bodyMedium),
          ],
          const SizedBox(height: 16),
          if (joined)
            OutlinedButton.icon(
              onPressed: () => _confirmLeave(context, ref),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Rời nhóm'),
            )
          else
            FilledButton.icon(
              onPressed: () =>
                  ref.read(communityProvider.notifier).join(group.id),
              icon: const Icon(Icons.group_add_outlined),
              label: const Text('Tham gia nhóm'),
            ),
        ],
      ),
    );
  }
}
