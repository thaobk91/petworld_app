# Ghi chú dự án

Nơi ghi lại quyết định, bối cảnh và những điều cần nhớ mà code không tự nói lên được.
Mỗi mục một dòng, ghi kèm ngày (YYYY-MM-DD). Xóa hoặc sửa mục nào đã lỗi thời.

## Quyết định

- 2026-11-02: Tạo thư mục `.claude` cùng `CLAUDE.md` và `memory.md`.
- 2026-11-02: Cấu trúc `lib/` chia theo tính năng (feature-first), mỗi tính năng có 3 layer: `presentation` / `domain` / `data`.
- 2026-11-02: Quản lý state dùng Riverpod, kiêm luôn dependency injection.
- 2026-11-02: Chỉ làm Android và iOS. Org là `com.petworld` (Android: `com.petworld.petworld_app`). Chọn tạm, đổi được trước khi phát hành.
- 2026-11-02: Tạm lưu dữ liệu bằng `shared_preferences` cho tới khi có backend.
- 2026-11-03: Chốt làm ý tưởng "ngôi nhà thú cưng trên bản đồ". Mục đích: khoe thú cưng, trò chuyện với người xung quanh, chia sẻ kiến thức chăm sóc thú cưng, tìm thú cưng đi lạc.
- 2026-11-03: Mỗi người dùng có 1 ngôi nhà (theo ý tưởng gốc). Bản đồ công khai, ai cũng xem được.
- 2026-11-03: Vị trí lệch chỉ tạo 1 lần lúc đăng ký. Lưu cả vị trí thật lẫn vị trí lệch. Khoảng lệch 50–200 m (mức tối thiểu 50 m do Claude đề xuất, sửa trong `LocationFuzzer`).
- 2026-11-03: Bản đồ làm đơn giản trước (`flutter_map` + tile OSM), sau này có thể nâng cấp lên bản đồ mô phỏng (vd MapLibre với style riêng).
- 2026-11-03: Không có GPS thì lấy vị trí từ Wi-Fi, không có Wi-Fi thì từ mạng di động (LTE), theo yêu cầu của anh. Thời gian chờ: GPS 12 s, Wi-Fi 8 s, di động 8 s.
- 2026-11-03: Không cho người dùng tự tạo vị trí hay tự ghim vị trí trên bản đồ. Vị trí nhà chỉ lấy từ thiết bị. Anh cũng không muốn có nút "Chọn trên bản đồ" khi định vị thất bại.
- 2026-11-03: Chặn vị trí giả lập (fake GPS) khi đăng ký nhà.
- 2026-11-03: Bản đầu lưu trên máy, Supabase làm sau. Lúc nối Supabase: vị trí thật (`real_lat`, `real_lng`) chỉ chủ nhà được đọc, có thể tách sang bảng riêng có RLS.
- 2026-11-03: Thêm màn hình đăng ký tài khoản, đứng trước màn hình đăng ký nhà. Anh yêu cầu: số điện thoại có chọn quốc gia; mật khẩu + nhập lại mật khẩu; mật khẩu phải có chữ, số và ít nhất 1 ký tự đặc biệt. Claude thêm: tối thiểu 8, tối đa 64 ký tự; chỉ nhận số di động (để sau gửi OTP); mặc định Việt Nam; mật khẩu băm PBKDF2 trước khi lưu.

## Bối cảnh

