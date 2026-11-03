import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final passwordHasherProvider = Provider<PasswordHasher>(
  (ref) => Pbkdf2PasswordHasher(),
);

/// Băm mật khẩu một chiều trước khi lưu. Không bao giờ lưu mật khẩu nguyên
/// văn.
abstract interface class PasswordHasher {
  Future<String> hash(String password);

  /// [encoded] là chuỗi do [hash] trả về.
  Future<bool> verify(String password, String encoded);
}

/// PBKDF2-HMAC-SHA256 với salt ngẫu nhiên 16 byte. Kết quả ghi kèm thuật toán
/// và số vòng lặp (`pbkdf2-sha256$<vòng lặp>$<salt>$<mã băm>`, base64), để
/// sau này tăng số vòng lặp mà vẫn kiểm tra được mật khẩu cũ.
class Pbkdf2PasswordHasher implements PasswordHasher {
  Pbkdf2PasswordHasher({this.iterations = defaultIterations, Random? random})
    : _random = random ?? Random.secure();

  static const defaultIterations = 100000;
  static const _algorithm = 'pbkdf2-sha256';
  static const _saltLength = 16;
  static const _keyLength = 32;

  final int iterations;
  final Random _random;

  @override
  Future<String> hash(String password) async {
    final salt = List.generate(_saltLength, (_) => _random.nextInt(256));
    final key = await _derive(utf8.encode(password), salt, iterations);
    return [
      _algorithm,
      iterations,
      base64.encode(salt),
      base64.encode(key),
    ].join(r'$');
  }

  @override
  Future<bool> verify(String password, String encoded) async {
    final parts = encoded.split(r'$');
    if (parts.length != 4 || parts[0] != _algorithm) return false;
    final rounds = int.tryParse(parts[1]);
    if (rounds == null || rounds < 1) return false;

    final expected = base64.decode(parts[3]);
    final actual = await _derive(
      utf8.encode(password),
      base64.decode(parts[2]),
      rounds,
    );
    return _constantTimeEquals(actual, expected);
  }

  // Hàm static để closure gửi sang isolate không giữ `this`. Chạy ở isolate
  // riêng vì 100.000 vòng lặp đủ làm giao diện đứng hình.
  static Future<Uint8List> _derive(
    List<int> password,
    List<int> salt,
    int iterations,
  ) => Isolate.run(() => pbkdf2Sha256(password, salt, iterations, _keyLength));

  // So hết mọi byte, không dừng sớm, để thời gian chạy không lộ vị trí byte
  // sai đầu tiên.
  static bool _constantTimeEquals(List<int> a, List<int> b) {
    var diff = a.length ^ b.length;
    for (var i = 0; i < min(a.length, b.length); i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}

/// PBKDF2 với HMAC-SHA256 theo RFC 8018, mục 5.2.
Uint8List pbkdf2Sha256(
  List<int> password,
  List<int> salt,
  int iterations,
  int keyLength,
) {
  final hmac = Hmac(sha256, password);
  final output = BytesBuilder(copy: false);
  for (var block = 1; output.length < keyLength; block++) {
    var u = hmac.convert([
      ...salt,
      block >> 24 & 0xff,
      block >> 16 & 0xff,
      block >> 8 & 0xff,
      block & 0xff,
    ]).bytes;
    final t = Uint8List.fromList(u);
    for (var i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < t.length; j++) {
        t[j] ^= u[j];
      }
    }
    output.add(t);
  }
  return Uint8List.sublistView(output.takeBytes(), 0, keyLength);
}
