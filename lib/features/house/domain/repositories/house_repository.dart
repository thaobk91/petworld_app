import 'package:petworld_app/core/location/geo_point.dart';
import 'package:petworld_app/features/house/domain/entities/house.dart';

abstract interface class HouseRepository {
  Future<House?> getMyHouse();

  /// Mọi ngôi nhà hiện trên bản đồ công khai. Bản lưu trên máy chỉ có nhà
  /// của mình.
  Future<List<House>> getAllHouses();

  Future<House> createHouse({
    required String name,
    required GeoPoint realLocation,
    required GeoPoint displayLocation,
  });
}
