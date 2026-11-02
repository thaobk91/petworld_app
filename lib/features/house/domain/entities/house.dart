import 'package:petworld_app/core/location/geo_point.dart';

class House {
  const House({
    required this.id,
    required this.name,
    required this.realLocation,
    required this.displayLocation,
    required this.createdAt,
  });

  final String id;
  final String name;

  /// Vị trí thật. Chỉ chủ nhà được thấy, không bao giờ hiện trên bản đồ
  /// công khai.
  final GeoPoint realLocation;

  /// Vị trí công khai, lệch ngẫu nhiên so với vị trí thật. Chỉ tạo một lần
  /// lúc đăng ký nhà.
  final GeoPoint displayLocation;

  final DateTime createdAt;
}
