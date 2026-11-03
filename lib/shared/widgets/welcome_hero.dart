import 'package:flutter/material.dart';
import 'package:petworld_app/core/theme/app_theme.dart';

/// Phần đầu trang có nền chuyển màu, dùng cho các màn hình chào mừng (đăng
/// ký tài khoản, đăng ký nhà). Tự chừa chỗ cho thanh trạng thái.
class WelcomeHero extends StatelessWidget {
  const WelcomeHero({
    super.key,
    required this.emoji,
    required this.title,
    required this.message,
  });

  final String emoji;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        MediaQuery.paddingOf(context).top + 28,
        24,
        28,
      ),
      decoration: BoxDecoration(
        gradient: AppTheme.softGradient(colors),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 16),
          Text(title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
