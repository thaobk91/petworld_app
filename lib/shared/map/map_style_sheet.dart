import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petworld_app/shared/map/map_preferences.dart';

/// Bảng chọn kiểu bản đồ. Chọn xong bản đồ đổi ngay, lựa chọn được lưu lại.
Future<void> showMapStyleSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      // Mặc định sheet chỉ cao tối đa 9/16 màn hình, không đủ chỗ cho cả hai
      // thẻ và phần ánh sáng khi cỡ chữ lớn.
      isScrollControlled: true,
      builder: (_) => const MapStyleSheet(),
    );

class MapStyleSheet extends ConsumerWidget {
  const MapStyleSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final preferences = ref.watch(mapPreferencesProvider);
    final notifier = ref.read(mapPreferencesProvider.notifier);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Kiểu bản đồ', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (index, kind) in MapKind.values.indexed) ...[
                  if (index > 0) const SizedBox(width: 12),
                  Expanded(
                    child: _KindCard(
                      kind: kind,
                      selected: preferences.kind == kind,
                      onTap: () => notifier.setKind(kind),
                    ),
                  ),
                ],
              ],
            ),
            if (preferences.kind == MapKind.model) ...[
              const SizedBox(height: 20),
              Text('Ánh sáng', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<MapLighting>(
                segments: [
                  for (final lighting in MapLighting.values)
                    ButtonSegment(value: lighting, label: Text(lighting.label)),
                ],
                selected: {preferences.lighting},
                showSelectedIcon: false,
                onSelectionChanged: (selection) =>
                    notifier.setLighting(selection.single),
              ),
              const SizedBox(height: 6),
              Text(
                'Tự động: ban đêm từ ${MapPreferences.nightStartHour} giờ tối '
                'đến ${MapPreferences.nightEndHour} giờ sáng.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _KindCard extends StatelessWidget {
  const _KindCard({
    required this.kind,
    required this.selected,
    required this.onTap,
  });

  final MapKind kind;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected
            ? colors.primaryContainer.withValues(alpha: 0.45)
            : colors.surfaceContainerHighest.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selected ? colors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(kind.emoji, style: const TextStyle(fontSize: 28)),
                    const Spacer(),
                    if (selected)
                      Icon(Icons.check_circle, color: colors.primary),
                  ],
                ),
                const SizedBox(height: 8),
                Text(kind.label, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  kind.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
