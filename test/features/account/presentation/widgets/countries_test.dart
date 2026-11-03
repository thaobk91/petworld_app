import 'package:flutter_test/flutter_test.dart';
import 'package:petworld_app/features/account/presentation/widgets/countries.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

void main() {
  final vietnam = Country(IsoCode.VN);

  test('Việt Nam có tên, mã vùng, cờ và số mẫu', () {
    expect(vietnam.name, 'Việt Nam');
    expect(vietnam.dialCode, '+84');
    expect(vietnam.flag, '🇻🇳');
    expect(vietnam.exampleMobile, isNotEmpty);
  });

  test('mọi quốc gia đều có tên tiếng Việt và mã vùng', () {
    expect(allCountries, hasLength(IsoCode.values.length));
    for (final country in allCountries) {
      expect(
        country.name,
        isNot(country.isoCode.name),
        reason: country.isoCode.name,
      );
      expect(country.dialCode, matches(RegExp(r'^\+\d+$')));
    }
  });

  test('tìm theo tên không cần gõ dấu', () {
    expect(vietnam.matches('viet'), isTrue);
    expect(vietnam.matches('Việt'), isTrue);
    expect(Country(IsoCode.DE).matches('duc'), isTrue);
    expect(vietnam.matches('nhat'), isFalse);
  });

  test('tìm theo mã vùng, có hoặc không có dấu cộng', () {
    expect(vietnam.matches('84'), isTrue);
    expect(vietnam.matches('+84'), isTrue);
    expect(vietnam.matches('+8'), isTrue);
    expect(vietnam.matches('81'), isFalse);
  });

  test('tìm theo mã ISO', () {
    expect(vietnam.matches('vn'), isTrue);
  });

  test('danh sách xếp theo tên tiếng Việt', () {
    final names = allCountries.map((c) => c.name).toList();
    expect(names.indexOf('Đức'), lessThan(names.indexOf('Hàn Quốc')));
    expect(names.indexOf('Nhật Bản'), lessThan(names.indexOf('Việt Nam')));
  });
}
