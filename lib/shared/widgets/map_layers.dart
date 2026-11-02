import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:petworld_app/core/location/geo_point.dart';

// Style "HOT" của OSM France: màu nhạt, có tên đường tiếng Việt đủ dấu.
// tile.openstreetmap.org bị chặn trên mạng ở máy dev (connection reset),
// còn CARTO giờ đòi API key. Máy chủ này chỉ dùng tạm khi phát triển, trước
// khi phát hành phải đổi sang nhà cung cấp có hợp đồng hoặc tự host.
const _tileUrl = 'https://a.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png';

// Giảm độ rực và phủ chút màu kem để bản đồ dịu đi, cho ghim nhà nổi bật.
const _softTiles = ColorFilter.matrix([
  0.71, 0.20, 0.02, 0, 22, //
  0.06, 0.85, 0.02, 0, 18, //
  0.06, 0.20, 0.67, 0, 12, //
  0, 0, 0, 1, 0, //
]);

TileLayer petWorldTileLayer() => TileLayer(
  urlTemplate: _tileUrl,
  userAgentPackageName: 'com.petworld.petworld_app',
  tileBuilder: (context, tile, _) =>
      ColorFiltered(colorFilter: _softTiles, child: tile),
);

/// Giấy phép dữ liệu OpenStreetMap bắt buộc phải ghi nguồn. Thu gọn thành
/// nút (i) ở góc để không che bản đồ.
Widget mapAttribution() => const RichAttributionWidget(
  alignment: AttributionAlignment.bottomLeft,
  attributions: [
    TextSourceAttribution('OpenStreetMap contributors'),
    TextSourceAttribution('Tiles: OSM France / HOT'),
  ],
);

/// Không cho xoay bản đồ, cho đơn giản.
const noRotation = InteractionOptions(
  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
);

extension GeoPointLatLng on GeoPoint {
  LatLng toLatLng() => LatLng(latitude, longitude);
}
