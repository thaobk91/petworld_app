import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petworld_app/core/error/failures.dart';
import 'package:petworld_app/core/location/geo_point.dart';
import 'package:petworld_app/core/location/location_fix.dart';
import 'package:petworld_app/core/location/location_service.dart';
import 'package:petworld_app/core/utils/formatters.dart';
import 'package:petworld_app/features/house/presentation/state/house_providers.dart';
import 'package:petworld_app/shared/map/pet_map.dart';
import 'package:petworld_app/shared/widgets/note_card.dart';
import 'package:petworld_app/shared/widgets/welcome_hero.dart';

class RegisterHouseScreen extends ConsumerStatefulWidget {
  const RegisterHouseScreen({super.key});

  @override
  ConsumerState<RegisterHouseScreen> createState() =>
      _RegisterHouseScreenState();
}

class _RegisterHouseScreenState extends ConsumerState<RegisterHouseScreen> {
  final _nameController = TextEditingController();
  // Vị trí nhà chỉ lấy từ thiết bị (GPS / Wi-Fi / di động). Người dùng không
  // được tự chọn hay tự ghim vị trí trên bản đồ.
  LocationFix? _fix;
  // Đổi key của bản đồ để nó căn lại giữa sau mỗi lần lấy vị trí.
  int _locateCount = 0;
  // Cách đang thử (GPS / Wi-Fi / di động), null khi không định vị.
  LocationMethod? _trying;
  bool _saving = false;
  // Lỗi định vị hiện ngay dưới nút "Lấy vị trí", chỗ người dùng đang nhìn.
  String? _locationError;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _locate() async {
    setState(() {
      _trying = LocationMethod.gps;
      _locationError = null;
    });
    try {
      final fix = await ref
          .read(locationServiceProvider)
          .getCurrentLocation(
            onAttempt: (method) {
              if (mounted) setState(() => _trying = method);
            },
          );
      if (mounted) {
        setState(() {
          _fix = fix;
          _locateCount++;
        });
      }
    } on LocationFailure catch (e) {
      if (mounted) setState(() => _locationError = e.message);
    } finally {
      if (mounted) setState(() => _trying = null);
    }
  }

