import 'package:flutter_test/flutter_test.dart';
import 'package:petworld_app/features/account/domain/services/password_policy.dart';

void main() {
  group('PasswordRequirement', () {
    Set<PasswordRequirement> unmet(String password) => {
      for (final r in PasswordRequirement.values)
        if (!r.isMetBy(password)) r,
    };

    test('mật khẩu đủ chữ, số, ký tự đặc biệt và độ dài thì đạt hết', () {
      expect(unmet('Milu@2026'), isEmpty);
    });

    test('báo đúng những yêu cầu còn thiếu', () {
      expect(unmet(''), PasswordRequirement.values.toSet());
      expect(unmet('milu2026'), {PasswordRequirement.special});
      expect(unmet('milu@cat'), {PasswordRequirement.digit});
      expect(unmet('2026@123'), {PasswordRequirement.letter});
      expect(unmet('Mi@1'), {PasswordRequirement.minLength});
    });

    test('chữ có dấu tiếng Việt cũng tính là chữ cái', () {
      expect(PasswordRequirement.letter.isMetBy('ư2026@@@'), isTrue);
    });

    test('khoảng trắng không tính là ký tự đặc biệt', () {
      expect(PasswordRequirement.special.isMetBy('milu 2026'), isFalse);
      expect(PasswordRequirement.special.isMetBy('milu_2026'), isTrue);
      expect(PasswordRequirement.special.isMetBy('milu😺2026'), isTrue);
    });

    test('độ dài đếm theo ký tự, không theo đơn vị UTF-16', () {
      // Emoji chiếm 2 đơn vị UTF-16 nhưng chỉ là 1 ký tự.
      expect(PasswordRequirement.minLength.isMetBy('a1😺😺😺😺'), isFalse);
      expect(PasswordRequirement.minLength.isMetBy('a1😺😺😺😺😺😺'), isTrue);
    });
  });

  group('PasswordPolicy.validate', () {
    test('mật khẩu hợp lệ thì không có lỗi', () {
      expect(PasswordPolicy.validate('Milu@2026'), isNull);
    });

    test(
      'báo lỗi cho mật khẩu trống, ngắn, thiếu số, thiếu ký tự đặc biệt',
      () {
        expect(PasswordPolicy.validate(''), 'Hãy nhập mật khẩu');
        expect(PasswordPolicy.validate('Mi@1'), 'Mật khẩu cần ít nhất 8 ký tự');
        expect(PasswordPolicy.validate('2026@123'), 'Mật khẩu cần có chữ cái');
        expect(PasswordPolicy.validate('milu@cat'), 'Mật khẩu cần có chữ số');
        expect(
          PasswordPolicy.validate('milu2026'),
          'Mật khẩu cần có ít nhất 1 ký tự đặc biệt',
        );
      },
    );

    test('từ chối mật khẩu dài quá giới hạn', () {
      final long = 'a1@${'x' * PasswordPolicy.maxLength}';
      expect(PasswordPolicy.validate(long), 'Mật khẩu tối đa 64 ký tự');
    });
  });

  test('nhập lại mật khẩu phải khớp', () {
    expect(
      PasswordPolicy.validateConfirmation('Milu@2026', 'Milu@2026'),
      isNull,
    );
    expect(
      PasswordPolicy.validateConfirmation('Milu@2026', 'Milu@2027'),
      'Mật khẩu nhập lại không khớp',
    );
    expect(
      PasswordPolicy.validateConfirmation('Milu@2026', ''),
      'Hãy nhập lại mật khẩu',
    );
  });
}
