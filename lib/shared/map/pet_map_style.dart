import 'dart:convert';

import 'package:flutter/painting.dart';

// Tile vector của OpenFreeMap: dữ liệu OpenStreetMap theo schema OpenMapTiles,
// miễn phí, không cần key, cho dùng thương mại. Dịch vụ sống nhờ quyên góp và
// không cam kết thời gian hoạt động, nên trước khi phát hành phải tự host
// (vd file PMTiles) hoặc chuyển sang nhà cung cấp có hợp đồng.
const _tilesUrl = 'https://tiles.openfreemap.org/planet';
const _glyphsUrl =
    'https://tiles.openfreemap.org/fonts/{fontstack}/{range}.pbf';

const _majorRoads = ['motorway', 'trunk', 'primary'];
const _midRoads = ['secondary', 'tertiary'];
const _notRoads = ['path', 'rail', 'transit', 'ferry', 'aerialway'];

/// Style MapLibre của một kiểu bản đồ, kèm màu chữ hợp với nền để vẽ tên nhà.
class PetMapStyle {
  const PetMapStyle._({
    required this.json,
    required this.labelColor,
    required this.labelHaloColor,
  });

  /// Kiểu Mô hình: nhà nổi khối 3D màu pastel, có bản ban ngày và ban đêm.
  /// Ban ngày nhuộm theo [tint], thường là `primaryContainer` của theme.
  factory PetMapStyle.model({required bool night, required Color tint}) {
    final p = night ? _Palette.modelNight : _Palette.modelDay(tint);
    return PetMapStyle._(
      json: jsonEncode(
        _style(p, [
          ..._groundLayers(p),
          {
            'id': buildingLayerId,
            'type': 'fill-extrusion',
            'source': 'omt',
            'source-layer': 'building',
            'minzoom': 14,
            'paint': {
              'fill-extrusion-color': [
                'interpolate',
                ['linear'],
                [
                  'coalesce',
                  ['get', 'render_height'],
                  8,
                ],
                for (final (height, color) in p.buildingStops) ...[
                  height,
                  color,
                ],
              ],
              'fill-extrusion-height': [
                'coalesce',
                ['get', 'render_height'],
                8,
              ],
              'fill-extrusion-base': [
                'coalesce',
                ['get', 'render_min_height'],
                0,
              ],
              'fill-extrusion-opacity': 0.95,
            },
          },
          _waterLabels(p),
          _placeLabels(p, ['suburb', 'quarter', 'neighbourhood']),
        ]),
      ),
      labelColor: p.label,
      labelHaloColor: p.labelHalo,
    );
  }

  /// Kiểu Thường: bản đồ phẳng, có tên đường để dễ tìm đường.
  factory PetMapStyle.normal({required Color tint}) {
    final p = _Palette.normal(tint);
    return PetMapStyle._(
      json: jsonEncode(
        _style(p, [
          ..._groundLayers(p),
          {
            'id': buildingLayerId,
            'type': 'fill',
            'source': 'omt',
            'source-layer': 'building',
            'minzoom': 15,
            'paint': {
              'fill-color': p.buildingStops.first.$2,
              'fill-outline-color': p.buildingOutline,
            },
          },
          {
            'id': 'road-label',
            'type': 'symbol',
            'source': 'omt',
            'source-layer': 'transportation_name',
            'minzoom': 14,
            'filter': [
              '!',
              [
                'in',
                ['get', 'class'],
                ['literal', _notRoads],
              ],
            ],
            'layout': {
              'symbol-placement': 'line',
              'text-field': ['get', 'name'],
              'text-font': regularFont,
              'text-size': 12,
            },
            'paint': {
              'text-color': p.roadText,
              'text-halo-color': p.roadTextHalo,
              'text-halo-width': 1.5,
            },
          },
          _waterLabels(p),
          _placeLabels(p, [
            'city',
            'town',
            'village',
            'suburb',
            'quarter',
            'neighbourhood',
          ]),
        ]),
      ),
      labelColor: p.label,
      labelHaloColor: p.labelHalo,
    );
  }

  /// Id lớp tòa nhà. Lớp riêng của app (vùng quanh nhà) đặt dưới lớp này để
  /// nhà 3D không bị phủ màu.
  static const buildingLayerId = 'building';

