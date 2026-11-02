import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petworld_app/app/home_shell.dart';
import 'package:petworld_app/features/house/presentation/screens/register_house_screen.dart';
import 'package:petworld_app/features/house/presentation/state/house_providers.dart';

/// Chưa có nhà thì bắt đăng ký nhà trước, có rồi thì vào màn hình chính.
class AppGate extends ConsumerWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(myHouseProvider)
        .when(
          data: (house) =>
              house == null ? const RegisterHouseScreen() : const HomeShell(),
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, _) => Scaffold(
            body: Center(child: Text('Không tải được dữ liệu: $error')),
          ),
        );
  }
}
