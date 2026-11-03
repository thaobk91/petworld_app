import 'package:flutter/material.dart';
import 'package:petworld_app/features/community/presentation/screens/community_screen.dart';
import 'package:petworld_app/features/house/presentation/screens/my_house_screen.dart';
import 'package:petworld_app/features/map/presentation/screens/map_screen.dart';

/// Màn hình chính với 3 tab: Bản đồ, Nhà của tôi, Cộng đồng.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack giữ nguyên trạng thái từng tab (vd vị trí đang xem trên
      // bản đồ) khi chuyển qua lại.
      body: IndexedStack(
        index: _index,
        children: const [MapScreen(), MyHouseScreen(), CommunityScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Bản đồ',
          ),
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Nhà của tôi',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Cộng đồng',
          ),
        ],
      ),
    );
  }
}
