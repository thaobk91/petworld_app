import 'package:flutter/material.dart';

abstract final class AppTheme {
  /// Cam san hô: ấm áp, gợi cảm giác thân thiện với thú cưng.
  static const seed = Color(0xFFF2784B);

  static ThemeData light() => _build(
    ColorScheme.fromSeed(
      seedColor: seed,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    ),
  );

  static ThemeData dark() => _build(
    ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    ),
  );

  /// Nền chuyển màu nhẹ cho phần đầu trang, cùng một tông đào. Không trộn
  /// cam với xanh ngọc, vì ở giữa sẽ ra màu nâu xám.
  static LinearGradient softGradient(ColorScheme colors) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.alphaBlend(
        colors.primaryContainer.withValues(alpha: 0.55),
        colors.surface,
      ),
      Color.alphaBlend(
        colors.secondaryContainer.withValues(alpha: 0.5),
        colors.surface,
      ),
    ],
  );

  static ThemeData _build(ColorScheme colors) {
    final base = ThemeData(colorScheme: colors);
    final text = base.textTheme.copyWith(
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleSmall: base.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
    final rounded16 = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    // Kiểu "filled" bo tròn. Không dùng OutlineInputBorder: nó đặt nhãn nổi
    // lên mép trên, nhìn như rơi ra ngoài ô khi không có viền.
    final fieldBorder = UnderlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    );

    return base.copyWith(
      textTheme: text,
      scaffoldBackgroundColor: colors.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleTextStyle: text.titleLarge?.copyWith(color: colors.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: colors.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.6),
        border: fieldBorder,
        enabledBorder: fieldBorder,
        focusedBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        // Nền cam san hô, chữ nâu đậm (giống FAB). `primary` của scheme
        // fidelity là màu gỉ sắt, nhìn nặng nề khi làm nút lớn.
        style: FilledButton.styleFrom(
          backgroundColor: colors.primaryContainer,
          foregroundColor: colors.onPrimaryContainer,
          minimumSize: const Size.fromHeight(54),
          shape: rounded16,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          shape: rounded16,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(shape: const StadiumBorder()),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        extendedTextStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surfaceContainerLow,
        indicatorColor: colors.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w500,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        backgroundColor: colors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: rounded16,
      ),
    );
  }
}
