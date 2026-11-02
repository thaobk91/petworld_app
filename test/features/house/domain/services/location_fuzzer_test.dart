import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:petworld_app/core/location/geo_point.dart';
import 'package:petworld_app/features/house/domain/services/location_fuzzer.dart';

void main() {
  const home = GeoPoint(21.0285, 105.8542);

  test('mọi điểm đều cách nhà thật từ 50 đến 200 m', () {
    final fuzzer = LocationFuzzer(random: Random(1));

    for (var i = 0; i < 2000; i++) {
      final distance = home.distanceTo(fuzzer.fuzz(home));
      expect(distance, inInclusiveRange(49.5, 200.5));
    }
  });

  test('điểm rải đều theo diện tích, không dồn về gần nhà thật', () {
    // Rải đều theo diện tích vành khuyên 50–200 m thì khoảng cách trung bình
    // là 140 m. Nếu random thẳng khoảng cách thì trung bình chỉ 125 m.
    final fuzzer = LocationFuzzer(random: Random(7));
    const samples = 20000;

    var total = 0.0;
    for (var i = 0; i < samples; i++) {
      total += home.distanceTo(fuzzer.fuzz(home));
    }

    expect(total / samples, closeTo(140, 2));
  });
}
