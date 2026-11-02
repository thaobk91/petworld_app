import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:petworld_app/core/location/geo_point.dart';

void main() {
  test('0.001 độ vĩ là khoảng 111 m', () {
    const a = GeoPoint(21.0, 105.8);
    const b = GeoPoint(21.001, 105.8);

    expect(a.distanceTo(b), closeTo(111.19, 0.05));
  });

  test('dời đi một khoảng rồi đo lại thì ra đúng khoảng đó', () {
    const origin = GeoPoint(21.0285, 105.8542);

    for (final bearing in [0.0, pi / 3, pi, 5 * pi / 4]) {
      final moved = origin.offset(distanceMeters: 150, bearingRadians: bearing);
      expect(origin.distanceTo(moved), closeTo(150, 0.5));
    }
  });
}
