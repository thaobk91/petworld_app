import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:petworld_app/core/security/password_hasher.dart';

void main() {
  group('pbkdf2Sha256 khớp vector chuẩn', () {
    // Kết quả đối chiếu bằng hashlib.pbkdf2_hmac của Python.
    String derive(String password, String salt, int rounds, int length) =>
        pbkdf2Sha256(
          utf8.encode(password),
          utf8.encode(salt),
          rounds,
          length,
        ).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

    test('1 vòng', () {
      expect(
        derive('password', 'salt', 1, 32),
        '120fb6cffcf8b32c43e7225256c4f837a86548c92ccc35480805987cb70be17b',
      );
    });

    test('4096 vòng', () {
      expect(
        derive('password', 'salt', 4096, 32),
        'c5e478d59288c841aa530db6845c4c8d962893a001ce4e11a4963873aa98134a',
      );
    });

    test('khoá dài hơn một khối SHA-256', () {
      expect(
        derive(
          'passwordPASSWORDpassword',
          'saltSALTsaltSALTsaltSALTsaltSALTsalt',
          4096,
          40,
        ),
        '348c89dbcbd32b2f32d814b8116e84cf2b17347ebc1800181c4e2a1fb8dd53e1'
        'c635518c7dac47e9',
      );
    });

    test('mật khẩu có dấu tiếng Việt', () {
      expect(
        derive('Mèo@123', 'salt', 2, 32),
        '5593f4355c19ac7a948592a83ccb4ffe0367e3e32e9196b704fa5db3b1ed83ea',
      );
    });
  });

  group('Pbkdf2PasswordHasher', () {
    final hasher = Pbkdf2PasswordHasher(iterations: 1000, random: Random(1));

    test(
      'không lưu mật khẩu nguyên văn, ghi kèm thuật toán và số vòng',
      () async {
        final encoded = await hasher.hash('Milu@2026');

        expect(encoded, isNot(contains('Milu@2026')));
        expect(encoded, startsWith(r'pbkdf2-sha256$1000$'));
        expect(encoded.split(r'$'), hasLength(4));
      },
    );

    test('kiểm tra đúng mật khẩu đã băm', () async {
      final encoded = await hasher.hash('Milu@2026');

      expect(await hasher.verify('Milu@2026', encoded), isTrue);
      expect(await hasher.verify('milu@2026', encoded), isFalse);
      expect(await hasher.verify('', encoded), isFalse);
    });

    test('cùng mật khẩu nhưng salt khác nhau thì mã băm khác nhau', () async {
      final first = await hasher.hash('Milu@2026');
      final second = await hasher.hash('Milu@2026');

      expect(first, isNot(second));
      expect(await hasher.verify('Milu@2026', second), isTrue);
    });

    test('vẫn kiểm tra được mã băm cũ khi đổi số vòng lặp', () async {
      final encoded = await hasher.hash('Milu@2026');
      final stronger = Pbkdf2PasswordHasher(iterations: 5000);

      expect(await stronger.verify('Milu@2026', encoded), isTrue);
    });

    test('chuỗi mã băm hỏng thì trả về false', () async {
      expect(await hasher.verify('Milu@2026', 'abc'), isFalse);
      expect(await hasher.verify('Milu@2026', r'md5$1$a$b'), isFalse);
      expect(
        await hasher.verify('Milu@2026', r'pbkdf2-sha256$0$AA==$AA=='),
        isFalse,
      );
    });
  });
}
