import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:petworld_app/core/location/geo_point.dart';
import 'package:petworld_app/shared/map/house_marker_icon.dart';
import 'package:petworld_app/shared/map/map_preferences.dart';
import 'package:petworld_app/shared/map/pet_map.dart';
import 'package:petworld_app/shared/map/pet_map_style.dart';

/// [PetMap] vẽ bằng MapLibre. Nhà và vùng quanh nhà là lớp GeoJSON riêng,
/// thêm lại mỗi khi style nạp xong (đổi kiểu bản đồ hay ngày/đêm là nạp style
/// mới, các lớp và ảnh thêm vào trước đó mất theo style cũ).
class MapLibrePetMap extends StatefulWidget {
  const MapLibrePetMap({super.key, required this.spec});

  final PetMapSpec spec;

  /// Góc nghiêng camera của kiểu Mô hình. Nghiêng nhiều hơn thì phải tải thêm
  /// tile ở xa tới tận đường chân trời, tốn pin và dữ liệu.
  static const modelTilt = 55.0;
  static const modelBearing = -20.0;

  @override
  State<MapLibrePetMap> createState() => _MapLibrePetMapState();
}

class _MapLibrePetMapState extends State<MapLibrePetMap> {
  static const _housesSource = 'pw-houses';
  static const _housesLayer = 'pw-houses-symbols';
  static const _areasSource = 'pw-areas';
  static const _areasFill = 'pw-areas-fill';
  static const _areasLine = 'pw-areas-line';

  MapLibreMapController? _controller;
  bool _styleReady = false;

  /// Màu theme lúc dựng gần nhất, để vẽ ghim nhà sau các bước chờ bất đồng bộ
  /// mà không phải đọc lại `context`.
  late ColorScheme _colors;
  final _images = <String>{};

  /// Các lệnh gửi xuống MapLibre chạy lần lượt, không chen nhau.
  Future<void> _queue = Future.value();

  PetMap get _map => widget.spec.map;

  PetMapStyle get _style => switch (widget.spec.kind) {
    MapKind.model => PetMapStyle.model(
      night: widget.spec.night,
      tint: widget.spec.tint,
    ),
    MapKind.normal => PetMapStyle.normal(tint: widget.spec.tint),
  };

  @override
  void initState() {
    super.initState();
    _map.controller?.attach(_moveTo);
  }

  @override
  void didUpdateWidget(MapLibrePetMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final old = oldWidget.spec;
    if (old.map.controller != _map.controller) {
      old.map.controller?.detach();
      _map.controller?.attach(_moveTo);
    }
    if (old.kind != widget.spec.kind ||
        old.night != widget.spec.night ||
        old.tint != widget.spec.tint) {
      // MapLibreMap tự nạp style mới khi styleString đổi, rồi gọi lại
      // onStyleLoadedCallback để thêm lại nhà.
      _styleReady = false;
      if (old.threeD != widget.spec.threeD) _enqueue(_applyTilt);
    } else if (!listEquals(old.map.markers, _map.markers) ||
        !listEquals(old.map.areas, _map.areas)) {
      _enqueue(_syncData);
    }
  }

  @override
  void dispose() {
    _map.controller?.detach();
    _controller?.onFeatureTapped.remove(_onFeatureTapped);
    super.dispose();
  }

  void _enqueue(Future<void> Function() task) {
    _queue = _queue.then((_) => task()).catchError((Object error) {
      // Style đang nạp lại hoặc bản đồ đã đóng: lần nạp style sau sẽ thêm lại.
      debugPrint('PetMap: $error');
    });
  }

