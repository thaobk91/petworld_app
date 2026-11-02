import 'package:flutter/material.dart';

/// Viên thông tin nhỏ bo tròn, vd "🎂 2 tuổi" hay "🐾 3 thú cưng".
class InfoPill extends StatelessWidget {
  const InfoPill({
    super.key,
    required this.leading,
    required this.label,
    this.color,
  });

  /// Thường là emoji (`Text`) hoặc `Icon` cỡ 18.
  final Widget leading;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
