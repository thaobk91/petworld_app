import 'dart:io';

import 'package:flutter/material.dart';
import 'package:petworld_app/features/pets/domain/entities/pet.dart';
import 'package:petworld_app/features/pets/presentation/widgets/pet_labels.dart';

/// Ảnh đại diện tròn. Chưa có ảnh thì hiện emoji của loài trên nền pastel.
class PetAvatar extends StatelessWidget {
  const PetAvatar({
    super.key,
    required this.path,
    required this.species,
    this.radius = 24,
    this.ring = false,
  });

  final String? path;
  final PetSpecies species;
  final double radius;

  /// Viền trắng có bóng, dùng khi avatar nằm trên nền màu hoặc bản đồ.
  final bool ring;

  @override
  Widget build(BuildContext context) {
    final path = this.path;
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: species.color,
      backgroundImage: path == null ? null : FileImage(File(path)),
      child: path == null
          ? Text(species.emoji, style: TextStyle(fontSize: radius * 0.95))
          : null,
    );
    if (!ring) return avatar;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surface,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: avatar,
    );
  }
}
