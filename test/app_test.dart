import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petworld_app/app/app.dart';
import 'package:petworld_app/core/error/failures.dart';
import 'package:petworld_app/core/location/geo_point.dart';
import 'package:petworld_app/core/location/location_fix.dart';
import 'package:petworld_app/core/location/location_service.dart';
import 'package:petworld_app/core/security/password_hasher.dart';
import 'package:petworld_app/core/storage/photo_storage.dart';
import 'package:petworld_app/core/storage/shared_preferences_provider.dart';
import 'package:petworld_app/features/account/data/models/account_dto.dart';
import 'package:petworld_app/features/house/data/models/house_dto.dart';
import 'package:petworld_app/features/map/presentation/widgets/house_marker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Trả về [fix], hoặc ném [failure] nếu có (vd khi vị trí bị giả lập).
class _FakeLocationService implements LocationService {
  _FakeLocationService(this.fix, {this.failure});

  final LocationFix fix;
  final LocationFailure? failure;

  @override
  Future<LocationFix> getCurrentLocation({
    void Function(LocationMethod method)? onAttempt,
  }) async {
    for (final method in LocationMethod.values) {
      onAttempt?.call(method);
      if (method == fix.method) break;
    }
    if (failure case final failure?) throw failure;
    return fix;
  }
}

/// Băm giả, chạy tức thì. Bản thật chạy ở isolate riêng, không xong được
/// trong thời gian giả của widget test.
class _FakePasswordHasher implements PasswordHasher {
  @override
  Future<String> hash(String password) async => 'hashed-${password.length}';

  @override
  Future<bool> verify(String password, String encoded) async =>
      encoded == 'hashed-${password.length}';
}

const _savedAccount = AccountDto(
  id: 'a1',
  phoneNumber: '+84912345678',
  passwordHash: 'hashed-9',
  createdAt: '2026-11-03T07:00:00.000',
);

const _gpsFix = LocationFix(
  point: GeoPoint(21.0285, 105.8542),
  accuracyMeters: 8,
  method: LocationMethod.gps,
);

const _savedHouse = HouseDto(
  id: 'h1',
  name: 'Nhà của Milu',
  realLat: 21.0285,
  realLng: 105.8542,
  displayLat: 21.0297,
  displayLng: 105.8551,
  createdAt: '2026-11-03T08:00:00.000',
);

