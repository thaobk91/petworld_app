import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petworld_app/features/house/domain/entities/house.dart';
import 'package:petworld_app/features/pets/presentation/state/pet_list_notifier.dart';
import 'package:petworld_app/shared/widgets/house_pin.dart';

/// Ghim ngôi nhà trên bản đồ, kèm số thú cưng trong nhà. Nhà của mình có màu
/// khác.
class HouseMarker extends ConsumerWidget {
  const HouseMarker({
    super.key,
    required this.house,
    required this.isMine,
    required this.onTap,
  });

  final House house;
  final bool isMine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final petCount = ref.watch(petListProvider(house.id)).value?.length ?? 0;

    return Tooltip(
      message: house.name,
      child: GestureDetector(
        onTap: onTap,
        child: HousePin(
          color: isMine ? colors.primaryContainer : colors.tertiary,
          badge: petCount > 0 ? '$petCount' : null,
        ),
      ),
    );
  }
}
