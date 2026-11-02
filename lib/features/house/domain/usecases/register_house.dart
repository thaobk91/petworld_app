import 'package:petworld_app/core/error/failures.dart';
import 'package:petworld_app/core/location/geo_point.dart';
import 'package:petworld_app/features/house/domain/entities/house.dart';
import 'package:petworld_app/features/house/domain/repositories/house_repository.dart';
import 'package:petworld_app/features/house/domain/services/location_fuzzer.dart';

class RegisterHouse {
  RegisterHouse(this._repository, this._fuzzer);

  static const maxNameLength = 40;

  final HouseRepository _repository;
  final LocationFuzzer _fuzzer;

  /// Ném [ValidationFailure] khi tên không hợp lệ hoặc đã có nhà.
  Future<House> call({required String name, required GeoPoint location}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationFailure('Hãy đặt tên cho ngôi nhà');
    }
    if (trimmed.length > maxNameLength) {
      throw const ValidationFailure('Tên nhà tối đa $maxNameLength ký tự');
    }
    if (await _repository.getMyHouse() != null) {
      throw const ValidationFailure('Bạn đã đăng ký nhà rồi');
    }

    // Vị trí lệch chỉ tạo một lần ở đây rồi lưu lại. Nếu mỗi lần hiển thị lại
    // random điểm mới, người xem lấy trung bình nhiều lần sẽ ra vị trí thật.
    return _repository.createHouse(
      name: trimmed,
      realLocation: location,
      displayLocation: _fuzzer.fuzz(location),
    );
  }
}
