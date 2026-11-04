# petworld_app

Hướng dẫn cho Claude khi làm việc trong dự án này.

## Tổng quan

- PetWorld: app mobile viết bằng Flutter. Mỗi người dùng đăng ký một ngôi nhà, trong nhà có các thú cưng với hồ sơ và ảnh riêng. Ngôi nhà hiện trên bản đồ công khai.
- Mục đích: khoe thú cưng, trò chuyện với người xung quanh, chia sẻ kiến thức chăm sóc, tìm thú cưng đi lạc. Xem `memory.md` để biết phần nào đã làm.
- Bản hiện tại lưu mọi thứ trên máy, chưa có backend. Bản đồ chỉ có nhà của chính mình, Cộng đồng chỉ có nhóm có sẵn và nhóm, bài của chính mình.
- Màn hình chính có 3 tab: Bản đồ → Nhà của tôi → Cộng đồng.
- Luồng vào app (`AppGate`): đăng ký tài khoản (số điện thoại + mật khẩu) → đăng ký nhà → màn hình chính.

## Công nghệ

- Flutter 3.47.9, Dart 3.13.7. Nền tảng: Android và iOS (build iOS phải có macOS + Xcode).
- State management và DI: `flutter_riverpod` 3, không dùng code generation, không dùng get_it.
- Điều hướng: `go_router`.
- Bản đồ: `maplibre_gl` (MapLibre Native), tile vector OpenFreeMap (dữ liệu OSM, schema OpenMapTiles). Style tự viết trong Dart (`shared/map/pet_map_style.dart`), có 2 kiểu: Mô hình (3D, ngày/đêm) và Thường (2D).
- Yêu cầu nền tảng do MapLibre: Android API 24+, build Android cần JDK 21, iOS 15.5+.
- Vị trí: `geolocator`. Ảnh: `image_picker`, file lưu trong thư mục documents (`path_provider`).
- Lưu trữ: `shared_preferences` (dữ liệu JSON). ID tạo bằng `uuid`.
- Số điện thoại: `phone_numbers_parser` (kiểm tra theo từng quốc gia, đổi sang E.164). Băm mật khẩu: `crypto` (PBKDF2 tự viết theo RFC 8018, có test với vector chuẩn).
- Lint: `flutter_lints`.

## Lệnh thường dùng

Flutter SDK nằm ở `C:\develop\flutter\bin`. Nếu thư mục này chưa có trong PATH thì gọi bằng đường dẫn đầy đủ.

```bash
flutter pub get      # cài dependency
flutter run          # chạy app trên thiết bị/emulator
flutter test         # chạy test
flutter analyze      # kiểm tra lỗi tĩnh
dart format lib test # định dạng code
```

## Cấu trúc thư mục

```
lib/
├── main.dart              # khởi tạo SharedPreferences, thư mục documents, ProviderScope
├── app/                   # PetWorldApp, AppGate (tài khoản → nhà → màn hình chính), HomeShell (3 tab)
├── core/                  # dùng chung toàn app, không phụ thuộc feature (trừ router)
│   ├── error/             # Failure, ValidationFailure, LocationFailure
│   ├── location/          # GeoPoint, LocationFix, LocationService (GPS → Wi-Fi → mạng di động)
│   ├── media/             # PhotoPicker (camera/thư viện)
│   ├── router/            # app_routes.dart, app_router.dart (GoRouter)
│   ├── security/          # PasswordHasher (PBKDF2-HMAC-SHA256)
│   ├── storage/           # sharedPreferencesProvider, PhotoStorage
│   ├── theme/
│   └── utils/             # formatDate, formatAge, formatTimeAgo, foldForSearch (tìm không dấu)
├── shared/
│   ├── map/               # PetMap (bản đồ dùng chung), style 2 kiểu, ảnh ghim nhà, lựa chọn kiểu bản đồ
│   └── widgets/           # widget dùng ở nhiều tính năng: pickPhoto, WelcomeHero, NoteCard
└── features/
    ├── account/           # đăng ký tài khoản: số điện thoại theo quốc gia, mật khẩu
    ├── community/         # Cộng đồng: nhóm (có sẵn, tự tạo), tham gia/rời, bài viết chữ trong nhóm
    ├── house/             # đăng ký nhà, LocationFuzzer, màn hình "Nhà của tôi"
    ├── pets/              # hồ sơ thú cưng, ảnh đại diện, bộ sưu tập ảnh
    └── map/               # bản đồ công khai (chỉ presentation, đọc dữ liệu từ house)
        mỗi feature:
        ├── di.dart        # provider nối interface domain với implementation data
        ├── domain/        # NGHIỆP VỤ: entities/, repositories/ (interface), usecases/, services/
        ├── data/          # DỮ LIỆU: models/ (DTO), datasources/, repositories/ (impl)
        └── presentation/  # UI: screens/, widgets/, state/ (Notifier của Riverpod)
test/                      # chia thư mục giống lib/
```

