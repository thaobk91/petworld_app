import 'package:flutter/material.dart';
import 'package:petworld_app/core/error/failures.dart';
import 'package:petworld_app/core/utils/formatters.dart';
import 'package:petworld_app/features/community/domain/entities/group_post.dart';
import 'package:petworld_app/features/community/domain/usecases/add_group_post.dart';

enum _PostAction { delete }

/// Một bài viết trong nhóm. Bài của mình có menu "Xoá bài viết".
class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, this.onDelete});

  final GroupPost post;

  /// Null khi không phải bài của mình.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final onDelete = this.onDelete;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 4, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: colors.primaryContainer,
                  child: const Text('🏡', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        formatTimeAgo(post.createdAt, DateTime.now()),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onDelete != null)
                  // Dùng onSelected (chạy sau khi menu đóng), không dùng
                  // onTap của mục: onTap chạy trước khi menu đóng, lệnh đóng
                  // menu sẽ đóng nhầm hộp xác nhận vừa mở.
                  PopupMenuButton<_PostAction>(
                    tooltip: 'Tuỳ chọn bài viết',
                    onSelected: (_) => onDelete(),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: _PostAction.delete,
                        child: Text('Xoá bài viết'),
                      ),
                    ],
                  )
                else
                  const SizedBox(height: 48),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(post.text, style: theme.textTheme.bodyLarge),
            ),
          ],
        ),
      ),
    );
  }
}

/// Khung soạn bài dạng bottom sheet. [onSubmit] ném [ValidationFailure] thì
/// hiện lỗi ngay dưới ô nhập, còn đăng xong thì đóng sheet.
Future<void> showPostComposer(
  BuildContext context, {
  required String groupName,
  required Future<void> Function(String text) onSubmit,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _PostComposer(groupName: groupName, onSubmit: onSubmit),
);

class _PostComposer extends StatefulWidget {
  const _PostComposer({required this.groupName, required this.onSubmit});

  final String groupName;
  final Future<void> Function(String text) onSubmit;

  @override
  State<_PostComposer> createState() => _PostComposerState();
}

class _PostComposerState extends State<_PostComposer> {
  final _controller = TextEditingController();
  String? _error;
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await widget.onSubmit(_controller.text);
      if (mounted) Navigator.pop(context);
    } on ValidationFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      // Đẩy khung lên trên bàn phím.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Viết bài', style: theme.textTheme.titleLarge),
              const SizedBox(height: 2),
              Text(
                'Đăng vào ${widget.groupName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _controller,
                autofocus: true,
                minLines: 4,
                maxLines: 8,
                maxLength: AddGroupPost.maxLength,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Chia sẻ điều gì đó với nhóm...',
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _sending ? null : _submit,
                icon: const Icon(Icons.send_rounded),
                label: const Text('Đăng bài'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
