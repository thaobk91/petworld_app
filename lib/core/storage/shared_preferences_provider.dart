import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Instance được tạo trong `main()` rồi truyền vào qua `overrideWithValue`,
/// để các provider khác dùng đồng bộ mà không phải `await`.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider phải được override trong ProviderScope',
  ),
);
