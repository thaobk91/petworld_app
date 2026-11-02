import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petworld_app/core/media/photo_picker.dart';

/// Hỏi người dùng chụp ảnh hay chọn từ thư viện, rồi trả về đường dẫn file
/// tạm. Trả về null nếu người dùng huỷ.
Future<String?> pickPhoto(BuildContext context, WidgetRef ref) async {
  final source = await showModalBottomSheet<PhotoSource>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Chụp ảnh'),
            onTap: () => Navigator.pop(context, PhotoSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Chọn từ thư viện'),
            onTap: () => Navigator.pop(context, PhotoSource.gallery),
          ),
        ],
      ),
    ),
  );
  if (source == null) return null;
  return ref.read(photoPickerProvider).pick(source);
}
