import 'dart:math';

import 'package:petworld_app/core/location/geo_point.dart';

/// Tạo vị trí công khai cho ngôi nhà: một điểm ngẫu nhiên cách vị trí thật
/// từ [minMeters] đến [maxMeters].
class LocationFuzzer {
  LocationFuzzer({Random? random, this.minMeters = 50, this.maxMeters = 200})
    : _random = random ?? Random.secure();

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
