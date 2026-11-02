import 'dart:convert';

import 'package:petworld_app/features/pets/data/models/pet_dto.dart';
import 'package:petworld_app/features/pets/data/models/pet_photo_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lưu thú cưng và thông tin ảnh dạng JSON trên máy. File ảnh nằm riêng
/// trong PhotoStorage.
class PetLocalDataSource {
  PetLocalDataSource(this._prefs);

  static const _petsKey = 'pets';
  static const _photosKey = 'pet_photos';

  final SharedPreferences _prefs;

  List<PetDto> readPets() => _readList(_petsKey, PetDto.fromJson);

  Future<void> savePets(List<PetDto> pets) =>
      _saveList(_petsKey, pets.map((pet) => pet.toJson()));

  List<PetPhotoDto> readPhotos() => _readList(_photosKey, PetPhotoDto.fromJson);

  Future<void> savePhotos(List<PetPhotoDto> photos) =>
      _saveList(_photosKey, photos.map((photo) => photo.toJson()));

  List<T> _readList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((item) => fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<void> _saveList(
    String key,
    Iterable<Map<String, dynamic>> items,
  ) async {
    await _prefs.setString(key, jsonEncode(items.toList()));
  }
}
