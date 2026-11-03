import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petworld_app/core/router/app_routes.dart';
import 'package:petworld_app/core/theme/app_theme.dart';
import 'package:petworld_app/features/community/domain/entities/community_group.dart';
import 'package:petworld_app/features/community/presentation/state/community_providers.dart';
import 'package:petworld_app/features/community/presentation/widgets/group_widgets.dart';
import 'package:petworld_app/shared/widgets/note_card.dart';

/// Tab Cộng đồng: nhóm đã tham gia và các nhóm để khám phá.
class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(communityProvider);

    return Scaffold(
      body: overviewAsync.when(
        data: (overview) => _GroupLists(overview: overview),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Không tải được cộng đồng: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        // Các tab khác cũng có FAB trong cùng route (IndexedStack), hai hero
        // trùng tag mặc định sẽ lỗi khi chuyển màn hình.
        heroTag: null,
        onPressed: () => context.push(AppRoutes.createGroup),
        icon: const Icon(Icons.group_add_outlined),
        label: const Text('Tạo nhóm'),
      ),
    );
  }
}

class _GroupLists extends ConsumerWidget {
  const _GroupLists({required this.overview});

  final CommunityOverview overview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joined = overview.joined;
    final others = overview.others;
    void open(CommunityGroup group) =>
        context.push(AppRoutes.groupDetail(group.id));

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: _CommunityHeader()),
        const _SectionTitle('Nhóm của bạn'),
        if (joined.isEmpty)
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: NoteCard(
                emoji: '👋',
                title: 'Bạn chưa tham gia nhóm nào',
                message:
                    'Chọn một nhóm bên dưới để cùng trò chuyện, hoặc tự tạo '
                    'nhóm của riêng bạn.',
              ),
            ),
          )
        else
          _GroupSliverList(
            children: [
              for (final group in joined)
                GroupCard(
                  group: group,
                  postCount: overview.postCount(group.id),
                  onTap: () => open(group),
                ),
            ],
          ),
        if (others.isNotEmpty) ...[
          const _SectionTitle('Khám phá nhóm'),
          _GroupSliverList(
            children: [
              for (final group in others)
                GroupCard(
                  group: group,
                  postCount: overview.postCount(group.id),
                  onTap: () => open(group),
                  onJoin: () =>
                      ref.read(communityProvider.notifier).join(group.id),
                ),
            ],
          ),
        ],
        // Chừa chỗ cho nút "Tạo nhóm".
        const SliverToBoxAdapter(child: SizedBox(height: 96)),
      ],
    );
  }
}

class _CommunityHeader extends StatelessWidget {
  const _CommunityHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.fromLTRB(
        16,
        MediaQuery.paddingOf(context).top + 12,
        16,
        0,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.softGradient(theme.colorScheme),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🐾 💬', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text('Cộng đồng', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            'Tham gia nhóm để trò chuyện và chia sẻ kinh nghiệm với những '
            'người yêu thú cưng.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
    sliver: SliverToBoxAdapter(
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    ),
  );
}

class _GroupSliverList extends StatelessWidget {
  const _GroupSliverList({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    sliver: SliverList.separated(
      itemCount: children.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, index) => children[index],
    ),
  );
}
