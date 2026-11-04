import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petworld_app/core/error/failures.dart';
import 'package:petworld_app/core/router/app_routes.dart';
import 'package:petworld_app/features/community/domain/entities/community_group.dart';
import 'package:petworld_app/features/community/domain/usecases/create_group.dart';
import 'package:petworld_app/features/community/presentation/state/community_providers.dart';
import 'package:petworld_app/features/community/presentation/widgets/group_widgets.dart';
import 'package:petworld_app/shared/widgets/note_card.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  GroupTopic _topic = GroupTopic.dogs;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Quy tắc nghiệp vụ nằm trong use case CreateGroup.
  Future<void> _create() async {
    setState(() => _saving = true);
    try {
      final group = await ref
          .read(communityProvider.notifier)
          .createGroup(
            GroupDraft(
              name: _nameController.text,
              topic: _topic,
              description: _descriptionController.text,
            ),
          );
      // Tạo xong vào thẳng nhóm, nút Back quay về tab Cộng đồng.
      if (mounted) context.pushReplacement(AppRoutes.groupDetail(group.id));
    } on ValidationFailure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Tạo nhóm')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Center(child: GroupAvatar(topic: _topic, size: 88)),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    maxLength: CreateGroup.maxNameLength,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Tên nhóm',
                      hintText: 'vd: Hội corgi Hà Nội',
                      prefixIcon: Icon(Icons.groups_outlined),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Chủ đề', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final topic in GroupTopic.values)
                        ChoiceChip(
                          avatar: Text(topic.emoji),
                          showCheckmark: false,
                          label: Text(topic.label),
                          selected: _topic == topic,
                          onSelected: (_) => setState(() => _topic = topic),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _descriptionController,
                    minLines: 3,
                    maxLines: 5,
                    maxLength: CreateGroup.maxDescriptionLength,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Mô tả (không bắt buộc)',
                      hintText: 'Nhóm này dành cho ai, nói về chuyện gì?',
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const NoteCard(
            emoji: '🌱',
            title: 'Nhóm đang lưu trên máy bạn',
            message:
                'Khi PetWorld có máy chủ, mọi người sẽ tìm thấy và tham gia '
                'nhóm của bạn được.',
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton.icon(
          onPressed: _saving ? null : _create,
          icon: const Icon(Icons.check_rounded),
          label: const Text('Tạo nhóm'),
        ),
      ),
    );
  }
}
