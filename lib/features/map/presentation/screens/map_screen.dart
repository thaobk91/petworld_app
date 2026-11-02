import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petworld_app/core/location/geo_point.dart';
import 'package:petworld_app/features/house/presentation/state/house_providers.dart';
import 'package:petworld_app/features/map/presentation/widgets/house_marker.dart';
import 'package:petworld_app/features/map/presentation/widgets/house_sheet.dart';
import 'package:petworld_app/shared/widgets/house_pin.dart';
import 'package:petworld_app/shared/widgets/map_layers.dart';

/// Bản đồ công khai. Chỉ dùng `displayLocation`, không bao giờ dùng
/// `realLocation` của ngôi nhà.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  // Hà Nội, chỉ dùng khi chưa có ngôi nhà nào.
  static const _fallbackCenter = GeoPoint(21.0285, 105.8542);

  final _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myHouse = ref.watch(myHouseProvider).value;
    final houses = ref.watch(allHousesProvider).value ?? const [];
    final center = myHouse?.displayLocation ?? _fallbackCenter;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center.toLatLng(),
              initialZoom: 16,
              minZoom: 3,
              // Vị trí đã lệch tới 200 m nên zoom sâu hơn cũng không có ích.
              maxZoom: 17,
              interactionOptions: noRotation,
            ),
            children: [
              petWorldTileLayer(),
              MarkerLayer(
                markers: [
                  for (final house in houses)
                    Marker(
                      point: house.displayLocation.toLatLng(),
                      width: HousePin.width,
                      height: HousePin.height,
                      alignment: Alignment.topCenter,
                      child: HouseMarker(
                        house: house,
                        isMine: house.id == myHouse?.id,
                        onTap: () => showModalBottomSheet<void>(
                          context: context,
                          builder: (_) => HouseSheet(house: house),
                        ),
                      ),
                    ),
                ],
              ),
              mapAttribution(),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              minimum: const EdgeInsets.all(12),
              child: _MapHeader(houseCount: houses.length),
            ),
          ),
        ],
      ),
      floatingActionButton: myHouse == null
          ? null
          : FloatingActionButton(
              // Tab "Nhà của tôi" cũng có FAB trong cùng route (IndexedStack),
              // hai hero trùng tag mặc định sẽ lỗi khi chuyển màn hình.
              heroTag: null,
              tooltip: 'Về nhà của tôi',
              onPressed: () =>
                  _mapController.move(myHouse.displayLocation.toLatLng(), 16),
              child: const Icon(Icons.home_rounded),
            ),
    );
  }
}

class _MapHeader extends StatelessWidget {
  const _MapHeader({required this.houseCount});

  final int houseCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 18, 10),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Text('🐾', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PetWorld', style: theme.textTheme.titleMedium),
                Text(
                  '$houseCount ngôi nhà trên bản đồ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
