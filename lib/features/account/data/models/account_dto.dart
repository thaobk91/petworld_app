import 'package:petworld_app/features/account/domain/entities/account.dart';

/// Tên khoá viết kiểu snake_case cho khớp với cột của bảng khi lên backend.
/// Mã băm mật khẩu chỉ nằm ở lớp data, không đưa lên entity.
class AccountDto {
  const AccountDto({
    required this.id,
    required this.phoneNumber,
    required this.passwordHash,
    required this.createdAt,
  });

  factory AccountDto.fromJson(Map<String, dynamic> json) => AccountDto(
    id: json['id'] as String,
    phoneNumber: json['phone_number'] as String,
    passwordHash: json['password_hash'] as String,
    createdAt: json['created_at'] as String,
  );

  final String id;
  final String phoneNumber;
  final String passwordHash;
  final String createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'phone_number': phoneNumber,
    'password_hash': passwordHash,
    'created_at': createdAt,
  };

  Account toEntity() => Account(
    id: id,
    phoneNumber: phoneNumber,
    createdAt: DateTime.parse(createdAt),
  );
}
