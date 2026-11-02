import 'package:petworld_app/core/location/geo_point.dart';
import 'package:petworld_app/features/house/data/datasources/house_local_datasource.dart';
import 'package:petworld_app/features/house/data/models/house_dto.dart';
import 'package:petworld_app/features/house/domain/entities/house.dart';
import 'package:petworld_app/features/house/domain/repositories/house_repository.dart';
import 'package:uuid/uuid.dart';

class HouseRepositoryImpl implements HouseRepository {
  HouseRepositoryImpl(this._local);

  static const _uuid = Uuid();

  final HouseLocalDataSource _local;

  @override
  Future<House?> getMyHouse() async => _local.read()?.toEntity();

  @override
  Future<List<House>> getAllHouses() async {
    final myHouse = await getMyHouse();
    return [?myHouse];
  }

  @override
  Future<House> createHouse({
    required String name,
    required GeoPoint realLocation,
    required GeoPoint displayLocation,
  }) async {
    final house = House(
      id: _uuid.v4(),
      name: name,
      realLocation: realLocation,
      displayLocation: displayLocation,
      createdAt: DateTime.now(),
    );
    await _local.save(HouseDto.fromEntity(house));
    return house;
  }
}
