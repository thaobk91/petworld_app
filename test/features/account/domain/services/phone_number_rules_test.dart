import 'package:flutter_test/flutter_test.dart';
import 'package:petworld_app/core/error/failures.dart';
import 'package:petworld_app/features/account/domain/services/phone_number_rules.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

void main() {
  group('số di động Việt Nam', () {
    test('có hay không có số 0 đầu đều ra cùng dạng E.164', () {
      expect(PhoneNumberRules.toE164('0912345678', IsoCode.VN), '+84912345678');
      expect(PhoneNumberRules.toE164('912345678', IsoCode.VN), '+84912345678');
      expect(
        PhoneNumberRules.toE164('0912 345 678', IsoCode.VN),
        '+84912345678',
      );
    });

    test('nhận các đầu số di động mới', () {
      expect(PhoneNumberRules.validate('0389 123 456', IsoCode.VN), isNull);
      expect(PhoneNumberRules.validate('0868 123 456', IsoCode.VN), isNull);
    });

    test('từ chối số cố định, vì cần nhận được SMS', () {
      expect(
        PhoneNumberRules.validate('024 3826 1234', IsoCode.VN),
        'Số điện thoại di động không đúng',
      );
    });

    test('từ chối số thiếu hoặc thừa chữ số', () {
      expect(PhoneNumberRules.validate('09123', IsoCode.VN), isNotNull);
      expect(PhoneNumberRules.validate('091234567890', IsoCode.VN), isNotNull);
    });
  });

  test('kiểm tra theo quốc gia đang chọn', () {
    expect(
      PhoneNumberRules.toE164('090 1234 5678', IsoCode.JP),
      '+819012345678',
    );
    expect(PhoneNumberRules.toE164('201 555 0123', IsoCode.US), '+12015550123');
    // Số di động Việt Nam không hợp lệ khi đang chọn Nhật Bản.
    expect(PhoneNumberRules.validate('0912345678', IsoCode.JP), isNotNull);
  });

  test('ô trống thì nhắc nhập số', () {
    expect(
      PhoneNumberRules.validate('  ', IsoCode.VN),
      'Hãy nhập số điện thoại',
    );
  });

  test('toE164 ném ValidationFailure khi số sai', () {
    expect(
      () => PhoneNumberRules.toE164('123', IsoCode.VN),
      throwsA(isA<ValidationFailure>()),
    );
  });
}