  /// Font có trên máy chủ glyphs, đủ dấu tiếng Việt.
  static const regularFont = ['Noto Sans Regular'];
  static const boldFont = ['Noto Sans Bold'];
  static const italicFont = ['Noto Sans Italic'];

  /// Style MapLibre dạng JSON, truyền thẳng vào `styleString`.
  final String json;

  /// Màu chữ tên nhà, dạng `#rrggbb`.
  final String labelColor;
  final String labelHaloColor;

  static Map<String, dynamic> _style(
    _Palette p,
    List<Map<String, dynamic>> layers,
  ) => {
    'version': 8,
    'glyphs': _glyphsUrl,
    'sources': {
      'omt': {'type': 'vector', 'url': _tilesUrl},
    },
    'light': {
      'anchor': 'map',
      'color': p.lightColor,
      'intensity': p.lightIntensity,
      'position': [1.3, 210, 35],
    },
    'layers': layers,
  };

  static List<Map<String, dynamic>> _groundLayers(_Palette p) {
    const roadFilter = [
      'all',
      [
        '!',
        [
          'in',
          ['get', 'class'],
          ['literal', _notRoads],
        ],
      ],
      [
        '!=',
        ['get', 'brunnel'],
        'tunnel',
      ],
    ];
    return [
      {
        'id': 'background',
        'type': 'background',
        'paint': {'background-color': p.background},
      },
      {
        'id': 'landuse',
        'type': 'fill',
        'source': 'omt',
        'source-layer': 'landuse',
        'paint': {
          'fill-color': [
            'match',
            ['get', 'class'],
            'residential',
            p.residential,
            ['school', 'kindergarten', 'college', 'university'],
            p.school,
            'hospital',
            p.hospital,
            ['pitch', 'stadium'],
            p.pitch,
            p.landuse,
          ],
        },
      },
      {
        'id': 'landcover',
        'type': 'fill',
        'source': 'omt',
        'source-layer': 'landcover',
        'paint': {
          'fill-color': [
            'match',
            ['get', 'class'],
            'wood',
            p.wood,
            'sand',
            p.sand,
            p.grass,
          ],
        },
      },
      {
        'id': 'park',
        'type': 'fill',
        'source': 'omt',
        'source-layer': 'park',
        'paint': {'fill-color': p.park},
      },
      {
        'id': 'water',
        'type': 'fill',
        'source': 'omt',
        'source-layer': 'water',
        'paint': {'fill-color': p.water},
      },
      {
        'id': 'waterway',
        'type': 'line',
        'source': 'omt',
        'source-layer': 'waterway',
        'paint': {
          'line-color': p.water,
          'line-width': [
            'interpolate',
            ['linear'],
            ['zoom'],
            12,
            1,
            18,
            6,
          ],
        },
      },
      {
        'id': 'path',
        'type': 'line',
        'source': 'omt',
        'source-layer': 'transportation',
        'minzoom': 14,
        'filter': [
          '==',
          ['get', 'class'],
          'path',
        ],
        'layout': {'line-cap': 'round'},
        'paint': {
          'line-color': p.path,
          'line-width': [
            'interpolate',
            ['linear'],
            ['zoom'],
            14,
            1,
            18,
            3,
          ],
          'line-dasharray': [1, 1.5],
        },
      },
      {
        'id': 'road-casing',
        'type': 'line',
        'source': 'omt',
        'source-layer': 'transportation',
        'filter': roadFilter,
        'layout': {'line-cap': 'round', 'line-join': 'round'},
        'paint': {
          'line-color': [
            'match',
            ['get', 'class'],
            _majorRoads,
            p.casingMajor,
            _midRoads,
            p.casingMid,
            p.casingMinor,
          ],
          'line-width': _roadWidth(major: 30, mid: 24, minor: 16, service: 9),
        },
      },
      {
        'id': 'road',
        'type': 'line',
        'source': 'omt',
        'source-layer': 'transportation',
        'filter': roadFilter,
        'layout': {'line-cap': 'round', 'line-join': 'round'},
        'paint': {
          'line-color': [
            'match',
            ['get', 'class'],
            _majorRoads,
            p.roadMajor,
            p.road,
          ],
          'line-width': _roadWidth(major: 24, mid: 19, minor: 12, service: 6),
        },
      },
    ];
  }