  // Màn hình không tự kiểm tra tên: quy tắc nằm trong use case RegisterHouse.
  // Đăng ký xong thì AppGate tự chuyển sang màn hình chính.
  Future<void> _register(GeoPoint location) async {
    setState(() => _saving = true);
    try {
      await ref
          .read(myHouseProvider.notifier)
          .register(name: _nameController.text, location: location);
    } on ValidationFailure catch (e) {
      // SnackBar để luôn thấy được, dù form đang cuộn tới đâu.
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fix = _fix;
    final trying = _trying;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const WelcomeHero(
            emoji: '🏡 🐶 🐱',
            title: 'Chào mừng đến PetWorld',
            message:
                'Đăng ký ngôi nhà, nơi các bé thú cưng của bạn sống, để làm '
                'quen với những người bạn yêu thú cưng quanh đây.',
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StepCard(
                  number: 1,
                  title: 'Đặt tên cho ngôi nhà',
                  child: TextField(
                    controller: _nameController,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      hintText: 'vd: Nhà của Milu',
                      prefixIcon: Icon(Icons.home_outlined),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _StepCard(
                  number: 2,
                  title: 'Vị trí ngôi nhà',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 200,
                          child: fix == null
                              ? const _MapPlaceholder()
                              : _LocationPreview(
                                  key: ValueKey(_locateCount),
                                  fix: fix,
                                ),
                        ),
                      ),
                      if (fix != null) ...[
                        const SizedBox(height: 10),
                        _FixInfo(fix: fix),
                      ],
                      // Đặt trên nút để không bị thanh "Đăng ký" che mất.
                      if (_locationError case final error?) ...[
                        const SizedBox(height: 12),
                        _ErrorBanner(message: error),
                      ],
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: trying != null ? null : _locate,
                        icon: trying != null
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.my_location),
                        label: Text(switch (trying) {
                          LocationMethod.gps => 'Đang dò GPS...',
                          LocationMethod.wifi => 'GPS yếu, đang thử Wi-Fi...',
                          LocationMethod.cellular => 'Đang thử mạng di động...',
                          null when fix == null => 'Lấy vị trí hiện tại',
                          null => 'Lấy lại vị trí',
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const NoteCard(
                  emoji: '🔒',
                  title: 'Vị trí thật chỉ lưu cho bạn',
                  message:
                      'Trên bản đồ công khai, nhà của bạn hiện ở một điểm '
                      'lệch ngẫu nhiên 50–200 m so với vị trí thật.',
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton(
          onPressed: fix == null || _saving ? null : () => _register(fix.point),
          child: const Text('Đăng ký ngôi nhà'),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.number,
    required this.title,
    required this.child,
  });

  final int number;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: colors.primaryContainer,
                  child: Text(
                    '$number',
                    style: TextStyle(
                      color: colors.onPrimaryContainer,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 40, color: muted),
          const SizedBox(height: 8),
          Text(
            'Bấm nút bên dưới để lấy vị trí nhà bạn',
            style: theme.textTheme.bodyMedium?.copyWith(color: muted),
          ),
        ],
      ),
    );
  }
}

/// Bản đồ chỉ để xem vị trí máy vừa lấy được. Không cho chạm, kéo hay zoom,
/// vì người dùng không được tự đặt ghim. Luôn nhìn thẳng từ trên xuống để
/// thấy rõ vòng sai số.
class _LocationPreview extends StatelessWidget {
  const _LocationPreview({super.key, required this.fix});

  final LocationFix fix;

  // Sai số lớn (vd định vị qua trạm di động) thì thu nhỏ bản đồ để thấy
  // được cả vòng tròn sai số.
  double get _zoom => switch (fix.accuracyMeters) {
    null => 16,
    <= 60 => 17,
    <= 300 => 16,
    <= 1500 => 14,
    _ => 12,
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accuracy = fix.accuracyMeters;

    return PetMap(
      center: fix.point,
      zoom: _zoom,
      interactive: false,
      flat: true,
      markers: [PetMapMarker(id: 'preview', position: fix.point, isMine: true)],
      areas: [
        if (accuracy != null && accuracy > 0)
          PetMapArea(
            center: fix.point,
            radiusMeters: accuracy,
            color: colors.primary,
          ),
      ],
    );
  }
}

/// Nguồn vị trí và sai số. Sai số lớn thì nhắc cách lấy lại cho chính xác
/// hơn (người dùng không được tự chỉnh ghim).
class _FixInfo extends StatelessWidget {
  const _FixInfo({required this.fix});

  /// Từ ngưỡng này trở lên thì nhắc người dùng lấy lại vị trí.
  static const _roughAccuracyMeters = 150.0;

  final LocationFix fix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: colors.onSurfaceVariant,
    );

    final (icon, source) = switch (fix.method) {
      LocationMethod.gps => (Icons.satellite_alt_outlined, 'GPS'),
      LocationMethod.wifi => (Icons.wifi, 'Wi-Fi'),
      LocationMethod.cellular => (Icons.cell_tower, 'mạng di động'),
    };
    final meters = fix.accuracyMeters;
    final accuracy = meters == null ? null : formatDistance(meters);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: colors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                accuracy == null
                    ? 'Lấy từ $source · không rõ sai số'
                    : 'Lấy từ $source · sai số khoảng $accuracy',
                style: muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (meters != null && meters >= _roughAccuracyMeters)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.tertiaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Vị trí lấy từ $source chỉ chính xác trong khoảng $accuracy. '
              'Hãy bật Wi-Fi hoặc ra chỗ thoáng để bắt GPS, rồi bấm '
              '"Lấy lại vị trí".',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onTertiaryContainer,
              ),
            ),
          )
        else
          Text('Vị trí do máy tự xác định.', style: muted),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colors.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colors.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
