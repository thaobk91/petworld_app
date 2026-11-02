import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petworld_app/core/error/failures.dart';
import 'package:petworld_app/core/utils/formatters.dart';
import 'package:petworld_app/features/house/presentation/state/house_providers.dart';
import 'package:petworld_app/features/pets/domain/entities/pet.dart';
import 'package:petworld_app/features/pets/presentation/state/pet_list_notifier.dart';
import 'package:petworld_app/features/pets/presentation/widgets/pet_avatar.dart';
import 'package:petworld_app/features/pets/presentation/widgets/pet_labels.dart';
import 'package:petworld_app/shared/widgets/pick_photo.dart';

class AddPetScreen extends ConsumerStatefulWidget {
  const AddPetScreen({super.key});

  @override
  ConsumerState<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends ConsumerState<AddPetScreen> {
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _descriptionController = TextEditingController();
  PetSpecies _species = PetSpecies.dog;
  PetGender _gender = PetGender.unknown;
  DateTime? _birthDate;
  String? _avatarPath;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final path = await pickPhoto(context, ref);
    if (path != null && mounted) setState(() => _avatarPath = path);
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? now,
      firstDate: DateTime(now.year - 40),
      lastDate: now,
    );
    if (picked != null && mounted) setState(() => _birthDate = picked);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // Màn hình chỉ đổi chữ thành số. Quy tắc nghiệp vụ nằm trong use case AddPet.
  Future<void> _save(String houseId) async {
    final weightText = _weightController.text.trim().replaceAll(',', '.');
    final weight = weightText.isEmpty ? null : double.tryParse(weightText);
    if (weightText.isNotEmpty && weight == null) {
      _showError('Cân nặng phải là một con số');
      return;
    }

    setState(() => _saving = true);
    try {
      await ref
          .read(petListProvider(houseId).notifier)
          .addPet(
            PetDraft(
              houseId: houseId,
              name: _nameController.text,
              species: _species,
              gender: _gender,
              breed: _breedController.text,
              birthDate: _birthDate,
              weightKg: weight,
              description: _descriptionController.text,
              avatarSourcePath: _avatarPath,
            ),
          );
      if (mounted) context.pop();
    } on ValidationFailure catch (e) {
      if (mounted) _showError(e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final house = ref.watch(myHouseProvider).value;
    final theme = Theme.of(context);
    final birthDate = _birthDate;

    return Scaffold(
      appBar: AppBar(title: const Text('Thêm thú cưng')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Center(
            child: _AvatarPicker(
              path: _avatarPath,
              species: _species,
              onTap: _pickAvatar,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chạm để chọn ảnh đại diện',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          _FormSection(
            title: 'Thông tin cơ bản',
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên',
                  hintText: 'vd: Milu',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 18),
              Text('Loài', style: theme.textTheme.titleSmall),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final species in PetSpecies.values)
                    ChoiceChip(
                      avatar: Text(species.emoji),
                      showCheckmark: false,
                      label: Text(species.label),
                      selected: _species == species,
                      onSelected: (_) => setState(() => _species = species),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Text('Giới tính', style: theme.textTheme.titleSmall),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<PetGender>(
                  showSelectedIcon: false,
                  segments: [
                    for (final gender in PetGender.values)
                      ButtonSegment(
                        value: gender,
                        icon: Icon(gender.icon, color: gender.color),
                        label: Text(gender.label),
                      ),
                  ],
                  selected: {_gender},
                  onSelectionChanged: (selection) =>
                      setState(() => _gender = selection.first),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _FormSection(
            title: 'Chi tiết',
            subtitle: 'Không bắt buộc',
            children: [
              TextField(
                controller: _breedController,
                decoration: const InputDecoration(
                  labelText: 'Giống',
                  hintText: 'vd: Poodle, Mèo Anh lông ngắn',
                  prefixIcon: Icon(Icons.pets),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _pickBirthDate,
                child: InputDecorator(
                  isEmpty: birthDate == null,
                  decoration: const InputDecoration(
                    labelText: 'Ngày sinh',
                    prefixIcon: Icon(Icons.cake_outlined),
                    suffixIcon: Icon(Icons.edit_calendar_outlined),
                  ),
                  child: birthDate == null ? null : Text(formatDate(birthDate)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Cân nặng',
                  suffixText: 'kg',
                  prefixIcon: Icon(Icons.monitor_weight_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Giới thiệu',
                  hintText: 'Tính cách, sở thích, món khoái khẩu...',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton.icon(
          onPressed: house == null || _saving ? null : () => _save(house.id),
          icon: const Icon(Icons.check_rounded),
          label: const Text('Lưu thú cưng'),
        ),
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.path,
    required this.species,
    required this.onTap,
  });

  final String? path;
  final PetSpecies species;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: 'Chọn ảnh đại diện',
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            PetAvatar(path: path, species: species, radius: 56, ring: true),
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.surface, width: 3),
                ),
                child: Icon(
                  Icons.photo_camera_rounded,
                  size: 18,
                  color: colors.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    this.subtitle,
    required this.children,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = this.subtitle;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                if (subtitle != null) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