  /// Độ rộng đường theo zoom: nhỏ khi nhìn xa, to và tròn khi nhìn gần.
  static List<Object> _roadWidth({
    required double major,
    required double mid,
    required double minor,
    required double service,
  }) => [
    'interpolate',
    ['exponential', 1.6],
    ['zoom'],
    12,
    [
      'match',
      ['get', 'class'],
      _majorRoads,
      major * 0.12,
      _midRoads,
      mid * 0.1,
      minor * 0.06,
    ],
    18,
    [
      'match',
      ['get', 'class'],
      _majorRoads,
      major,
      _midRoads,
      mid,
      ['service', 'track'],
      service,
      minor,
    ],
  ];

  static Map<String, dynamic> _waterLabels(_Palette p) => {
    'id': 'water-label',
    'type': 'symbol',
    'source': 'omt',
    'source-layer': 'water_name',
    'layout': {
      'text-field': ['get', 'name'],
      'text-font': italicFont,
      'text-size': 13,
    },
    'paint': {
      'text-color': p.waterText,
      'text-halo-color': p.waterTextHalo,
      'text-halo-width': 1.5,
    },
  };

  static Map<String, dynamic> _placeLabels(_Palette p, List<String> classes) =>
      {
        'id': 'place-label',
        'type': 'symbol',
        'source': 'omt',
        'source-layer': 'place',
        'filter': [
          'in',
          ['get', 'class'],
          ['literal', classes],
        ],
        'layout': {
          'text-field': ['get', 'name'],
          'text-font': boldFont,
          'text-size': 13,
        },
        'paint': {
          'text-color': p.placeText,
          'text-halo-color': p.placeTextHalo,
          'text-halo-width': 2,
        },
      };
}

/// Tạo màu cùng tông với màu gốc: giữ sắc độ (hue), đặt độ sáng cố định để
/// màu gốc đậm hay nhạt thì bản đồ vẫn nhạt như nhau.
class _Tint {
  _Tint(Color color, {this.maxSaturation = 0.85})
    : _hsl = HSLColor.fromColor(color);

  final HSLColor _hsl;
  final double maxSaturation;

  String hex({
    required double lightness,
    double hueShift = 0,
    double? saturation,
  }) {
    final color = HSLColor.fromAHSL(
      1,
      (_hsl.hue + hueShift) % 360,
      saturation ?? _hsl.saturation.clamp(0.3, maxSaturation),
      lightness,
    ).toColor();
    return '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  }
}

/// Bảng màu của một style.
class _Palette {
  const _Palette({
    required this.background,
    required this.landuse,
    required this.residential,
    required this.school,
    required this.hospital,
    required this.pitch,
    required this.grass,
    required this.wood,
    required this.sand,
    required this.park,
    required this.water,
    required this.path,
    required this.casingMajor,
    required this.casingMid,
    required this.casingMinor,
    required this.roadMajor,
    required this.road,
    required this.buildingStops,
    required this.placeText,
    required this.placeTextHalo,
    required this.waterText,
    required this.waterTextHalo,
    required this.label,
    required this.labelHalo,
    this.buildingOutline = 'rgba(0, 0, 0, 0)',
    this.roadText = '#000000',
    this.roadTextHalo = '#ffffff',
    this.lightColor = '#ffffff',
    this.lightIntensity = 0.4,
  });

  /// Ban ngày của kiểu Mô hình, nhuộm theo [tint] (màu nút chính của app).
  /// Cây cỏ, nước giữ màu tự nhiên.
  factory _Palette.modelDay(Color tint) {
    final t = _Tint(tint);
    return _Palette(
      background: t.hex(lightness: 0.965),
      landuse: t.hex(lightness: 0.955),
      residential: t.hex(lightness: 0.94),
      school: t.hex(lightness: 0.94, hueShift: -30),
      hospital: t.hex(lightness: 0.935, hueShift: -15),
      pitch: '#c6ebb0',
      grass: '#cdebb5',
      wood: '#b9e0a5',
      sand: '#fbe7b5',
      park: '#c8e8b0',
      water: '#9ed8f0',
      path: t.hex(lightness: 0.82),
      casingMajor: t.hex(lightness: 0.77),
      casingMid: t.hex(lightness: 0.83),
      casingMinor: t.hex(lightness: 0.89),
      roadMajor: '#ffe8a3',
      road: '#ffffff',
      // Nhà thấp đúng tông của app, cao dần thì xoay dần sang các màu kẹo
      // khác cho vui mắt.
      buildingStops: [
        (0, t.hex(lightness: 0.88)),
        (15, t.hex(lightness: 0.89, hueShift: -30)),
        (40, t.hex(lightness: 0.9, hueShift: -110)),
        (100, t.hex(lightness: 0.9, hueShift: -170)),
      ],
      placeText: t.hex(lightness: 0.45, saturation: 0.3),
      placeTextHalo: '#ffffff',
      waterText: '#4e9cc0',
      waterTextHalo: '#e8f7ff',
      label: t.hex(lightness: 0.25, saturation: 0.35),
      labelHalo: '#ffffff',
    );
  }