  Future<void> _moveTo(GeoPoint target, double zoom) async {
    await _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(_latLng(target), zoom),
    );
  }

  Future<void> _applyTilt() async {
    final threeD = widget.spec.threeD;
    await _controller?.animateCamera(
      CameraUpdate.tiltTo(threeD ? MapLibrePetMap.modelTilt : 0),
    );
    await _controller?.animateCamera(
      CameraUpdate.bearingTo(threeD ? MapLibrePetMap.modelBearing : 0),
    );
  }

  void _onMapCreated(MapLibreMapController controller) {
    _controller = controller;
    controller.onFeatureTapped.add(_onFeatureTapped);
  }

  void _onFeatureTapped(
    Point<double> point,
    LatLng coordinates,
    String id,
    String layerId,
    Annotation? annotation,
  ) {
    if (layerId == _housesLayer) _map.onMarkerTap?.call(id);
  }

  void _onStyleLoaded() {
    _styleReady = false;
    _images.clear();
    _enqueue(_addLayers);
  }

  Future<void> _addLayers() async {
    final controller = _controller;
    if (controller == null || !mounted) return;
    final style = _style;

    await controller.addGeoJsonSource(_areasSource, _areasGeoJson());
    await controller.addFillLayer(
      _areasSource,
      _areasFill,
      const FillLayerProperties(
        fillColor: [Expressions.get, 'color'],
        fillOpacity: 0.16,
      ),
      belowLayerId: PetMapStyle.buildingLayerId,
      enableInteraction: false,
    );
    await controller.addLineLayer(
      _areasSource,
      _areasLine,
      const LineLayerProperties(
        lineColor: [Expressions.get, 'color'],
        lineWidth: 2,
        lineOpacity: 0.7,
        lineDasharray: [2, 2],
      ),
      belowLayerId: PetMapStyle.buildingLayerId,
      enableInteraction: false,
    );

    await controller.addGeoJsonSource(_housesSource, _housesGeoJson());
    await controller.addSymbolLayer(
      _housesSource,
      _housesLayer,
      SymbolLayerProperties(
        iconImage: [Expressions.get, 'icon'],
        iconAnchor: 'bottom',
        iconAllowOverlap: true,
        iconIgnorePlacement: true,
        // Ghim luôn đứng thẳng hướng về người xem, kể cả khi bản đồ nghiêng.
        iconPitchAlignment: 'viewport',
        iconRotationAlignment: 'viewport',
        symbolSortKey: [Expressions.get, 'sort'],
        textField: [Expressions.get, 'label'],
        textFont: PetMapStyle.boldFont,
        textSize: 12,
        textAnchor: 'top',
        textOffset: const [0, 0.3],
        textOptional: true,
        textColor: style.labelColor,
        textHaloColor: style.labelHaloColor,
        textHaloWidth: 2,
      ),
      enableInteraction: true,
    );
    _styleReady = true;
    await _syncData();
  }

  Future<void> _syncData() async {
    final controller = _controller;
    if (controller == null || !_styleReady || !mounted) return;

    final colors = _colors;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    for (final marker in _map.markers) {
      final name = _iconName(marker);
      if (!_images.add(name)) continue;
      final png = await HouseMarkerIcon.render(
        isMine: marker.isMine,
        pets: marker.pets,
        colors: colors,
        pixelRatio: pixelRatio,
      );
      await controller.addImage(name, png, false, pixelRatio);
    }
    await controller.setGeoJsonSource(_areasSource, _areasGeoJson());
    await controller.setGeoJsonSource(_housesSource, _housesGeoJson());
  }

  String _iconName(PetMapMarker marker) => HouseMarkerIcon.imageName(
    isMine: marker.isMine,
    pets: marker.pets,
    colors: _colors,
  );

  Map<String, dynamic> _housesGeoJson() => {
    'type': 'FeatureCollection',
    'features': [
      for (final marker in _map.markers)
        {
          'type': 'Feature',
          // Android và iOS lấy id ở cấp feature để báo lại khi chạm.
          'id': marker.id,
          'properties': {
            'icon': _iconName(marker),
            'label': marker.label,
            // Nhà của mình vẽ sau cùng, nằm trên các nhà khác.
            'sort': marker.isMine ? 1 : 0,
          },
          'geometry': {
            'type': 'Point',
            'coordinates': [
              marker.position.longitude,
              marker.position.latitude,
            ],
          },
        },
    ],
  };

  Map<String, dynamic> _areasGeoJson() => {
    'type': 'FeatureCollection',
    'features': [
      for (final area in _map.areas)
        {
          'type': 'Feature',
          'properties': {'color': _hex(area.color)},
          'geometry': {
            'type': 'Polygon',
            'coordinates': [_circle(area.center, area.radiusMeters)],
          },
        },
    ],
  };

  /// Đa giác 48 cạnh xấp xỉ vòng tròn bán kính [meters] quanh [center].
  static List<List<double>> _circle(GeoPoint center, double meters) => [
    for (var i = 0; i <= 48; i++)
      () {
        final point = center.offset(
          distanceMeters: meters,
          bearingRadians: 2 * pi * i / 48,
        );
        return [point.longitude, point.latitude];
      }(),
  ];

  static String _hex(Color color) =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  static LatLng _latLng(GeoPoint point) =>
      LatLng(point.latitude, point.longitude);

  @override
  Widget build(BuildContext context) {
    _colors = Theme.of(context).colorScheme;
    final spec = widget.spec;
    final interactive = _map.interactive;
    final threeD = spec.threeD;

    // Không cho chạm khi chỉ để xem: chặn luôn ở phía Flutter cho chắc, phòng
    // khi view native vẫn nhận cử chỉ.
    return IgnorePointer(
      ignoring: !interactive,
      child: MapLibreMap(
        styleString: _style.json,
        initialCameraPosition: CameraPosition(
          target: _latLng(_map.center),
          zoom: _map.zoom,
          tilt: threeD ? MapLibrePetMap.modelTilt : 0,
          bearing: threeD ? MapLibrePetMap.modelBearing : 0,
        ),
        minMaxZoomPreference: MinMaxZoomPreference(3, _map.maxZoom),
        scrollGesturesEnabled: interactive,
        zoomGesturesEnabled: interactive,
        doubleClickZoomEnabled: interactive,
        rotateGesturesEnabled: interactive && threeD,
        tiltGesturesEnabled: interactive && threeD,
        compassEnabled: interactive && threeD,
        compassViewPosition: CompassViewPosition.topRight,
        compassViewMargins: const Point(16, 120),
        // Giấy phép OpenStreetMap bắt buộc ghi nguồn: nút (i) ở góc trái
        // dưới. Đặt lề rõ ràng, không thì nút chừa chỗ cho logo MapLibre
        // (đã tắt) và lệch vào giữa.
        attributionButtonPosition: AttributionButtonPosition.bottomLeft,
        attributionButtonMargins: const Point(12, 12),
        // Không dùng annotation của plugin: bỏ đi thì Android vẽ nhanh hơn.
        annotationOrder: const [],
        // Kéo thả feature, không phải kéo bản đồ. Không dùng nên tắt cho nhẹ.
        dragEnabled: false,
        onMapCreated: _onMapCreated,
        onStyleLoadedCallback: _onStyleLoaded,
      ),
    );
  }
}