`core/network/` chưa có, sẽ tạo khi nối backend.

## Quy ước kiến trúc

- Chiều phụ thuộc: `presentation → domain ← data`.
- `domain` là Dart thuần, không import Flutter, Riverpod hay thư viện lưu trữ/HTTP. Được dùng `core/location/geo_point.dart`, `core/error/`, hàm Dart thuần trong `core/utils/` (vd `foldForSearch`) và thư viện Dart thuần chỉ tính toán (vd `phone_numbers_parser`).
- Form có lỗi theo từng ô thì `validator` của ô gọi chính hàm kiểm tra ở domain (vd `PasswordPolicy.validate`), để thông báo lỗi chỉ viết một chỗ. Use case vẫn kiểm tra lại trước khi lưu.
- `presentation` không import `data`. Repository và use case lấy qua provider trong `di.dart`.
- Quy tắc nghiệp vụ đặt trong use case. Không đặt trong widget hay DTO.
- Use case chỉ thêm khi có quy tắc thật. Nếu chỉ đọc/ghi dữ liệu thì Notifier gọi thẳng repository.
- Use case báo lỗi nghiệp vụ bằng `ValidationFailure`. Màn hình bắt lỗi đó và hiện `message`.
- Service của nền tảng (GPS, chọn ảnh, thư mục app) được bọc sau provider, để test override được.
- Khoá JSON trong DTO viết kiểu snake_case cho khớp với cột bảng khi lên backend.
- Ảnh chỉ lưu **tên file**, không lưu đường dẫn tuyệt đối (trên iOS, thư mục app đổi đường dẫn sau mỗi lần cập nhật).
- Import bằng `package:petworld_app/...`.
- TODO: quy ước nhánh/commit, review.

## Quy ước giao diện

- Phong cách tươi, dễ thương. Màu gốc xanh lá cây `#5DBB63` (`AppPalette.current` = `AppPalette.leafGreen` trong `core/theme/app_theme.dart`), scheme `DynamicSchemeVariant.fidelity`. `AppPalette.coral` (cam san hô) và `AppPalette.deepBlue` (xanh dương đậm) để sẵn nhưng đang tắt; đổi màu app thì đổi `AppPalette.current`.
- **App luôn dùng giao diện sáng** (`themeMode: ThemeMode.light` trong `PetWorldApp`), kể cả khi điện thoại để chế độ tối. `AppTheme.dark()` giữ lại nhưng tắt; đổi sang `ThemeMode.system` để bật lại. Có test trong `test/app_test.dart`.
- Nút chính, FAB, ghim nhà của mình: dùng `primaryContainer` / `onPrimaryContainer`. Không dùng `primary` làm nền lớn, vì với scheme này nó đậm hơn hẳn (xanh rừng `#006E22`), nhìn nặng.
- Nền đầu trang: `AppTheme.softGradient` (`primaryContainer` sang `secondaryContainer`). Không trộn hai màu đối nhau (vd cam với xanh ngọc), ở giữa ra màu xám bẩn.
- Mỗi loài thú cưng có emoji và màu pastel riêng (`pet_labels.dart`). Thú cưng chưa có ảnh thì hiện emoji trên nền pastel đó.
- Widget dùng chung: `EmptyState`, `InfoPill`, `WelcomeHero` (đầu trang màn hình chào mừng), `NoteCard` (ô ghi chú có emoji) trong `shared/widgets/`.
- Ô nhập kiểu filled bo tròn (`UnderlineInputBorder` không viền). Không dùng `OutlineInputBorder`, vì nhãn nổi sẽ rơi ra ngoài ô.
- Chữ trong `Row` phải bọc `Expanded`/`Flexible` để không tràn khi cỡ chữ hệ thống lớn. Widget test chạy ở 360×800 để bắt lỗi tràn. Trong widget test, sau `ensureVisible` phải `pumpAndSettle` rồi mới `tap`, không thì chạm vào vị trí cũ.
- Cả 3 tab nằm chung một route (`IndexedStack`) và đều có FAB, nên FAB của tab Bản đồ và tab Cộng đồng đặt `heroTag: null`.
- Nút mặc định của app (`FilledButton`) rộng hết chiều ngang (`minimumSize` cao 54, rộng vô hạn). Đặt nút trong `Row` thì phải đè `minimumSize` (vd `Size(0, 40)`), như nút "Tham gia" trên thẻ nhóm.
- Menu "..." mở hộp xác nhận thì dùng `onSelected` của `PopupMenuButton`, không dùng `onTap` của `PopupMenuItem`: `onTap` chạy trước khi menu đóng, lệnh đóng menu sẽ đóng nhầm hộp xác nhận.

