import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petworld_app/core/storage/shared_preferences_provider.dart';
import 'package:petworld_app/shared/map/map_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('isNightAt', () {
    const auto = MapPreferences();

    test('tự động: đêm từ 18 h tới trước 6 h', () {
      expect(auto.isNightAt(DateTime(2026, 11, 3, 17, 59)), isFalse);
      expect(auto.isNightAt(DateTime(2026, 11, 3, 18)), isTrue);
      expect(auto.isNightAt(DateTime(2026, 11, 3, 23, 30)), isTrue);
      expect(auto.isNightAt(DateTime(2026, 11, 4, 5, 59)), isTrue);
      expect(auto.isNightAt(DateTime(2026, 11, 4, 6)), isFalse);
    });

    test('chọn cố định thì không theo giờ', () {
      final noon = DateTime(2026, 11, 3, 12);
      final midnight = DateTime(2026, 11, 3, 0);
      const night = MapPreferences(lighting: MapLighting.night);
      const day = MapPreferences(lighting: MapLighting.day);
      expect(night.isNightAt(noon), isTrue);
      expect(day.isNightAt(midnight), isFalse);
    });

    test('kiểu Thường không có ban đêm', () {
      const normal = MapPreferences(
        kind: MapKind.normal,
        lighting: MapLighting.night,
      );
      expect(normal.isNightAt(DateTime(2026, 11, 3, 23)), isFalse);
    });
  });

  test('lần đổi ngày/đêm kế tiếp', () {
    const auto = MapPreferences();
    expect(
      auto.nextLightingChangeAfter(DateTime(2026, 11, 3, 5)),
      DateTime(2026, 11, 3, 6),
    );
    expect(
      auto.nextLightingChangeAfter(DateTime(2026, 11, 3, 12)),
      DateTime(2026, 11, 3, 18),
    );
    expect(
      auto.nextLightingChangeAfter(DateTime(2026, 11, 3, 18)),
      DateTime(2026, 11, 4, 6),
    );
    expect(
      const MapPreferences(lighting: MapLighting.day)
          .nextLightingChangeAfter(DateTime(2026, 11, 3, 12)),
      isNull,
    );
  });

  group('MapPreferencesNotifier', () {
    Future<ProviderContainer> containerWith(Map<String, Object> values) async {
      SharedPreferences.setMockInitialValues(values);
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('chưa chọn gì thì mặc định Mô hình, ánh sáng tự động', () async {
      final container = await containerWith({});
      expect(container.read(mapPreferencesProvider), const MapPreferences());
    });

    test('lưu lựa chọn và đọc lại được', () async {
      final container = await containerWith({});
      final notifier = container.read(mapPreferencesProvider.notifier);
      await notifier.setKind(MapKind.normal);
      await notifier.setLighting(MapLighting.night);

      final prefs = await SharedPreferences.getInstance();
      expect(jsonDecode(prefs.getString('map_preferences')!), {
        'kind': 'normal',
        'lighting': 'night',
      });

      final reopened = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(reopened.dispose);
      expect(
        reopened.read(mapPreferencesProvider),
        const MapPreferences(kind: MapKind.normal, lighting: MapLighting.night),
      );
    });

    test('dữ liệu hỏng hay giá trị lạ thì dùng mặc định', () async {
      final broken = await containerWith({'map_preferences': '{oops'});
      expect(broken.read(mapPreferencesProvider), const MapPreferences());

      final unknown = await containerWith({
        'map_preferences': '{"kind":"satellite","lighting":"dusk"}',
      });
      expect(unknown.read(mapPreferencesProvider), const MapPreferences());
    });
  });
}
