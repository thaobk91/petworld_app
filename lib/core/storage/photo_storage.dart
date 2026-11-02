import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

/// Thư mục documents của app. Lấy trong `main()` rồi truyền vào qua
/// `overrideWithValue`, giống `sharedPreferencesProvider`.
final appDocumentsPathProvider = Provider<String>(
  (ref) => throw UnimplementedError(
    'appDocumentsPathProvider phải được override trong ProviderScope',
  ),
);

final photoStorageProvider = Provider<PhotoStorage>(
  (ref) => PhotoStorage(ref.watch(appDocumentsPathProvider)),
);

/// Lưu ảnh vào thư mục riêng của app.
///
/// Chỉ lưu tên file, không lưu đường dẫn tuyệt đối: trên iOS, thư mục của app
/// đổi đường dẫn sau mỗi lần cập nhật app.
class PhotoStorage {
  PhotoStorage(String documentsPath) : _dir = p.join(documentsPath, 'photos');

  static const _uuid = Uuid();

  final String _dir;

  /// Sao chép [sourcePath] vào bộ nhớ của app, trả về tên file mới.
  Future<String> save(String sourcePath) async {
    await Directory(_dir).create(recursive: true);
    final fileName = '${_uuid.v4()}${p.extension(sourcePath)}';
    await File(sourcePath).copy(p.join(_dir, fileName));
    return fileName;
  }

  String pathOf(String fileName) => p.join(_dir, fileName);
}
