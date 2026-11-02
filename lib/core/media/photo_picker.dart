import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

enum PhotoSource { camera, gallery }

final photoPickerProvider = Provider<PhotoPicker>((ref) => PhotoPicker());

class PhotoPicker {
  final _picker = ImagePicker();

  /// Trả về đường dẫn file tạm, hoặc null nếu người dùng huỷ.
  /// Ảnh được thu nhỏ trước để đỡ tốn bộ nhớ.
  Future<String?> pick(PhotoSource source) async {
    final file = await _picker.pickImage(
      source: switch (source) {
        PhotoSource.camera => ImageSource.camera,
        PhotoSource.gallery => ImageSource.gallery,
      },
      maxWidth: 1600,
      imageQuality: 85,
    );
    return file?.path;
  }
}
