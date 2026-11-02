import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petworld_app/core/router/app_routes.dart';
import 'package:petworld_app/core/theme/app_theme.dart';
import 'package:petworld_app/core/utils/formatters.dart';
import 'package:petworld_app/features/house/domain/entities/house.dart';
import 'package:petworld_app/features/house/presentation/state/house_providers.dart';
import 'package:petworld_app/features/pets/presentation/state/pet_list_notifier.dart';
import 'package:petworld_app/features/pets/presentation/widgets/pet_tile.dart';
import 'package:petworld_app/shared/widgets/empty_state.dart';
import 'package:petworld_app/shared/widgets/info_pill.dart';

class MyHouseScreen extends ConsumerWidget {
  const MyHouseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final house = ref.watch(myHouseProvider).value;
    if (house == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final petsAsync = ref.watch(petListProvider(house.id));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _HouseHeader(
              house: house,
              petCount: petsAsync.value?.length ?? 0,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Thú cưng của bạn',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          ...petsAsync.when(
            data: (pets) => pets.isEmpty
                ? const [
                    SliverToBoxAdapter(
                      child: EmptyState(
                        emoji: '🐶',
                        title: 'Chưa có thú cưng nào',
                        message: 'Thêm bé đầu tiên để mọi người cùng ngắm nhé!',
                      ),
                    ),
                  ]
                : [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                      sliver: SliverGrid.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.74,
                            ),
                        itemCount: pets.length,
                        itemBuilder: (context, index) =>
                            PetTile(pet: pets[index]),
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
                child: Text('Không tải được danh sách: $error'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addPet),
        icon: const Icon(Icons.add),
        label: const Text('Thêm thú cưng'),
      ),
    );
  }
}

class _HouseHeader extends StatelessWidget {
  const _HouseHeader({required this.house, required this.petCount});

  final House house;
  final int petCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    // Chỉ chủ nhà thấy được con số này.
    final offsetMeters = house.realLocation
        .distanceTo(house.displayLocation)
        .round();
    final pillColor = colors.surface.withValues(alpha: 0.75);

    return Container(
      margin: EdgeInsets.fromLTRB(
        16,
        MediaQuery.paddingOf(context).top + 12,
        16,
        0,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.softGradient(colors),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🏡', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 8),
          Text(house.name, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InfoPill(
                leading: const Text('🐾'),
                label: '$petCount thú cưng',
                color: pillColor,
              ),
              InfoPill(
                leading: const Text('📅'),
                label: 'Từ ${formatDate(house.createdAt)}',
                color: pillColor,
              ),
              InfoPill(
                leading: const Text('🔒'),
                label: 'Công khai lệch $offsetMeters m',
                color: pillColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
