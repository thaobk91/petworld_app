import 'package:flutter_test/flutter_test.dart';
import 'package:petworld_app/core/location/geo_point.dart';
import 'package:petworld_app/features/house/data/datasources/house_local_datasource.dart';
import 'package:petworld_app/features/house/data/repositories/house_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<HouseRepositoryImpl> createRepository() async {
    final prefs = await SharedPreferences.getInstance();
    return HouseRepositoryImpl(HouseLocalDataSource(prefs));
  }

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('chưa đăng ký thì chưa có nhà nào', () async {
    final repository = await createRepository();

    expect(await repository.getMyHouse(), isNull);
    expect(await repository.getAllHouses(), isEmpty);
  });

  test('đọc lại giữ nguyên cả vị trí thật lẫn vị trí lệch', () async {
    const real = GeoPoint(21.0285, 105.8542);
    const display = GeoPoint(21.0297, 105.8551);
    final created = await (await createRepository()).createHouse(
      name: 'Nhà của Milu',
      realLocation: real,
      displayLocation: display,
    );

    final reloaded = await createRepository();
    final house = await reloaded.getMyHouse();

    expect(house!.id, created.id);
    expect(house.name, 'Nhà của Milu');
    expect(house.realLocation, real);
    expect(house.displayLocation, display);
    expect(house.createdAt, created.createdAt);
    expect(await reloaded.getAllHouses(), hasLength(1));
  });
}
