import 'dart:convert';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petworld_app/shared/map/pet_map_style.dart';

const _tint = Color(0xFFF2784B);

void main() {
  Map<String, dynamic> decode(PetMapStyle style) =>
      jsonDecode(style.json) as Map<String, dynamic>;

  List<Map<String, dynamic>> layers(PetMapStyle style) =>
      (decode(style)['layers'] as List).cast<Map<String, dynamic>>();

  final styles = {
    'Mô hình ban ngày': PetMapStyle.model(night: false, tint: _tint),
    'Mô hình ban đêm': PetMapStyle.model(night: true, tint: _tint),
    'Thường': PetMapStyle.normal(tint: _tint),
  };

  for (final MapEntry(key: name, value: style) in styles.entries) {
    test('$name: style hợp lệ, mọi lớp dùng nguồn có thật', () {
      final json = decode(style);
      expect(json['version'], 8);
      expect(json['glyphs'], contains('{fontstack}'));
      final sources = (json['sources'] as Map).keys.toSet();

      final ids = <String>{};
      for (final layer in layers(style)) {
        expect(ids.add(layer['id'] as String), isTrue, reason: 'trùng id');
        if (layer['type'] != 'background') {
          expect(sources, contains(layer['source']), reason: layer['id']);
        }
      }
      // Lớp vùng quanh nhà được chèn dưới lớp tòa nhà, nên lớp này phải có.
      expect(ids, contains(PetMapStyle.buildingLayerId));
      expect(style.labelColor, matches(RegExp(r'^#[0-9a-f]{6}$')));
    });
  }

  test('Mô hình dựng nhà 3D, Thường vẽ nhà phẳng', () {
    String buildingType(PetMapStyle style) =>
        layers(style).firstWhere(
              (layer) => layer['id'] == PetMapStyle.buildingLayerId,
            )['type']
            as String;

    expect(
      buildingType(PetMapStyle.model(night: false, tint: _tint)),
      'fill-extrusion',
    );
    expect(buildingType(PetMapStyle.normal(tint: _tint)), 'fill');
  });

  test('chỉ kiểu Thường có tên đường', () {
    bool hasRoadNames(PetMapStyle style) =>
        layers(style)
            .any((layer) => layer['source-layer'] == 'transportation_name');

    expect(hasRoadNames(PetMapStyle.normal(tint: _tint)), isTrue);
    expect(hasRoadNames(PetMapStyle.model(night: false, tint: _tint)), isFalse);
  });

  test('ban đêm đổi màu nền và màu chữ tên nhà', () {
    final day = PetMapStyle.model(night: false, tint: _tint);
    final night = PetMapStyle.model(night: true, tint: _tint);
    String background(PetMapStyle style) =>
        (layers(style).first['paint'] as Map)['background-color'] as String;

    expect(background(night), isNot(background(day)));
    expect(night.labelColor, isNot(day.labelColor));
  });

  test('ban ngày nhuộm theo màu theme, ban đêm thì không', () {
    const blue = Color(0xFF7EC8F0);
    String background(PetMapStyle style) =>
        (layers(style).first['paint'] as Map)['background-color'] as String;

    expect(
      background(PetMapStyle.model(night: false, tint: blue)),
      isNot(background(PetMapStyle.model(night: false, tint: _tint))),
    );
    expect(
      background(PetMapStyle.normal(tint: blue)),
      isNot(background(PetMapStyle.normal(tint: _tint))),
    );
    expect(
      background(PetMapStyle.model(night: true, tint: blue)),
      background(PetMapStyle.model(night: true, tint: _tint)),
    );
  });
}