## Quy tắc về Cộng đồng

- Bản đầu gồm: nhóm (tạo, tham gia, rời) và bài viết chữ trong nhóm. Chưa có bảng tin chung, ảnh trong bài, thích/bình luận, sửa bài, xoá nhóm, quản trị nhóm.
- Nhóm chủ đề có sẵn nằm trong code (`CommunityLocalDataSource.builtInGroups`), không lưu vào dữ liệu. Id cố định dạng `builtin-...`: đổi id thì mất bài viết và việc tham gia của nhóm đó.
- Tạo nhóm (`CreateGroup`): tên 3–50 ký tự, mô tả tối đa 300, không trùng tên nhóm khác (không phân biệt hoa thường và dấu, dùng `foldForSearch`). Người tạo tự tham gia.
- Đăng bài (`AddGroupPost`): chỉ thành viên, 1–1000 ký tự. Người đăng là ngôi nhà: lưu `author_house_id` và `author_name` (tên nhà lúc đăng).
- Xoá bài (`DeleteGroupPost`): chỉ người đăng.
- Khoá lưu trữ: `community_groups`, `community_joined_groups`, `community_posts`.

## Quy tắc về tài khoản và mật khẩu

- Đăng ký bằng số điện thoại + mật khẩu + nhập lại mật khẩu. Mỗi máy một tài khoản (bản lưu trên máy).
- Số điện thoại: người dùng chọn quốc gia (mặc định Việt Nam, có tìm kiếm không dấu). Chỉ nhận **số di động** hợp lệ của nước đã chọn, vì sau này gửi OTP qua SMS. Lưu dạng E.164 (`+84912345678`). Quy tắc nằm trong `PhoneNumberRules`.
- Mật khẩu (`PasswordPolicy`): ít nhất 8 ký tự, có chữ cái (kể cả chữ có dấu), có chữ số, có ít nhất 1 ký tự đặc biệt (bất kỳ ký tự nào không phải chữ, số hay khoảng trắng). Tối đa 64 ký tự. Độ dài đếm theo ký tự (`runes`), không theo đơn vị UTF-16.
- **Không lưu mật khẩu nguyên văn.** `Pbkdf2PasswordHasher` băm PBKDF2-HMAC-SHA256, 100.000 vòng, salt ngẫu nhiên 16 byte, chạy trong `Isolate.run`. Chuỗi lưu có dạng `pbkdf2-sha256$<vòng>$<salt>$<mã băm>`, nên tăng số vòng sau này vẫn kiểm tra được mã cũ. Mã băm chỉ nằm ở lớp data (`AccountDto`), không có trên entity.
- Widget test phải override `passwordHasherProvider` bằng bản giả. `Isolate.run` không xong được trong thời gian giả của `testWidgets`, test sẽ treo.
- Tên quốc gia tiếng Việt nằm ở `features/account/presentation/widgets/country_names_vi.dart`, sinh từ bản dịch `vi` của gói `phone_form_field` (MIT). Không sửa tay hàng loạt; nếu cần sinh lại thì đối chiếu với `IsoCode` của `phone_numbers_parser`.

## Quy tắc về bản đồ

