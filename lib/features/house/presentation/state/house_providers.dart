import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petworld_app/core/location/geo_point.dart';
import 'package:petworld_app/features/house/di.dart';
import 'package:petworld_app/features/house/domain/entities/house.dart';

/// Ngôi nhà của người dùng, null khi chưa đăng ký.
final myHouseProvider = AsyncNotifierProvider<MyHouseNotifier, House?>(
  MyHouseNotifier.new,
);

class MyHouseNotifier extends AsyncNotifier<House?> {
  @override
  Future<House?> build() => ref.watch(houseRepositoryProvider).getMyHouse();

  /// Ném lại [ValidationFailure] từ use case để màn hình hiện lỗi.
  Future<void> register({
    required String name,
    required GeoPoint location,
  }) async {
    final house = await ref.read(registerHouseProvider)(
      name: name,
      location: location,
    );
    state = AsyncData(house);
  }
}

/// Các ngôi nhà trên bản đồ công khai. Tự tải lại khi nhà của mình thay đổi.
final allHousesProvider = FutureProvider<List<House>>((ref) async {
  await ref.watch(myHouseProvider.future);
  return ref.watch(houseRepositoryProvider).getAllHouses();
});
