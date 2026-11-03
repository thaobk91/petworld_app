import 'package:flutter_test/flutter_test.dart';
import 'package:petworld_app/core/utils/formatters.dart';

void main() {
  test('ngày dạng dd/MM/yyyy', () {
    expect(formatDate(DateTime(2026, 3, 7)), '07/03/2026');
  });

  test('khoảng cách đổi sang km khi từ 1000 m trở lên', () {
    expect(formatDistance(7.6), '8 m');
    expect(formatDistance(350), '350 m');
    expect(formatDistance(1234), '1,2 km');
  });

  test('cân nặng dùng dấu phẩy thập phân, bỏ ",0"', () {
    expect(formatWeight(4.5), '4,5 kg');
    expect(formatWeight(5), '5 kg');
  });

  group('tuổi', () {
    final now = DateTime(2026, 11, 3);

    test('dưới 1 tháng', () {
      expect(formatAge(DateTime(2026, 10, 20), now), 'Dưới 1 tháng');
    });

    test('chỉ có tháng', () {
      expect(formatAge(DateTime(2026, 6, 3), now), '5 tháng');
    });

    test('chưa đủ ngày thì chưa tính tròn tháng', () {
      expect(formatAge(DateTime(2026, 6, 4), now), '4 tháng');
    });

    test('tròn năm', () {
      expect(formatAge(DateTime(2024, 11, 3), now), '2 tuổi');
    });

    test('năm và tháng', () {
      expect(formatAge(DateTime(2024, 8, 1), now), '2 tuổi 3 tháng');
    });
  });

  test('thời gian đăng bài', () {
    final now = DateTime(2026, 11, 3, 12);
    String ago(Duration elapsed) => formatTimeAgo(now.subtract(elapsed), now);

    expect(ago(const Duration(seconds: 30)), 'Vừa xong');
    expect(ago(const Duration(minutes: 5)), '5 phút trước');
    expect(ago(const Duration(hours: 3)), '3 giờ trước');
    expect(ago(const Duration(days: 2)), '2 ngày trước');
    expect(ago(const Duration(days: 10)), '24/10/2026');
    // Giờ máy lệch về sau thì coi như vừa đăng.
    expect(formatTimeAgo(now.add(const Duration(minutes: 1)), now), 'Vừa xong');
  });
}
