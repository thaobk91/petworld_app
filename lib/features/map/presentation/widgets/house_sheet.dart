import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petworld_app/core/router/app_routes.dart';
import 'package:petworld_app/features/house/domain/entities/house.dart';
import 'package:petworld_app/features/pets/presentation/state/pet_list_notifier.dart';
import 'package:petworld_app/features/pets/presentation/widgets/pet_avatar.dart';

/// Hiện khi chạm vào một ngôi nhà trên bản đồ: tên nhà và các bé thú cưng.
class HouseSheet extends ConsumerWidget {
  const HouseSheet({super.key, required this.house});

  final House house;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final petsAsync = ref.watch(petListProvider(house.id));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🏠', style: TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(house.name, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 2),
                      Text(
                        '📍 Vị trí gần đúng, trong bán kính 200 m',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Thú cưng trong nhà', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            petsAsync.when(
              data: (pets) => pets.isEmpty
                  ? Text(
                      'Nhà này chưa có thú cưng nào',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    )
                  : SizedBox(
                      height: 108,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: pets.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final pet = pets[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              final router = GoRouter.of(context);
                              Navigator.pop(context);
                              router.push(AppRoutes.petDetail(pet.id));
                            },
                            child: SizedBox(
                              width: 80,
                              child: Column(
                                children: [
                                  PetAvatar(
                                    path: pet.avatarPath,
                                    species: pet.species,
                                    radius: 34,
                                    ring: true,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    pet.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelLarge,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Không tải được: $error'),
            ),
          ],
        ),
      ),
    );
  }
}