void main() {
  late Directory tempDir;

  setUp(() => tempDir = Directory.systemTemp.createTempSync('petworld_app'));

  tearDown(() => tempDir.deleteSync(recursive: true));

  Future<void> pumpApp(
    WidgetTester tester, {
    bool withAccount = true,
    bool withHouse = false,
    LocationFix fix = _gpsFix,
    LocationFailure? locationFailure,
  }) async {
    // Kích thước điện thoại thật (360×800) để bố cục giống trên máy.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({
      if (withAccount) 'account': jsonEncode(_savedAccount.toJson()),
      if (withHouse) 'house': jsonEncode(_savedHouse.toJson()),
    });
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appDocumentsPathProvider.overrideWithValue(tempDir.path),
          locationServiceProvider.overrideWithValue(
            _FakeLocationService(fix, failure: locationFailure),
          ),
          passwordHasherProvider.overrideWithValue(_FakePasswordHasher()),
        ],
        child: const PetWorldApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openMyHouseTab(WidgetTester tester) async {
    await tester.tap(find.text('Nhà của tôi'));
    await tester.pumpAndSettle();
  }

  Future<void> fillAccountForm(
    WidgetTester tester, {
    String phone = '0912 345 678',
    String password = 'Milu@2026',
    String? confirm,
  }) async {
    for (final (label, text) in [
      ('Số điện thoại', phone),
      ('Mật khẩu', password),
      ('Nhập lại mật khẩu', confirm ?? password),
    ]) {
      final field = find.widgetWithText(TextFormField, label);
      await tester.ensureVisible(field);
      await tester.enterText(field, text);
    }
    await tester.pumpAndSettle();
  }

  Future<void> tapCreateAccount(WidgetTester tester) async {
    await tester.tap(find.text('Tạo tài khoản'));
    await tester.pumpAndSettle();
  }

  testWidgets('chưa có tài khoản: đăng ký tài khoản rồi tới đăng ký nhà', (
    tester,
  ) async {
    await pumpApp(tester, withAccount: false);
    expect(find.text('Tạo tài khoản PetWorld'), findsOneWidget);
    expect(find.text('+84'), findsOneWidget);

    await fillAccountForm(tester);
    await tapCreateAccount(tester);

    expect(find.text('Chào mừng đến PetWorld'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    final saved =
        jsonDecode(prefs.getString('account')!) as Map<String, dynamic>;
    expect(saved['phone_number'], '+84912345678');
    // Chỉ lưu mã băm, không lưu mật khẩu nguyên văn.
    expect(saved['password_hash'], 'hashed-9');
    expect(prefs.getString('account'), isNot(contains('Milu@2026')));
  });

  testWidgets('nhập sai thì báo lỗi dưới từng ô, không tạo tài khoản', (
    tester,
  ) async {
    await pumpApp(tester, withAccount: false);
    await fillAccountForm(
      tester,
      phone: '0912',
      password: 'milu2026',
      confirm: 'milu2025',
    );
    await tapCreateAccount(tester);

    expect(find.text('Số điện thoại di động không đúng'), findsOneWidget);
    expect(
      find.text('Mật khẩu cần có ít nhất 1 ký tự đặc biệt'),
      findsOneWidget,
    );
    expect(find.text('Mật khẩu nhập lại không khớp'), findsOneWidget);
    expect(find.text('Tạo tài khoản PetWorld'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('account'), isNull);
  });

  testWidgets('danh sách yêu cầu mật khẩu được tích dần khi gõ', (
    tester,
  ) async {
    await pumpApp(tester, withAccount: false);
    final password = find.widgetWithText(TextFormField, 'Mật khẩu');
    final checked = find.byIcon(Icons.check_circle);

    await tester.enterText(password, 'milu');
    await tester.pump();
    expect(checked, findsOneWidget); // có chữ cái

    await tester.enterText(password, 'milu2026');
    await tester.pump();
    expect(checked, findsNWidgets(3)); // + chữ số, đủ 8 ký tự

    await tester.enterText(password, 'milu@2026');
    await tester.pump();
    expect(checked, findsNWidgets(4)); // + ký tự đặc biệt
  });

  testWidgets('chọn quốc gia khác thì kiểm tra và lưu theo mã vùng đó', (
    tester,
  ) async {
    await pumpApp(tester, withAccount: false);

    await tester.tap(find.text('+84'));
    await tester.pumpAndSettle();
    expect(find.text('Chọn quốc gia'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Tìm tên nước hoặc mã vùng'),
      'nhat',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nhật Bản'));
    await tester.pumpAndSettle();

    expect(find.text('Chọn quốc gia'), findsNothing);
    expect(find.text('+81'), findsOneWidget);

    await fillAccountForm(tester, phone: '090 1234 5678');
    await tapCreateAccount(tester);

    final prefs = await SharedPreferences.getInstance();
    final saved =
        jsonDecode(prefs.getString('account')!) as Map<String, dynamic>;
    expect(saved['phone_number'], '+819012345678');
  });

  testWidgets('chưa có nhà: đăng ký nhà rồi vào màn hình chính', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Chào mừng đến PetWorld'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Nhà của Milu');
    // Nút nằm sát mép trên thanh "Đăng ký ngôi nhà", cuộn tới cho chắc.
    await tester.ensureVisible(find.text('Lấy vị trí hiện tại'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lấy vị trí hiện tại'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đăng ký ngôi nhà'));
    await tester.pumpAndSettle();

    expect(find.text('PetWorld'), findsOneWidget);
    await openMyHouseTab(tester);
    expect(find.text('Nhà của Milu'), findsOneWidget);
    expect(find.text('Chưa có thú cưng nào'), findsOneWidget);
  });

  Future<void> tapLocate(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Lấy vị trí hiện tại'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lấy vị trí hiện tại'));
    await tester.pumpAndSettle();
  }

  testWidgets('GPS cho sai số nhỏ thì chỉ báo nguồn, không nhắc lấy lại', (
    tester,
  ) async {
    await pumpApp(tester);
    await tapLocate(tester);

    expect(find.text('Lấy từ GPS · sai số khoảng 8 m'), findsOneWidget);
    expect(find.textContaining('Hãy bật Wi-Fi'), findsNothing);
  });

  testWidgets('không cho tự ghim: chạm hay kéo bản đồ không đổi vị trí', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.enterText(find.byType(TextField), 'Nhà của Milu');
    await tapLocate(tester);

    final map = find.byType(FlutterMap);
    await tester.tapAt(tester.getCenter(map) + const Offset(60, 40));
    await tester.drag(map, const Offset(-80, 50));
    await tester.pumpAndSettle();

    final marker = tester
        .widget<MarkerLayer>(find.byType(MarkerLayer))
        .markers
        .single;
    expect(marker.point.latitude, _gpsFix.point.latitude);
    expect(marker.point.longitude, _gpsFix.point.longitude);

    await tester.tap(find.text('Đăng ký ngôi nhà'));
    await tester.pumpAndSettle();

    // Vị trí thật được lưu đúng là vị trí máy trả về.
    final prefs = await SharedPreferences.getInstance();
    final saved = jsonDecode(prefs.getString('house')!) as Map<String, dynamic>;
    expect(saved['real_lat'], _gpsFix.point.latitude);
    expect(saved['real_lng'], _gpsFix.point.longitude);
  });

  testWidgets('vị trí giả lập: báo lỗi chỗ thấy được, không cho đăng ký', (
    tester,
  ) async {
    await pumpApp(
      tester,
      locationFailure: const LocationFailure(
        'PetWorld không nhận vị trí giả lập. Hãy tắt ứng dụng giả lập vị trí '
        '(fake GPS) rồi thử lại.',
      ),
    );
    await tester.enterText(find.byType(TextField), 'Nhà của Milu');
    await tapLocate(tester);

    final error = find.textContaining('không nhận vị trí giả lập');
    expect(error, findsOneWidget);
    // Lỗi phải nằm phía trên thanh nút "Đăng ký", tức là đang thấy được.
    expect(
      tester.getBottomLeft(error).dy,
      lessThan(tester.getTopLeft(find.text('Đăng ký ngôi nhà')).dy),
    );
    final register = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Đăng ký ngôi nhà'),
    );
    expect(register.onPressed, isNull);
  });

  testWidgets('vị trí từ mạng di động sai số lớn thì nhắc lấy lại vị trí', (
    tester,
  ) async {
    await pumpApp(
      tester,
      fix: const LocationFix(
        point: GeoPoint(21.03, 105.86),
        accuracyMeters: 1800,
        method: LocationMethod.cellular,
      ),
    );
    await tapLocate(tester);

    expect(
      find.text('Lấy từ mạng di động · sai số khoảng 1,8 km'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Hãy bật Wi-Fi hoặc ra chỗ thoáng'),
      findsOneWidget,
    );
    expect(find.byType(CircleLayer), findsOneWidget);
  });

  testWidgets('bản đồ đặt ngôi nhà ở vị trí lệch, không phải vị trí thật', (
    tester,
  ) async {
    await pumpApp(tester, withHouse: true);

    final marker = tester
        .widget<MarkerLayer>(find.byType(MarkerLayer))
        .markers
        .single;
    expect(marker.point.latitude, _savedHouse.displayLat);
    expect(marker.point.longitude, _savedHouse.displayLng);

    await tester.tap(find.byType(HouseMarker));
    await tester.pumpAndSettle();
    expect(find.text('Nhà của Milu'), findsOneWidget);
    expect(find.text('Nhà này chưa có thú cưng nào'), findsOneWidget);
  });

  testWidgets('thêm thú cưng rồi mở trang chi tiết', (tester) async {
    await pumpApp(tester, withHouse: true);
    await openMyHouseTab(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Tên'), 'Milu');
    await tester.tap(find.text('Mèo'));
    await tester.tap(find.text('Lưu thú cưng'));
    await tester.pumpAndSettle();

    expect(find.text('Milu'), findsOneWidget);
    expect(find.text('Mèo'), findsOneWidget);
    expect(find.text('1 thú cưng'), findsOneWidget);

    await tester.tap(find.text('Milu'));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có ảnh nào'), findsOneWidget);
    expect(find.text('Mèo'), findsOneWidget);
  });

  testWidgets('tên trống thì báo lỗi và ở lại màn hình thêm', (tester) async {
    await pumpApp(tester, withHouse: true);
    await openMyHouseTab(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu thú cưng'));
    await tester.pumpAndSettle();

    expect(find.text('Tên thú cưng không được để trống'), findsOneWidget);
    expect(find.text('Thêm thú cưng'), findsOneWidget);
  });
}
