import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petworld_app/app/home_shell.dart';
import 'package:petworld_app/features/account/presentation/screens/register_account_screen.dart';
import 'package:petworld_app/features/account/presentation/state/account_providers.dart';
import 'package:petworld_app/features/house/presentation/screens/register_house_screen.dart';
import 'package:petworld_app/features/house/presentation/state/house_providers.dart';

/// Chưa có tài khoản thì đăng ký tài khoản, rồi tới đăng ký nhà, có đủ cả
/// hai thì vào màn hình chính.
class AppGate extends ConsumerWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch ((ref.watch(myAccountProvider), ref.watch(myHouseProvider))) {
      (AsyncError(:final error), _) || (_, AsyncError(:final error)) =>
        Scaffold(body: Center(child: Text('Không tải được dữ liệu: $error'))),
      (AsyncData(value: null), _) => const RegisterAccountScreen(),
      (AsyncData(), AsyncData(value: null)) => const RegisterHouseScreen(),
      (AsyncData(), AsyncData()) => const HomeShell(),
      _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
    };
  }
}
