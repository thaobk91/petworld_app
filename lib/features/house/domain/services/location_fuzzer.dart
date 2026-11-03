import 'dart:math';

import 'package:petworld_app/core/location/geo_point.dart';

/// Tạo vị trí công khai cho ngôi nhà: một điểm ngẫu nhiên cách vị trí thật
/// từ [minMeters] đến [maxMeters].
class LocationFuzzer {
  LocationFuzzer({
    Random? random,
    this.minMeters = 50,
    this.maxMeters = defaultMaxMeters,
  }) : _random = random ?? Random.secure();

  /// Vị trí thật luôn nằm trong bán kính này quanh vị trí công khai, nên bản
  /// đồ công khai vẽ vùng gần đúng của ngôi nhà với bán kính này.
  static const defaultMaxMeters = 200.0;

  final double minMeters;
  final double maxMeters;
  final Random _random;

  GeoPoint fuzz(GeoPoint real) {
    // Lấy căn bậc hai để điểm rải đều theo diện tích vành khuyên. Nếu random
    // thẳng khoảng cách thì điểm sẽ dồn về phía gần nhà thật.
    final minSquared = minMeters * minMeters;
    final distance = sqrt(
      minSquared + _random.nextDouble() * (maxMeters * maxMeters - minSquared),
    );
    final bearing = 2 * pi * _random.nextDouble();
    return real.offset(distanceMeters: distance, bearingRadians: bearing);
  }
}
