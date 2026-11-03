import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Ảnh ghim ngôi nhà để MapLibre tự vẽ trên bản đồ: ô bo tròn nổi khối có
/// mái nhà ở giữa, các bé thú cưng ngồi ở góc, bóng đổ dưới chân. Điểm dưới
/// cùng giữa ảnh là toạ độ của ngôi nhà (`icon-anchor: bottom`).
///
/// Vẽ thành ảnh thay vì đặt widget Flutter đè lên bản đồ, vì widget đè lên phải
/// tính lại vị trí mỗi khi bản đồ di chuyển nên bị trễ và tốn pin.
abstract final class HouseMarkerIcon {
  /// Kích thước ảnh tính theo điểm logic.
  static const size = Size(84, 82);

  static const _bubble = 56.0;
  static const _depth = 6.0;

  /// Tên ảnh trong style. Ảnh giống nhau thì dùng chung một tên. Có mã màu
  /// theme để đổi theme thì ảnh được vẽ lại.
  static String imageName({
    required bool isMine,
    required List<String> pets,
    required ColorScheme colors,
  }) =>
      'pw-house-${isMine ? 'mine' : 'other'}-'
      '${colors.primaryContainer.toARGB32().toRadixString(16)}-'
      '${pets.join('_')}';

  static Future<Uint8List> render({
    required bool isMine,
    required List<String> pets,
    required ColorScheme colors,
    required double pixelRatio,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(pixelRatio);

    // Lấy theo màu nút chính của theme: viền sáng hơn, mặt dưới đậm hơn.
    final accent = colors.primaryContainer;
    final fill = isMine ? accent : Colors.white;
    final border = isMine
        ? Color.lerp(accent, Colors.white, 0.25)!
        : Color.lerp(accent, Colors.white, 0.75)!;
    final depth = isMine
        ? Color.lerp(accent, colors.primary, 0.35)!
        : Color.lerp(accent, Colors.white, 0.45)!;
    final left = (size.width - _bubble) / 2;
    const top = 4.0;

    // Bóng đổ hình bầu dục dưới chân, đáy ảnh chính là toạ độ ngôi nhà.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height - 5),
        width: 40,
        height: 9,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // Mặt dưới đậm hơn, nhìn như khối nổi.
    final face = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, _bubble, _bubble),
      const Radius.circular(18),
    );
    canvas
      ..drawRRect(face.shift(const Offset(0, _depth)), Paint()..color = depth)
      ..drawRRect(face, Paint()..color = fill)
      ..drawRRect(
        face.deflate(1.5),
        Paint()
          ..color = border
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );

    _paintEmoji(canvas, '🏡', 30, face.center);

    // Tối đa 3 bé, xếp từ góc phải dưới sang trái, bé sau đè bé trước.
    final shown = pets.take(3).toList();
    for (var i = 0; i < shown.length; i++) {
      final center = Offset(left + _bubble + 2 - i * 17, top + _bubble - 2);
      canvas.drawCircle(center, 12, Paint()..color = Colors.white);
      _paintEmoji(canvas, shown[i], 16, center);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      (size.width * pixelRatio).ceil(),
      (size.height * pixelRatio).ceil(),
    );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    picture.dispose();
    return data!.buffer.asUint8List();
  }

  static void _paintEmoji(
    Canvas canvas,
    String emoji,
    double fontSize,
    Offset center,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(fontSize: fontSize, height: 1),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter
      ..paint(canvas, center - Offset(painter.width / 2, painter.height / 2))
      ..dispose();
  }
}
