import 'package:petworld_app/core/location/geo_point.dart';

/// Cách đã lấy được vị trí, theo thứ tự thử: GPS → Wi-Fi → mạng di động.
///
/// Android và iOS không tách riêng Wi-Fi với trạm di động. [wifi] là định vị
/// qua mạng, hệ điều hành ưu tiên Wi-Fi nhưng vẫn có thể dùng trạm di động.
/// [cellular] là chế độ tiết kiệm pin, chủ yếu dựa vào trạm di động (LTE),
/// sai số có thể tới vài km.
enum LocationMethod { gps, wifi, cellular }

class LocationFix {
  const LocationFix({
    required this.point,
    required this.accuracyMeters,
    required this.method,
  });

  final GeoPoint point;

  /// Bán kính sai số do hệ điều hành báo, tính bằng mét. Null khi hệ điều
  /// hành không đo được.
  final double? accuracyMeters;

  final LocationMethod method;
}
