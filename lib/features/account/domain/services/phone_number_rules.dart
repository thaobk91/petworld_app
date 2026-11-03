import 'package:petworld_app/core/error/failures.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

/// Kiểm tra số điện thoại theo quốc gia người dùng chọn. Chỉ nhận số di
/// động, vì sau này sẽ gửi mã xác minh (OTP) qua SMS.
abstract final class PhoneNumberRules {
  /// Lỗi để hiện cho người dùng, null nếu hợp lệ.
  static String? validate(String input, IsoCode country) {
    if (input.trim().isEmpty) return 'Hãy nhập số điện thoại';
    if (_parseMobile(input, country) == null) {
      return 'Số điện thoại di động không đúng';
    }
    return null;
  }

  /// Đổi số người dùng nhập (vd "0912 345 678", quốc gia VN) sang dạng quốc
  /// tế E.164 ("+84912345678"). Ném [ValidationFailure] nếu không hợp lệ.
  static String toE164(String input, IsoCode country) {
    if (validate(input, country) case final error?) {
      throw ValidationFailure(error);
    }
    return _parseMobile(input, country)!.international;
  }

  static PhoneNumber? _parseMobile(String input, IsoCode country) {
    try {
      final phone = PhoneNumber.parse(input, destinationCountry: country);
      final valid =
          phone.isoCode == country &&
          phone.isValid(type: PhoneNumberType.mobile);
      return valid ? phone : null;
    } on PhoneNumberException {
      return null;
    }
  }
}
