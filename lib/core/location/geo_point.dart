import 'dart:math';

/// Một điểm trên Trái Đất, tính bằng độ.
class GeoPoint {
  const GeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  static const _earthRadiusMeters = 6371000.0;
  static const _metersPerDegree = _earthRadiusMeters * pi / 180;

  /// Khoảng cách tới [other] theo công thức haversine, tính bằng mét.
  double distanceTo(GeoPoint other) {
    final dLat = _toRadians(other.latitude - latitude);
    final dLng = _toRadians(other.longitude - longitude);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(latitude)) *
            cos(_toRadians(other.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    return 2 * _earthRadiusMeters * asin(sqrt(a));
  }

  /// Điểm cách điểm này [distanceMeters] mét theo hướng [bearingRadians]
  /// (0 là hướng bắc, tăng theo chiều kim đồng hồ). Tính xấp xỉ trên mặt
  /// phẳng, đủ chính xác với khoảng cách vài trăm mét.
  GeoPoint offset({
    required double distanceMeters,
    required double bearingRadians,
  }) {
    final dLat = distanceMeters * cos(bearingRadians) / _metersPerDegree;
    final dLng =
        distanceMeters *
        sin(bearingRadians) /
        (_metersPerDegree * cos(_toRadians(latitude)));
    return GeoPoint(latitude + dLat, longitude + dLng);
  }

  static double _toRadians(double degrees) => degrees * pi / 180;

  @override
  bool operator ==(Object other) =>
      other is GeoPoint &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'GeoPoint($latitude, $longitude)';
}
