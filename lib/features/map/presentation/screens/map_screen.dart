import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petworld_app/core/location/geo_point.dart';
import 'package:petworld_app/features/house/domain/entities/house.dart';
import 'package:petworld_app/features/house/domain/services/location_fuzzer.dart';
import 'package:petworld_app/features/house/presentation/state/house_providers.dart';
import 'package:petworld_app/features/map/presentation/widgets/house_sheet.dart';
import 'package:petworld_app/features/pets/presentation/state/pet_list_notifier.dart';
import 'package:petworld_app/features/pets/presentation/widgets/pet_labels.dart';
import 'package:petworld_app/shared/map/map_style_sheet.dart';
import 'package:petworld_app/shared/map/pet_map.dart';

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

  final _mapController = PetMapController();

  /// Emoji các loài thú cưng khác nhau trong nhà, để vẽ lên ghim.
  List<String> _petEmojis(House house) {
    final pets = ref.watch(petListProvider(house.id)).value ?? const [];
    return {for (final pet in pets) pet.species.emoji}.toList();
  }

  void _showHouse(List<House> houses, String id) {
    final house = houses.where((house) => house.id == id).firstOrNull;
    if (house == null) return;
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => HouseSheet(house: house),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final myHouse = ref.watch(myHouseProvider).value;
    final houses = ref.watch(allHousesProvider).value ?? const [];
    final center = myHouse?.displayLocation ?? _fallbackCenter;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: PetMap(
              center: center,
              // Vị trí đã lệch tới 200 m, zoom sâu hơn thì ghim nằm đè lên đúng
              // một toà nhà, dễ bị hiểu nhầm là nhà thật.
              maxZoom: 17,
              controller: _mapController,
              markers: [
                for (final house in houses)
                  PetMapMarker(
                    id: house.id,
                    position: house.displayLocation,
                    label: house.name,
                    isMine: house.id == myHouse?.id,
                    pets: _petEmojis(house),
                  ),
              ],
              areas: [
                for (final house in houses)
                  PetMapArea(
                    center: house.displayLocation,
                    radiusMeters: LocationFuzzer.defaultMaxMeters,
                    color: house.id == myHouse?.id
                        ? colors.primary
                        : colors.tertiary,
                  ),
              ],
              onMarkerTap: (id) => _showHouse(houses, id),
            ),
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
              onPressed: () => _mapController.moveTo(myHouse.displayLocation),
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
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
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
          IconButton.filledTonal(
            tooltip: 'Kiểu bản đồ',
            onPressed: () => showMapStyleSheet(context),
            icon: const Icon(Icons.layers_outlined),
          ),
        ],
      ),
    );
  }
}
