import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:petworld_app/core/error/failures.dart';
import 'package:petworld_app/core/location/geo_point.dart';
import 'package:petworld_app/features/house/domain/entities/house.dart';
import 'package:petworld_app/features/house/domain/repositories/house_repository.dart';
import 'package:petworld_app/features/house/domain/services/location_fuzzer.dart';
import 'package:petworld_app/features/house/domain/usecases/register_house.dart';

class _FakeHouseRepository implements HouseRepository {
  House? house;

  @override
  Future<House?> getMyHouse() async => house;

  @override
  Future<List<House>> getAllHouses() async => [?house];

  @override
  Future<House> createHouse({
    required String name,
    required GeoPoint realLocation,
    required GeoPoint displayLocation,
  }) async {
    return house = House(
      id: 'h1',
      name: name,
      realLocation: realLocation,
      displayLocation: displayLocation,
      createdAt: DateTime(2026, 11, 3),
    );
  }
}

void main() {
  const home = GeoPoint(21.0285, 105.8542);
  late _FakeHouseRepository repository;
  late RegisterHouse registerHouse;

  setUp(() {
    repository = _FakeHouseRepository();
    registerHouse = RegisterHouse(
      repository,
      LocationFuzzer(random: Random(3)),
    );
  });

  test('lưu nguyên vị trí thật và tạo vị trí lệch 50–200 m', () async {
    final house = await registerHouse(name: '  Nhà của Milu ', location: home);

    expect(house.name, 'Nhà của Milu');
    expect(house.realLocation, home);
    expect(
      house.realLocation.distanceTo(house.displayLocation),
      inInclusiveRange(49.5, 200.5),
    );
  });

  test('chỉ được đăng ký một ngôi nhà', () async {
    await registerHouse(name: 'Nhà 1', location: home);

    await expectLater(
      registerHouse(name: 'Nhà 2', location: home),
      throwsA(isA<ValidationFailure>()),
    );
    expect(repository.house!.name, 'Nhà 1');
  });

  test('từ chối tên trống', () async {
    await expectLater(
      registerHouse(name: '   ', location: home),
      throwsA(isA<ValidationFailure>()),
    );
    expect(repository.house, isNull);
  });

  test('từ chối tên dài quá giới hạn', () async {
    await expectLater(
      registerHouse(
        name: 'a' * (RegisterHouse.maxNameLength + 1),
        location: home,
      ),
      throwsA(isA<ValidationFailure>()),
    );
  });
}
