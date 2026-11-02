# petworld_app

Hướng dẫn cho Claude khi làm việc trong dự án này.

## Tổng quan

- PetWorld: app mobile viết bằng Flutter. Mỗi người dùng đăng ký một ngôi nhà, trong nhà có các thú cưng với hồ sơ và ảnh riêng. Ngôi nhà hiện trên bản đồ công khai.
- Mục đích: khoe thú cưng, trò chuyện với người xung quanh, chia sẻ kiến thức chăm sóc, tìm thú cưng đi lạc. Xem `memory.md` để biết phần nào đã làm.
- Bản hiện tại lưu mọi thứ trên máy, chưa có backend. Bản đồ chỉ có nhà của chính mình.

## Công nghệ

- Flutter 3.47.9, Dart 3.13.7. Nền tảng: Android và iOS (build iOS phải có macOS + Xcode).
- State management và DI: `flutter_riverpod` 3, không dùng code generation, không dùng get_it.
- Điều hướng: `go_router`.
- Bản đồ: `flutter_map` + `latlong2`, tile OSM France style HOT, có lớp lọc màu cho dịu (`shared/widgets/map_layers.dart`).
- Vị trí: `geolocator`. Ảnh: `image_picker`, file lưu trong thư mục documents (`path_provider`).
- Lưu trữ: `shared_preferences` (dữ liệu JSON). ID tạo bằng `uuid`.
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
├── app/                   # PetWorldApp, AppGate (chưa có nhà → đăng ký), HomeShell (2 tab)
├── core/                  # dùng chung toàn app, không phụ thuộc feature (trừ router)
│   ├── error/             # Failure, ValidationFailure, LocationFailure
│   ├── location/          # GeoPoint, LocationFix, LocationService (GPS → Wi-Fi → mạng di động)
│   ├── media/             # PhotoPicker (camera/thư viện)
│   ├── router/            # app_routes.dart, app_router.dart (GoRouter)
│   ├── storage/           # sharedPreferencesProvider, PhotoStorage
│   ├── theme/
│   └── utils/             # formatDate, formatAge
├── shared/widgets/        # widget dùng ở nhiều tính năng: lớp bản đồ OSM, pickPhoto
└── features/
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
- `domain` là Dart thuần, không import Flutter, Riverpod hay thư viện lưu trữ/HTTP. Được dùng `core/location/geo_point.dart` và `core/error/`.
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

- Phong cách ấm áp, dễ thương. Màu gốc cam san hô `AppTheme.seed`, scheme `DynamicSchemeVariant.fidelity`.
- Nút chính, FAB, ghim nhà của mình: dùng `primaryContainer` / `onPrimaryContainer`. Không dùng `primary` làm nền lớn, vì với scheme này nó ra màu gỉ sắt.
- Nền đầu trang: `AppTheme.softGradient`. Không trộn cam với xanh ngọc, ở giữa sẽ ra màu nâu xám.
- Mỗi loài thú cưng có emoji và màu pastel riêng (`pet_labels.dart`). Thú cưng chưa có ảnh thì hiện emoji trên nền pastel đó.
- Widget dùng chung: `EmptyState`, `InfoPill`, `HousePin` trong `shared/widgets/`.
- Ô nhập kiểu filled bo tròn (`UnderlineInputBorder` không viền). Không dùng `OutlineInputBorder`, vì nhãn nổi sẽ rơi ra ngoài ô.
- Chữ trong `Row` phải bọc `Expanded`/`Flexible` để không tràn khi cỡ chữ hệ thống lớn. Widget test chạy ở 360×800 để bắt lỗi tràn.
- Có 2 FAB trong cùng route (2 tab của `IndexedStack`), nên FAB của bản đồ đặt `heroTag: null`.

## Quy tắc về vị trí (quyền riêng tư)

- Lấy vị trí theo thứ tự GPS → Wi-Fi → mạng di động (`GeolocatorLocationService.attempts`, ứng với `LocationAccuracy` high → medium → low). Mỗi cách có thời gian chờ riêng, hết giờ thì thử cách kế tiếp.
- Android/iOS không tách riêng Wi-Fi với trạm di động: mức "Wi-Fi" là định vị mạng ưu tiên Wi-Fi, mức "mạng di động" là chế độ tiết kiệm pin dựa vào trạm LTE (sai số có thể tới vài km). Tắt dịch vụ vị trí thì cả ba cách đều không dùng được.
- **Người dùng không được tự tạo hay tự ghim vị trí.** Vị trí nhà chỉ lấy từ thiết bị (`LocationFix` do `LocationService` trả về). Bản đồ ở màn hình đăng ký chỉ để xem (`InteractiveFlag.none`, không có `onTap`). Có test trong `test/app_test.dart` kiểm tra chạm/kéo bản đồ không đổi vị trí.
- **Không nhận vị trí giả lập** (`Position.isMocked`: app fake GPS / test provider trên Android, giả lập bằng phần mềm trên iOS 15+). `GeolocatorLocationService` ném `LocationFailure` ngay, không thử cách khác. GPS giả lập của emulator (Extended Controls → Location) không bị coi là giả, nên vẫn dùng để phát triển được. Còn vị trí bơm qua `adb shell cmd location providers ...` thì bị chặn.
- Kiểm tra này chạy trên máy nên máy đã root vẫn có thể lách. Khi có backend, cần kiểm tra thêm ở server.
- `accuracyMeters` là null khi hệ điều hành không đo được sai số (`Position.hasAccuracy == false`). Không coi 0 là "rất chính xác".
- Màn hình đăng ký hiện nguồn và sai số. Sai số từ 150 m trở lên thì nhắc người dùng bật Wi-Fi hoặc ra chỗ thoáng rồi bấm "Lấy lại vị trí". Lỗi định vị hiện ngay trên nút "Lấy vị trí", không để cuối form.
- Mỗi ngôi nhà có `realLocation` (vị trí thật) và `displayLocation` (vị trí lệch ngẫu nhiên 50–200 m).
- `displayLocation` chỉ tạo **một lần** trong use case `RegisterHouse`, rồi lưu lại. Không bao giờ random lại lúc hiển thị, vì người xem lấy trung bình nhiều lần sẽ ra vị trí thật.
- Bản đồ công khai và mọi thứ người khác thấy chỉ được dùng `displayLocation`. `realLocation` chỉ dành cho chủ nhà.
- Có test trong `test/app_test.dart` kiểm tra marker trên bản đồ nằm ở `displayLocation`.

## Ghi chú dự án

Các quyết định và ghi chú lâu dài nằm ở file dưới đây, được nạp kèm file này:

@memory.md
