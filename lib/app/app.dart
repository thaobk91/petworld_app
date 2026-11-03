import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petworld_app/core/router/app_router.dart';
import 'package:petworld_app/core/theme/app_theme.dart';

class PetWorldApp extends ConsumerWidget {
  const PetWorldApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'PetWorld',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // Giao diện tối đang tắt: app luôn sáng, kể cả khi điện thoại để chế
      // độ tối. Đổi thành ThemeMode.system để bật lại.
      themeMode: ThemeMode.light,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
