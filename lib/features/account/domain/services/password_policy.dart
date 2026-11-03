/// Các yêu cầu mật khẩu phải đạt. Màn hình đăng ký hiện thành danh sách để
/// người dùng thấy còn thiếu gì.
enum PasswordRequirement {
  minLength('Ít nhất ${PasswordPolicy.minLength} ký tự'),
  letter('Có chữ cái'),
  digit('Có chữ số'),
  special('Có ký tự đặc biệt, vd ! @ # \$ %');

  const PasswordRequirement(this.label);

  final String label;

  static final _letter = RegExp(r'\p{L}', unicode: true);
  static final _digit = RegExp(r'[0-9]');
  // Ký tự đặc biệt: mọi thứ không phải chữ, số hay khoảng trắng.
  static final _special = RegExp(r'[^\p{L}\p{N}\s]', unicode: true);

  bool isMetBy(String password) => switch (this) {
    minLength => password.runes.length >= PasswordPolicy.minLength,
    letter => _letter.hasMatch(password),
    digit => _digit.hasMatch(password),
    special => _special.hasMatch(password),
  };
}

abstract final class PasswordPolicy {
  static const minLength = 8;
  static const maxLength = 64;

  /// Lỗi để hiện cho người dùng, null nếu mật khẩu đạt mọi yêu cầu.
  static String? validate(String password) {
    if (password.isEmpty) return 'Hãy nhập mật khẩu';
    if (password.runes.length > maxLength) {
      return 'Mật khẩu tối đa $maxLength ký tự';
    }
    for (final requirement in PasswordRequirement.values) {
      if (requirement.isMetBy(password)) continue;
      return switch (requirement) {
        PasswordRequirement.minLength =>
          'Mật khẩu cần ít nhất $minLength ký tự',
        PasswordRequirement.letter => 'Mật khẩu cần có chữ cái',
        PasswordRequirement.digit => 'Mật khẩu cần có chữ số',
        PasswordRequirement.special =>
          'Mật khẩu cần có ít nhất 1 ký tự đặc biệt',
      };
    }
    return null;
  }

  /// Lỗi khi ô "Nhập lại mật khẩu" không khớp, null nếu khớp.
  static String? validateConfirmation(String password, String confirmation) {
    if (confirmation.isEmpty) return 'Hãy nhập lại mật khẩu';
    if (confirmation != password) return 'Mật khẩu nhập lại không khớp';
    return null;
  }
}
