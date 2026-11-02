import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:petworld_app/core/error/failures.dart';
import 'package:petworld_app/core/location/geo_point.dart';
import 'package:petworld_app/core/location/location_fix.dart';

final locationServiceProvider = Provider<LocationService>(
  (ref) => GeolocatorLocationService(),
);

abstract interface class LocationService {
  /// Thử lần lượt GPS → Wi-Fi → mạng di động, trả về cách đầu tiên có kết
  /// quả. [onAttempt] được gọi mỗi khi bắt đầu thử một cách, để màn hình
  /// báo cho người dùng biết đang làm gì.
  ///
  /// Ném [LocationFailure] khi dịch vụ vị trí tắt, không có quyền, vị trí là
  /// vị trí giả lập, hoặc cả ba cách đều không lấy được vị trí.
  Future<LocationFix> getCurrentLocation({
    void Function(LocationMethod method)? onAttempt,
  });
}

/// Lớp mỏng bọc các hàm tĩnh của geolocator, để test được thứ tự thử.
class LocationPlatform {
  const LocationPlatform();

  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();

  Future<LocationPermission> requestPermission() =>
      Geolocator.requestPermission();

  /// Ném [TimeoutException] khi quá [timeLimit] mà chưa có vị trí.
  ///
  /// `accuracy` là null khi hệ điều hành không đo được sai số (lúc đó
  /// geolocator trả 0 chỉ để giữ chỗ). `isMocked` là true khi vị trí đến từ
  /// nguồn giả lập: app fake GPS trên Android, hoặc giả lập bằng phần mềm
  /// trên iOS 15 trở lên.
  Future<PlatformPosition> currentPosition(
    LocationAccuracy accuracy,
    Duration timeLimit,
  ) async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        timeLimit: timeLimit,
      ),
    );
    return (
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.hasAccuracy ? position.accuracy : null,
      isMocked: position.isMocked,
    );
  }
}

typedef PlatformPosition = ({
  double latitude,
  double longitude,
  double? accuracy,
  bool isMocked,
});

/// Chỉ xin quyền "khi đang dùng app", vì vị trí chỉ cần lúc đăng ký nhà.
class GeolocatorLocationService implements LocationService {
  GeolocatorLocationService([this._platform = const LocationPlatform()]);

  // Trên Android (fused provider): high = GPS, medium = định vị mạng ưu tiên
  // Wi-Fi (sai số ~100 m), low = tiết kiệm pin, chủ yếu trạm di động.
  static const attempts = [
    (
      method: LocationMethod.gps,
      accuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 12),
    ),
    (
      method: LocationMethod.wifi,
      accuracy: LocationAccuracy.medium,
      timeLimit: Duration(seconds: 8),
    ),
    (
      method: LocationMethod.cellular,
      accuracy: LocationAccuracy.low,
      timeLimit: Duration(seconds: 8),
    ),
  ];

  final LocationPlatform _platform;

  @override
  Future<LocationFix> getCurrentLocation({
    void Function(LocationMethod method)? onAttempt,
  }) async {
    await _ensureAllowed();

    for (final attempt in attempts) {
      onAttempt?.call(attempt.method);
      try {
        final position = await _platform.currentPosition(
          attempt.accuracy,
          attempt.timeLimit,
        );
        // Không nhận vị trí giả. Dừng luôn, không thử cách khác, vì khi có
        // app giả lập thì các nguồn khác thường cũng bị giả.
        if (position.isMocked) {
          throw const LocationFailure(
            'PetWorld không nhận vị trí giả lập. Hãy tắt ứng dụng giả lập '
            'vị trí (fake GPS) rồi thử lại.',
          );
        }
        return LocationFix(
          point: GeoPoint(position.latitude, position.longitude),
          accuracyMeters: position.accuracy,
          method: attempt.method,
        );
      } on TimeoutException {
        // Chưa có tín hiệu, thử cách kế tiếp.
      } on PositionUpdateException {
        // Nguồn này đang lỗi, thử cách kế tiếp.
      }
    }

    throw const LocationFailure(
      'Không lấy được vị trí từ GPS, Wi-Fi hay mạng di động. Hãy ra chỗ '
      'thoáng hoặc bật Wi-Fi rồi thử lại.',
    );
  }

  Future<void> _ensureAllowed() async {
    // Trên Android, Wi-Fi và trạm di động cũng đi qua dịch vụ vị trí, nên tắt
    // dịch vụ này thì không cách nào lấy được vị trí.
    if (!await _platform.isServiceEnabled()) {
      throw const LocationFailure(
        'Dịch vụ vị trí của máy đang tắt. Hãy bật "Vị trí" rồi thử lại.',
      );
    }

    var permission = await _platform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _platform.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationFailure('Bạn chưa cho phép PetWorld dùng vị trí.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationFailure(
        'Quyền vị trí đã bị chặn. Hãy bật lại trong Cài đặt của máy.',
      );
    }
  }
}
