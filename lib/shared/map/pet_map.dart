import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petworld_app/core/location/geo_point.dart';
import 'package:petworld_app/shared/map/map_preferences.dart';
import 'package:petworld_app/shared/map/maplibre_pet_map.dart';

/// Một ngôi nhà trên bản đồ.
class PetMapMarker {
  const PetMapMarker({
    required this.id,
    required this.position,
    this.label = '',
    this.isMine = false,
    this.pets = const [],
  });

  final String id;
  final GeoPoint position;

  /// Chữ dưới ghim, vd tên nhà.
  final String label;
  final bool isMine;

  /// Emoji các loài thú cưng trong nhà. Ghim hiện tối đa 3.
  final List<String> pets;

  @override
  bool operator ==(Object other) =>
      other is PetMapMarker &&
      other.id == id &&
      other.position == position &&
      other.label == label &&
      other.isMine == isMine &&
      listEquals(other.pets, pets);

  @override
  int get hashCode =>
      Object.hash(id, position, label, isMine, Object.hashAll(pets));
}

/// Một vùng tròn tô nhạt có viền nét đứt, vd vùng gần đúng của ngôi nhà hay
/// vòng sai số định vị.
class PetMapArea {
  const PetMapArea({
    required this.center,
    required this.radiusMeters,
    required this.color,
  });

  final GeoPoint center;
  final double radiusMeters;
  final Color color;

  @override
  bool operator ==(Object other) =>
      other is PetMapArea &&
      other.center == center &&
      other.radiusMeters == radiusMeters &&
      other.color == color;

  @override
  int get hashCode => Object.hash(center, radiusMeters, color);
}

/// Điều khiển camera của [PetMap] từ bên ngoài, vd nút "Về nhà của tôi".
class PetMapController {
  Future<void> Function(GeoPoint target, double zoom)? _mover;

  /// Bản đồ đang hiển thị gắn vào để nhận lệnh. Chỉ bản đồ gọi hàm này.
  void attach(Future<void> Function(GeoPoint target, double zoom) mover) =>
      _mover = mover;

  void detach() => _mover = null;

  Future<void> moveTo(GeoPoint target, {double zoom = 16}) async =>
      _mover?.call(target, zoom);
}

/// Bản đồ của PetWorld, vẽ theo kiểu người dùng chọn (Mô hình hoặc Thường).
///
/// Bản đồ thật do [petMapBuilderProvider] dựng, để widget test thay bằng bản
/// giả: MapLibre là view native nên không dựng được trong test.
class PetMap extends ConsumerStatefulWidget {
  const PetMap({
    super.key,
    required this.center,
    this.zoom = 16,
    this.maxZoom = 17,
    this.markers = const [],
    this.areas = const [],
    this.interactive = true,
    this.flat = false,
    this.controller,
    this.onMarkerTap,
  });

  /// Vị trí camera lúc mở bản đồ.
  final GeoPoint center;
  final double zoom;
  final double maxZoom;
  final List<PetMapMarker> markers;
  final List<PetMapArea> areas;

  /// False thì không chạm, kéo, zoom hay xoay được.
  final bool interactive;

  /// Luôn nhìn thẳng từ trên xuống, kể cả khi đang chọn kiểu Mô hình.
  final bool flat;
  final PetMapController? controller;

  /// Nhận id của ghim nhà vừa được chạm.
  final ValueChanged<String>? onMarkerTap;

  @override
  ConsumerState<PetMap> createState() => _PetMapState();
}

/// Những gì bản đồ cần để vẽ: cấu hình của [PetMap] và kiểu đang chọn.
class PetMapSpec {
  const PetMapSpec({
    required this.map,
    required this.kind,
    required this.night,
    required this.tint,
  });

  final PetMap map;
  final MapKind kind;
  final bool night;

  /// Màu nhuộm bản đồ ban ngày, lấy từ `primaryContainer` của theme.
  final Color tint;

  /// Có nghiêng camera và dựng nhà 3D không.
  bool get threeD => kind == MapKind.model && !map.flat;
}

typedef PetMapBuilder = Widget Function(PetMapSpec spec);

final petMapBuilderProvider = Provider<PetMapBuilder>(
  (ref) =>
      (spec) => MapLibrePetMap(spec: spec),
);

class _PetMapState extends ConsumerState<PetMap> {
  Timer? _lightingTimer;

  @override
  void dispose() {
    _lightingTimer?.cancel();
    super.dispose();
  }

  /// Ánh sáng "Tự động" thì hẹn giờ vẽ lại lúc chuyển ngày/đêm.
  void _scheduleLightingChange(MapPreferences preferences, DateTime now) {
    _lightingTimer?.cancel();
    final next = preferences.nextLightingChangeAfter(now);
    if (next == null) return;
    _lightingTimer = Timer(next.difference(now), () {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(mapPreferencesProvider);
    final now = DateTime.now();
    _scheduleLightingChange(preferences, now);

    final spec = PetMapSpec(
      map: widget,
      kind: preferences.kind,
      night: preferences.isNightAt(now),
      tint: Theme.of(context).colorScheme.primaryContainer,
    );
    return ref.watch(petMapBuilderProvider)(spec);
  }
}
