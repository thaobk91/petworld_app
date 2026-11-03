import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petworld_app/core/storage/shared_preferences_provider.dart';

/// Kiểu bản đồ người dùng chọn.
enum MapKind {
  /// Thành phố đồ chơi: nhà nổi khối 3D, camera nghiêng, màu pastel.
  model('Mô hình', '🧸', 'Nhà nổi khối 3D, nhìn nghiêng như thành phố đồ chơi'),

  /// Bản đồ phẳng, rõ tên đường. Hợp khi đi tìm thú cưng đi lạc.
  normal('Thường', '🗺️', 'Bản đồ phẳng, rõ tên đường, dễ tìm đường');

  const MapKind(this.label, this.emoji, this.description);

  final String label;
  final String emoji;
  final String description;
}

/// Ánh sáng của kiểu Mô hình.
enum MapLighting {
  auto('Tự động'),
  day('Ngày'),
  night('Đêm');

  const MapLighting(this.label);

  final String label;
}

class MapPreferences {
  const MapPreferences({
    this.kind = MapKind.model,
    this.lighting = MapLighting.auto,
  });

  factory MapPreferences.fromJson(Map<String, dynamic> json) => MapPreferences(
    kind: MapKind.values.asNameMap()[json['kind']] ?? MapKind.model,
    lighting:
        MapLighting.values.asNameMap()[json['lighting']] ?? MapLighting.auto,
  );

  /// Giờ bắt đầu và kết thúc ban đêm khi để [MapLighting.auto].
  static const nightStartHour = 18;
  static const nightEndHour = 6;

  final MapKind kind;
  final MapLighting lighting;

  /// Bản đồ có vẽ theo kiểu ban đêm ở thời điểm [time] không. Chỉ kiểu Mô hình
  /// có ban đêm.
  bool isNightAt(DateTime time) =>
      kind == MapKind.model &&
      switch (lighting) {
        MapLighting.day => false,
        MapLighting.night => true,
        MapLighting.auto =>
          time.hour >= nightStartHour || time.hour < nightEndHour,
      };

  /// Thời điểm sau [time] mà [isNightAt] có thể đổi, để bản đồ tự chuyển
  /// ngày/đêm khi đang mở. Null nếu không bao giờ đổi.
  DateTime? nextLightingChangeAfter(DateTime time) {
    if (kind != MapKind.model || lighting != MapLighting.auto) return null;
    final today = DateTime(time.year, time.month, time.day);
    for (final candidate in [
      today.add(const Duration(hours: nightEndHour)),
      today.add(const Duration(hours: nightStartHour)),
      today.add(const Duration(days: 1, hours: nightEndHour)),
    ]) {
      if (candidate.isAfter(time)) return candidate;
    }
    return null;
  }

  MapPreferences copyWith({MapKind? kind, MapLighting? lighting}) =>
      MapPreferences(
        kind: kind ?? this.kind,
        lighting: lighting ?? this.lighting,
      );

  Map<String, dynamic> toJson() => {
    'kind': kind.name,
    'lighting': lighting.name,
  };

  @override
  bool operator ==(Object other) =>
      other is MapPreferences &&
      other.kind == kind &&
      other.lighting == lighting;

  @override
  int get hashCode => Object.hash(kind, lighting);
}

/// Lựa chọn kiểu bản đồ, lưu trên máy. Chỉ là tuỳ chọn giao diện nên đọc ghi
/// thẳng SharedPreferences, không qua repository.
final mapPreferencesProvider =
    NotifierProvider<MapPreferencesNotifier, MapPreferences>(
      MapPreferencesNotifier.new,
    );

class MapPreferencesNotifier extends Notifier<MapPreferences> {
  static const _key = 'map_preferences';

  @override
  MapPreferences build() {
    final raw = ref.watch(sharedPreferencesProvider).getString(_key);
    if (raw == null) return const MapPreferences();
    try {
      if (jsonDecode(raw) case final Map<String, dynamic> json) {
        return MapPreferences.fromJson(json);
      }
    } on FormatException {
      // Dữ liệu hỏng thì dùng mặc định, lần lưu sau sẽ ghi đè.
    }
    return const MapPreferences();
  }

  Future<void> setKind(MapKind kind) => _save(state.copyWith(kind: kind));

  Future<void> setLighting(MapLighting lighting) =>
      _save(state.copyWith(lighting: lighting));

  Future<void> _save(MapPreferences preferences) async {
    state = preferences;
    await ref
        .read(sharedPreferencesProvider)
        .setString(_key, jsonEncode(preferences.toJson()));
  }
}
