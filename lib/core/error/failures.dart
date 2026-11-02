/// Lỗi nghiệp vụ, có thông điệp hiện thẳng cho người dùng được.
class Failure implements Exception {
  const Failure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Dữ liệu nhập vào vi phạm quy tắc nghiệp vụ.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Không lấy được vị trí: GPS tắt, không có quyền, hoặc hết thời gian chờ.
class LocationFailure extends Failure {
  const LocationFailure(super.message);
}
