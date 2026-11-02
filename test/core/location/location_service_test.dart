import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:petworld_app/core/error/failures.dart';
import 'package:petworld_app/core/location/location_fix.dart';
import 'package:petworld_app/core/location/location_service.dart';

/// Mỗi mức chính xác trả về một kết quả, hoặc ném lỗi nếu [failures] có.
/// [overrides] thay kết quả của một mức, vd để giả vị trí bị mock.
class _FakePlatform extends LocationPlatform {
  _FakePlatform({
    this.serviceEnabled = true,
    this.permission = LocationPermission.whileInUse,
    this.permissionAfterRequest = LocationPermission.whileInUse,
    this.failures = const {},
    this.overrides = const {},
  });

  final bool serviceEnabled;
  final LocationPermission permission;
  final LocationPermission permissionAfterRequest;
  final Map<LocationAccuracy, Exception> failures;
  final Map<LocationAccuracy, PlatformPosition> overrides;

  final requested = <LocationAccuracy>[];

  static const readings = <LocationAccuracy, PlatformPosition>{
    LocationAccuracy.high: (
      latitude: 21.0285,
      longitude: 105.8542,
      accuracy: 6,
      isMocked: false,
    ),
    LocationAccuracy.medium: (
      latitude: 21.029,
      longitude: 105.855,
      accuracy: 45,
      isMocked: false,
    ),
    LocationAccuracy.low: (
      latitude: 21.03,
      longitude: 105.86,
      accuracy: 1800,
      isMocked: false,
    ),
  };

  @override
  Future<bool> isServiceEnabled() async => serviceEnabled;

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<LocationPermission> requestPermission() async =>
      permissionAfterRequest;

  @override
  Future<PlatformPosition> currentPosition(
    LocationAccuracy accuracy,
    Duration timeLimit,
  ) async {
    requested.add(accuracy);
    final failure = failures[accuracy];
    if (failure != null) throw failure;
    return overrides[accuracy] ?? readings[accuracy]!;
  }
}

void main() {
  final timeout = TimeoutException('hết giờ');

  Future<(LocationFix, List<LocationMethod>)> locate(
    _FakePlatform platform,
  ) async {
    final tried = <LocationMethod>[];
    final fix = await GeolocatorLocationService(platform)
        .getCurrentLocation(onAttempt: tried.add);
    return (fix, tried);
  }

  test('có GPS thì dùng GPS, không thử cách khác', () async {
    final platform = _FakePlatform();

    final (fix, tried) = await locate(platform);

    expect(fix.method, LocationMethod.gps);
    expect(fix.accuracyMeters, 6);
    expect(fix.point.latitude, 21.0285);
    expect(tried, [LocationMethod.gps]);
    expect(platform.requested, [LocationAccuracy.high]);
  });

  test('GPS hết giờ thì chuyển sang Wi-Fi', () async {
    final platform = _FakePlatform(failures: {LocationAccuracy.high: timeout});

    final (fix, tried) = await locate(platform);

    expect(fix.method, LocationMethod.wifi);
    expect(fix.accuracyMeters, 45);
    expect(tried, [LocationMethod.gps, LocationMethod.wifi]);
    expect(platform.requested, [
      LocationAccuracy.high,
      LocationAccuracy.medium,
    ]);
  });

  test('GPS và Wi-Fi đều không được thì dùng mạng di động', () async {
    final platform = _FakePlatform(
      failures: {
        LocationAccuracy.high: timeout,
        LocationAccuracy.medium: const PositionUpdateException('lỗi'),
      },
    );

    final (fix, tried) = await locate(platform);

    expect(fix.method, LocationMethod.cellular);
    expect(fix.accuracyMeters, 1800);
    expect(tried, LocationMethod.values);
  });

  test('cả ba cách đều không được thì báo lỗi', () async {
    final platform = _FakePlatform(
      failures: {
        LocationAccuracy.high: timeout,
        LocationAccuracy.medium: timeout,
        LocationAccuracy.low: timeout,
      },
    );

    await expectLater(
      GeolocatorLocationService(platform).getCurrentLocation(),
      throwsA(isA<LocationFailure>()),
    );
    expect(platform.requested, hasLength(3));
  });

  test('dịch vụ vị trí tắt thì báo lỗi, không thử cách nào', () async {
    final platform = _FakePlatform(serviceEnabled: false);

    await expectLater(
      GeolocatorLocationService(platform).getCurrentLocation(),
      throwsA(isA<LocationFailure>()),
    );
    expect(platform.requested, isEmpty);
  });

  test('người dùng từ chối quyền thì báo lỗi', () async {
    final platform = _FakePlatform(
      permission: LocationPermission.denied,
      permissionAfterRequest: LocationPermission.denied,
    );

    await expectLater(
      GeolocatorLocationService(platform).getCurrentLocation(),
      throwsA(isA<LocationFailure>()),
    );
    expect(platform.requested, isEmpty);
  });

  test('lỗi khác không phải hết giờ thì không nuốt mất', () async {
    final platform = _FakePlatform(
      failures: {
        LocationAccuracy.high: const LocationServiceDisabledException(),
      },
    );

    await expectLater(
      GeolocatorLocationService(platform).getCurrentLocation(),
      throwsA(isA<LocationServiceDisabledException>()),
    );
  });

  test('vị trí giả lập thì từ chối ngay, không thử cách khác', () async {
    final platform = _FakePlatform(
      overrides: {
        LocationAccuracy.high: (
          latitude: 10.7769,
          longitude: 106.7009,
          accuracy: 3,
          isMocked: true,
        ),
      },
    );

    await expectLater(
      GeolocatorLocationService(platform).getCurrentLocation(),
      throwsA(
        isA<LocationFailure>().having(
          (failure) => failure.message,
          'message',
          contains('vị trí giả lập'),
        ),
      ),
    );
    expect(platform.requested, [LocationAccuracy.high]);
  });

  test('Wi-Fi trả vị trí giả lập cũng bị từ chối', () async {
    final platform = _FakePlatform(
      failures: {LocationAccuracy.high: timeout},
      overrides: {
        LocationAccuracy.medium: (
          latitude: 10.7769,
          longitude: 106.7009,
          accuracy: 30,
          isMocked: true,
        ),
      },
    );

    await expectLater(
      GeolocatorLocationService(platform).getCurrentLocation(),
      throwsA(isA<LocationFailure>()),
    );
    expect(platform.requested, [
      LocationAccuracy.high,
      LocationAccuracy.medium,
    ]);
  });

  test('hệ điều hành không đo được sai số thì để null, không phải 0', () async {
    final platform = _FakePlatform(
      overrides: {
        LocationAccuracy.high: (
          latitude: 21.0285,
          longitude: 105.8542,
          accuracy: null,
          isMocked: false,
        ),
      },
    );

    final (fix, _) = await locate(platform);

    expect(fix.accuracyMeters, isNull);
  });
}
