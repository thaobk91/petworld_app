class Account {
  const Account({
    required this.id,
    required this.phoneNumber,
    required this.createdAt,
  });

  final String id;

  /// Số điện thoại dạng quốc tế E.164, vd `+84912345678`.
  final String phoneNumber;

  final DateTime createdAt;
}
