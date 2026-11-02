import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petworld_app/core/utils/formatters.dart';
import 'package:petworld_app/features/pets/domain/entities/pet.dart';
import 'package:petworld_app/features/pets/domain/entities/pet_photo.dart';
import 'package:petworld_app/features/pets/presentation/state/pet_detail_providers.dart';
import 'package:petworld_app/features/pets/presentation/widgets/pet_labels.dart';
import 'package:petworld_app/shared/widgets/info_pill.dart';
import 'package:petworld_app/shared/widgets/pick_photo.dart';

class PetDetailScreen extends ConsumerWidget {
  const PetDetailScreen({super.key, required this.petId});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(petProvider(petId))
        .when(
          data: (pet) => pet == null
              ? Scaffold(
                  appBar: AppBar(),
                  body: const Center(child: Text('Không tìm thấy thú cưng')),
                )
              : _PetDetailView(pet: pet),
          loading: () => Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Scaffold(
            appBar: AppBar(),
            body: Center(child: Text('Không tải được: $error')),
          ),
        );
  }
}

class _PetDetailView extends StatelessWidget {
  const _PetDetailView({required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final birthDate = pet.birthDate;
    final weight = pet.weightKg;
    final description = pet.description;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 300,
            backgroundColor: pet.species.color,
            leading: Padding(
              padding: const EdgeInsets.all(6),
              child: BackButton(
                style: IconButton.styleFrom(
                  backgroundColor: colors.surface.withValues(alpha: 0.85),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(background: _Cover(pet: pet)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pet.name, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 2),
                  Text(
                    pet.speciesAndBreed,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      InfoPill(
                        leading: Icon(
                          pet.gender.icon,
                          size: 18,
                          color: pet.gender.color,
                        ),
                        label: pet.gender.label,
                      ),
                      if (birthDate != null)
                        InfoPill(
                          leading: const Text('🎂'),
                          label: formatAge(birthDate, DateTime.now()),
                        ),
                      if (birthDate != null)
                        InfoPill(
                          leading: const Text('📅'),
                          label: formatDate(birthDate),
                        ),
                      if (weight != null)
                        InfoPill(
                          leading: const Text('⚖️'),
                          label: formatWeight(weight),
                        ),
                    ],
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Giới thiệu',
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 6),
                            Text(description, style: theme.textTheme.bodyLarge),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _PhotoSection(petId: pet.id),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ảnh bìa: ảnh đại diện phủ kín, chưa có ảnh thì emoji to trên nền pastel.
class _Cover extends StatelessWidget {
  const _Cover({required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    final avatar = pet.avatarPath;
    if (avatar != null) {
      return Image.file(File(avatar), fit: BoxFit.cover);
    }
    return ColoredBox(
      color: pet.species.color,
      child: Center(
        child: Text(pet.species.emoji, style: const TextStyle(fontSize: 120)),
      ),
    );
  }
}

class _PhotoSection extends ConsumerWidget {
  const _PhotoSection({required this.petId});

  final String petId;

  Future<void> _addPhoto(BuildContext context, WidgetRef ref) async {
    final path = await pickPhoto(context, ref);
    if (path == null || !context.mounted) return;
    await ref.read(petPhotosProvider(petId).notifier).addPhoto(path);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final photosAsync = ref.watch(petPhotosProvider(petId));
    final photos = photosAsync.value ?? const <PetPhoto>[];
    final addTile = _AddPhotoTile(onTap: () => _addPhoto(context, ref));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Bộ sưu tập ảnh', style: theme.textTheme.titleLarge),
            ),
            if (photos.isNotEmpty)
              Text(
                '${photos.length} ảnh',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (photosAsync.isLoading && photos.isEmpty)
          const Center(child: CircularProgressIndicator())
        else if (photos.isEmpty)
          Row(
            children: [
              SizedBox.square(dimension: 96, child: addTile),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Chưa có ảnh nào', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      'Lưu lại những khoảnh khắc đáng yêu của bé nhé!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        else
          GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              addTile,
              for (final photo in photos)
                _PhotoThumb(
                  path: photo.path,
                  onTap: () => _openPhoto(context, photo.path),
                ),
            ],
          ),
      ],
    );
  }

  void _openPhoto(BuildContext context, String path) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(12),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(child: Image.file(File(path))),
        ),
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.primaryContainer.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colors.primary.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: colors.primary),
            const SizedBox(height: 4),
            Text(
              'Thêm ảnh',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({required this.path, required this.onTap});

  final String path;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(File(path), fit: BoxFit.cover, cacheWidth: 400),
      ),
    );
  }
}
