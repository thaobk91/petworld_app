import 'package:flutter/material.dart';

/// Bảng màu của app: màu gốc để Material tạo cả bộ màu.
class AppPalette {
  const AppPalette({required this.name, required this.seed});

  /// Xanh lá cây: tươi, gợi cảm giác cỏ cây. Đang dùng.
  static const leafGreen = AppPalette(
    name: 'Xanh lá cây',
    seed: Color(0xFF5DBB63),
  );

  // Hai bảng màu để sẵn, đang tắt. Muốn dùng thì đổi [current].
  static const coral = AppPalette(name: 'Cam san hô', seed: Color(0xFFF2784B));
  static const deepBlue = AppPalette(
    name: 'Xanh dương đậm',
    seed: Color(0xFF2F5DA8),
  );

  /// Bảng màu app đang dùng.
  static const current = leafGreen;

  final String name;

  /// Với scheme `fidelity`, `primaryContainer` (nút chính, FAB) gần như đúng
  /// màu này.
  final Color seed;
}

abstract final class AppTheme {
  /// App luôn dùng giao diện sáng (xem `PetWorldApp`).
  static ThemeData light([AppPalette palette = AppPalette.current]) => _build(
    ColorScheme.fromSeed(
      seedColor: palette.seed,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    ),
  );

  /// Giao diện tối, đang tắt. Giữ lại để bật lại sau.
  static ThemeData dark([AppPalette palette = AppPalette.current]) => _build(
    ColorScheme.fromSeed(
      seedColor: palette.seed,
      brightness: Brightness.dark,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    ),
  );

  /// Nền chuyển màu nhẹ cho phần đầu trang, từ màu nút chính sang màu phụ cùng
  /// tông. Với xanh lá cây: xanh lá sang xanh nhạt.
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
        // Nền đúng màu gốc, chữ cùng tông đậm (giống FAB). `primary` của
        // scheme fidelity đậm hơn nhiều (xanh lá: xanh rừng #006E22), nhìn
        // nặng nề khi làm nút lớn.
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
        // Icon tab đang chọn nằm trên nền primaryContainer, nên dùng màu chữ
        // đi kèm. Mặc định của Material ra màu sáng, chìm vào nền ở giao
        // diện tối.
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? colors.onPrimaryContainer
                : colors.onSurfaceVariant,
          ),
        ),
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