  static const modelNight = _Palette(
    background: '#2b2540',
    landuse: '#30294a',
    residential: '#332b4a',
    school: '#30294a',
    hospital: '#30294a',
    pitch: '#2f4a44',
    grass: '#2f4a44',
    wood: '#2f4a44',
    sand: '#3a3350',
    park: '#2f4a44',
    water: '#2c4e78',
    path: '#4a4266',
    casingMajor: '#3d3560',
    casingMid: '#3d3560',
    casingMinor: '#3d3560',
    roadMajor: '#8a7a4f',
    road: '#5c537d',
    buildingStops: [
      (0, '#4a3f6b'),
      (15, '#5b4a80'),
      (40, '#6b5a99'),
      (100, '#7c6bb0'),
    ],
    placeText: '#e7d7ff',
    placeTextHalo: '#2b2540',
    waterText: '#9fc8f0',
    waterTextHalo: '#22304d',
    label: '#fff4e8',
    labelHalo: '#2b2540',
    lightColor: '#b8a8ff',
    lightIntensity: 0.25,
  );

  /// Kiểu Thường: nhạt và trung tính hơn Mô hình để tên đường dễ đọc, chỉ
  /// ngả nhẹ theo [tint].
  factory _Palette.normal(Color tint) {
    final t = _Tint(tint, maxSaturation: 0.4);
    return _Palette(
      background: t.hex(lightness: 0.97),
      landuse: t.hex(lightness: 0.955),
      residential: t.hex(lightness: 0.945),
      school: t.hex(lightness: 0.95, hueShift: -30),
      hospital: t.hex(lightness: 0.945, hueShift: -15),
      pitch: '#d5ecc4',
      grass: '#dbeecb',
      wood: '#cfe6bf',
      sand: '#f6ecc9',
      park: '#d4ebc2',
      water: '#a8d8ee',
      path: t.hex(lightness: 0.8),
      casingMajor: t.hex(lightness: 0.78, saturation: 0.55),
      casingMid: t.hex(lightness: 0.84),
      casingMinor: t.hex(lightness: 0.88),
      roadMajor: '#ffefc2',
      road: '#ffffff',
      buildingStops: [(0, t.hex(lightness: 0.91))],
      buildingOutline: t.hex(lightness: 0.85),
      roadText: t.hex(lightness: 0.36, saturation: 0.3),
      roadTextHalo: '#ffffff',
      placeText: t.hex(lightness: 0.3, saturation: 0.3),
      placeTextHalo: '#ffffff',
      waterText: '#3f8bb0',
      waterTextHalo: '#eef8ff',
      label: t.hex(lightness: 0.25, saturation: 0.35),
      labelHalo: '#ffffff',
    );
  }

  final String background;
  final String landuse;
  final String residential;
  final String school;
  final String hospital;
  final String pitch;
  final String grass;
  final String wood;
  final String sand;
  final String park;
  final String water;
  final String path;
  final String casingMajor;
  final String casingMid;
  final String casingMinor;
  final String roadMajor;
  final String road;

  /// Màu nhà theo chiều cao (mét). Kiểu Thường chỉ dùng màu đầu tiên.
  final List<(num, String)> buildingStops;
  final String buildingOutline;
  final String roadText;
  final String roadTextHalo;
  final String placeText;
  final String placeTextHalo;
  final String waterText;
  final String waterTextHalo;

  /// Tên nhà của người dùng PetWorld.
  final String label;
  final String labelHalo;
  final String lightColor;
  final double lightIntensity;
}