- 2026-11-02: Máy dev chạy Windows. Flutter 3.47.9 cài ở `C:\develop\flutter` từ file zip chính thức (đã đối chiếu SHA-256), đã có trong PATH của user.
- 2026-11-02: Đã cài Android Studio. Android SDK ở `%LOCALAPPDATA%\Android\sdk` (platform android-37, build-tools 36). Flutter dùng JDK kèm Android Studio, không dùng Java 8 có sẵn trong PATH. Lệnh `sdkmanager` đã bị thay bằng Android CLI (`android sdk`), và bước `flutter doctor --android-licenses` không còn cần nữa.
- 2026-11-02: Build Android cần NDK `28.2.13676358` (đây là `flutter.ndkVersion` của Flutter 3.47.9). Gradle tự cài NDK thì bị lỗi `Package ndk not found`, phải cài tay: Android Studio → SDK Manager → SDK Tools → NDK (Side by side).
- 2026-11-02: Project ở ổ D: còn pub cache ở ổ C:, nên incremental compile của Kotlin lỗi `different roots` khi build plugin Android. Đã tắt bằng `kotlin.incremental=false` trong `android/gradle.properties`. Nếu sau này dời project sang ổ C: (hoặc đặt `PUB_CACHE` ở ổ D:) thì có thể bỏ dòng đó.

- 2026-11-03: Trên mạng của máy dev, `tile.openstreetmap.org` bị chặn hẳn (connection reset, cả từ PC lẫn emulator), còn CARTO basemaps giờ đòi API key (tile hiện chữ "API KEY REQUIRED"). Đang dùng `a.tile.openstreetmap.fr/hot`.
- 2026-11-03: Làm lại giao diện theo hướng ấm áp, dễ thương sau khi anh chê xấu. Quy ước nằm trong CLAUDE.md, mục "Quy ước giao diện".
- 2026-11-03: Chọn thư viện cho ô số điện thoại. `country_picker` không có tên nước tiếng Việt. `phone_form_field` 12 có tiếng Việt nhưng dùng `material_ui` (bản Material tách khỏi SDK), lớp `Theme` khác với `package:flutter/material.dart` nên không ăn theme của app. Vì vậy app dùng `phone_numbers_parser` + ô chọn quốc gia tự làm, tên nước tiếng Việt lấy từ bản dịch của `phone_form_field` (MIT).
- 2026-11-03: Đo trên PC: PBKDF2 100.000 vòng mất khoảng 0,3 s (Dart VM). Trên điện thoại có thể tới khoảng 1 s, nên chạy ở isolate riêng và nút "Tạo tài khoản" hiện vòng xoay trong lúc chờ.

## Việc cần làm sau

- Build/chạy iOS cần máy Mac có Xcode.
- Trước khi phát hành: chọn nhà cung cấp tile có hợp đồng (vd MapTiler, Stadia) hoặc tự host. Tile OSM France đang dùng chỉ để phát triển (xem `shared/widgets/map_layers.dart`).
- Cân nhắc thêm font tròn, thân thiện, hỗ trợ tiếng Việt tốt (vd Nunito, Be Vietnam Pro), đóng gói font vào app thay vì tải lúc chạy.
- Nối Supabase: đăng nhập, bảng houses / pets / pet_photos, bucket lưu ảnh, RLS bảo vệ vị trí thật. Thêm kiểm tra chống giả vị trí ở server (vd Play Integrity / App Attest), vì kiểm tra `isMocked` trên máy bị máy root lách được.
- Tính năng sau: video thú cưng, trò chuyện với người xung quanh, chia sẻ kiến thức chăm sóc, tìm thú cưng đi lạc.
- Bắt buộc trước khi lên store: báo cáo nội dung, chặn người dùng, xoá tài khoản trong app.
- Còn thiếu: sửa/xoá thú cưng và ảnh, đổi tên nhà.
- Tài khoản: chưa xác minh số điện thoại (OTP), chưa có đăng nhập, quên mật khẩu, đổi mật khẩu. Khi nối Supabase Auth: đăng ký bằng phone + password rồi xác minh OTP qua SMS (cần nhà cung cấp SMS, vd Twilio). Khi đó bỏ mã băm lưu trên máy, vì Supabase tự băm (bcrypt chỉ lấy 72 byte đầu, mật khẩu tối đa 64 ký tự có dấu vẫn có thể vượt 72 byte, cần kiểm tra lại). Gắn ngôi nhà với tài khoản (`owner_id`).
