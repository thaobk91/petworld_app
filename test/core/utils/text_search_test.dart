import 'package:flutter_test/flutter_test.dart';
import 'package:petworld_app/core/utils/text_search.dart';

void main() {
  test('bỏ dấu tiếng Việt và chuyển chữ thường', () {
    expect(foldForSearch('Việt Nam'), 'viet nam');
    expect(foldForSearch('Đức'), 'duc');
    expect(foldForSearch('ẤN ĐỘ'), 'an do');
    expect(foldForSearch('Thổ Nhĩ Kỳ'), 'tho nhi ky');
  });

  test('bỏ dấu của các chữ Latin khác', () {
    expect(foldForSearch('Curaçao'), 'curacao');
    expect(foldForSearch('São Tomé'), 'sao tome');
  });

  test('giữ nguyên chữ số và ký tự không có dấu', () {
    expect(foldForSearch('+84 abc'), '+84 abc');
  });
}
