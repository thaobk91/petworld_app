import 'package:petworld_app/core/location/geo_point.dart';
import 'package:petworld_app/features/house/domain/entities/house.dart';

/// Tên khoá viết kiểu snake_case cho khớp với cột của bảng khi lên backend.
class HouseDto {
  const HouseDto({
    required this.id,
    required this.name,
    required this.realLat,
    required this.realLng,
    required this.displayLat,
    required this.displayLng,
    required this.createdAt,
  });

  factory HouseDto.fromJson(Map<String, dynamic> json) => HouseDto(
    id: json['id'] as String,
    name: json['name'] as String,
    realLat: (json['real_lat'] as num).toDouble(),
    realLng: (json['real_lng'] as num).toDouble(),
    displayLat: (json['display_lat'] as num).toDouble(),
    displayLng: (json['display_lng'] as num).toDouble(),
    createdAt: json['created_at'] as String,
  );

  factory HouseDto.fromEntity(House house) => HouseDto(
    id: house.id,
    name: house.name,
    realLat: house.realLocation.latitude,
    realLng: house.realLocation.longitude,
    displayLat: house.displayLocation.latitude,
    displayLng: house.displayLocation.longitude,
    createdAt: house.createdAt.toIso8601String(),
  );

  final String id;
  final String name;
  final double realLat;
  final double realLng;
  final double displayLat;
  final double displayLng;
  final String createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'real_lat': realLat,
    'real_lng': realLng,
    'display_lat': displayLat,
    'display_lng': displayLng,
    'created_at': createdAt,
  };

  House toEntity() => House(
    id: id,
    name: name,
    realLocation: GeoPoint(realLat, realLng),
    displayLocation: GeoPoint(displayLat, displayLng),
    createdAt: DateTime.parse(createdAt),
  );
}