- Mọi bản đồ dùng `PetMap` (`shared/map/pet_map.dart`), không dùng `MapLibreMap` trực tiếp. `PetMap` nhận ghim nhà (`PetMapMarker`), vùng tròn (`PetMapArea`), `interactive`, `flat`, `PetMapController` để di chuyển camera.
- Hai kiểu bản đồ (`MapKind`): **Mô hình** (nhà nổi khối 3D, camera nghiêng 55°, ánh sáng Tự động/Ngày/Đêm, tự động thì đêm từ 18 h tới 6 h) và **Thường** (2D phẳng, có tên đường). Mặc định Mô hình. Người dùng đổi bằng nút "Kiểu bản đồ" trên tab Bản đồ; lựa chọn lưu ở SharedPreferences khoá `map_preferences` (chỉ là tuỳ chọn giao diện nên `MapPreferencesNotifier` đọc ghi thẳng, không qua repository).
- Đổi kiểu hay ngày/đêm là nạp style mới; nhà và vùng là lớp GeoJSON riêng, thêm lại trong `onStyleLoadedCallback`. Lớp vùng đặt dưới lớp `building` của style.
- Ghim nhà là **ảnh** do `HouseMarkerIcon` vẽ rồi nạp vào style (`addImage`), không phải widget Flutter đè lên bản đồ (widget đè lên bị trễ khi kéo và tốn pin). Ảnh dùng chung theo (nhà của mình hay không, các loài thú cưng, màu theme); tên nhà vẽ bằng `text-field` của MapLibre.
- Màu bản đồ ăn theo theme: ghim nhà và bản đồ ban ngày (cả Mô hình lẫn Thường) nhuộm theo `primaryContainer` (`PetMapSpec.tint`), độ sáng cố định để bản đồ luôn nhạt. Nước, cây cỏ giữ màu tự nhiên; ban đêm giữ tông tím than. Không hard-code màu thương hiệu trong bản đồ.
- Không có hoạt ảnh chạy liên tục trên bản đồ (bắt bản đồ vẽ lại mọi khung hình, hao pin).
- Widget test phải override `petMapBuilderProvider` bằng bản giả và kiểm tra `PetMapSpec` (dữ liệu đưa vào bản đồ). MapLibre là view native, không dựng được trong test.
- Tile OpenFreeMap miễn phí, không cần key nhưng không cam kết thời gian hoạt động. Phải đổi trước khi phát hành (xem `memory.md`).

## Quy tắc về vị trí (quyền riêng tư)

- Lấy vị trí theo thứ tự GPS → Wi-Fi → mạng di động (`GeolocatorLocationService.attempts`, ứng với `LocationAccuracy` high → medium → low). Mỗi cách có thời gian chờ riêng, hết giờ thì thử cách kế tiếp.
- Android/iOS không tách riêng Wi-Fi với trạm di động: mức "Wi-Fi" là định vị mạng ưu tiên Wi-Fi, mức "mạng di động" là chế độ tiết kiệm pin dựa vào trạm LTE (sai số có thể tới vài km). Tắt dịch vụ vị trí thì cả ba cách đều không dùng được.
- **Người dùng không được tự tạo hay tự ghim vị trí.** Vị trí nhà chỉ lấy từ thiết bị (`LocationFix` do `LocationService` trả về). Bản đồ ở màn hình đăng ký chỉ để xem (`PetMap(interactive: false)`: tắt mọi cử chỉ, bọc `IgnorePointer`, không có `onMarkerTap`). Có test trong `test/app_test.dart` kiểm tra bản đồ đăng ký không nhận chạm và kéo không đổi vị trí.
- **Không nhận vị trí giả lập** (`Position.isMocked`: app fake GPS / test provider trên Android, giả lập bằng phần mềm trên iOS 15+). `GeolocatorLocationService` ném `LocationFailure` ngay, không thử cách khác. GPS giả lập của emulator (Extended Controls → Location) không bị coi là giả, nên vẫn dùng để phát triển được. Còn vị trí bơm qua `adb shell cmd location providers ...` thì bị chặn.
- Kiểm tra này chạy trên máy nên máy đã root vẫn có thể lách. Khi có backend, cần kiểm tra thêm ở server.
- `accuracyMeters` là null khi hệ điều hành không đo được sai số (`Position.hasAccuracy == false`). Không coi 0 là "rất chính xác".
- Màn hình đăng ký hiện nguồn và sai số. Sai số từ 150 m trở lên thì nhắc người dùng bật Wi-Fi hoặc ra chỗ thoáng rồi bấm "Lấy lại vị trí". Lỗi định vị hiện ngay trên nút "Lấy vị trí", không để cuối form.
- Mỗi ngôi nhà có `realLocation` (vị trí thật) và `displayLocation` (vị trí lệch ngẫu nhiên 50–200 m).
- `displayLocation` chỉ tạo **một lần** trong use case `RegisterHouse`, rồi lưu lại. Không bao giờ random lại lúc hiển thị, vì người xem lấy trung bình nhiều lần sẽ ra vị trí thật.
- Bản đồ công khai và mọi thứ người khác thấy chỉ được dùng `displayLocation`. `realLocation` chỉ dành cho chủ nhà.
- Bản đồ công khai vẽ mỗi nhà kèm một vùng tròn nét đứt tâm ở `displayLocation`, bán kính `LocationFuzzer.defaultMaxMeters` (200 m, nhà thật luôn nằm trong vùng này), và giới hạn zoom tối đa 17, để ghim không bị hiểu là đúng một toà nhà.
- Có test trong `test/app_test.dart` kiểm tra ghim và vùng trên bản đồ nằm ở `displayLocation`.

## Ghi chú dự án

Các quyết định và ghi chú lâu dài nằm ở file dưới đây, được nạp kèm file này:

@memory.md
