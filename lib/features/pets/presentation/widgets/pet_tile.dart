import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petworld_app/core/router/app_routes.dart';
import 'package:petworld_app/features/pets/domain/entities/pet.dart';
import 'package:petworld_app/features/pets/presentation/widgets/pet_labels.dart';

/// Thẻ thú cưng trong lưới: ảnh vuông ở trên, tên và loài ở dưới.
class PetTile extends StatelessWidget {
  const PetTile({super.key, required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatar = pet.avatarPath;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.petDetail(pet.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ảnh chiếm phần còn lại của ô, để chữ bên dưới không bị tràn
            // khi cỡ chữ hệ thống lớn.
            Expanded(
              child: avatar == null
                  ? ColoredBox(
                      color: pet.species.color,
                      child: Center(
                        child: Text(
                          pet.species.emoji,
                          style: const TextStyle(fontSize: 64),
                        ),
                      ),
                    )
                  : Image.file(
                      File(avatar),
                      fit: BoxFit.cover,
                      cacheWidth: 500,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pet.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (pet.gender != PetGender.unknown)
                        Icon(
                          pet.gender.icon,
                          size: 18,
                          color: pet.gender.color,
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pet.speciesAndBreed,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
