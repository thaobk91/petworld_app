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
- 2026-11-03: Chuyển bản đồ từ `flutter_map` (tile ảnh OSM) sang MapLibre (`maplibre_gl`) với style tự viết, theo yêu cầu "bản đồ mô hình kiểu trò chơi". Có 2 kiểu, người dùng tự đổi và app nhớ lựa chọn: Mô hình (3D, ngày/đêm) và Thường (2D, rõ tên đường, hợp khi tìm thú lạc). Mặc định Mô hình. Anh chốt MapLibre sau khi so với Mapbox (đẹp sẵn hơn nhưng tính phí theo người dùng sau ~25.000 MAU, cần token), Google Maps (không làm được kiểu trò chơi) và flutter_map (nhẹ nhất nhưng không có 3D). Cả 2 kiểu dùng chung MapLibre để chỉ phải làm phần nhà/vùng một lần.
- 2026-11-03: Không có GPS thì lấy vị trí từ Wi-Fi, không có Wi-Fi thì từ mạng di động (LTE), theo yêu cầu của anh. Thời gian chờ: GPS 12 s, Wi-Fi 8 s, di động 8 s.
- 2026-11-03: Không cho người dùng tự tạo vị trí hay tự ghim vị trí trên bản đồ. Vị trí nhà chỉ lấy từ thiết bị. Anh cũng không muốn có nút "Chọn trên bản đồ" khi định vị thất bại.
- 2026-11-03: Chặn vị trí giả lập (fake GPS) khi đăng ký nhà.
- 2026-11-03: Bản đầu lưu trên máy, Supabase làm sau. Lúc nối Supabase: vị trí thật (`real_lat`, `real_lng`) chỉ chủ nhà được đọc, có thể tách sang bảng riêng có RLS.
- 2026-11-03: Thêm màn hình đăng ký tài khoản, đứng trước màn hình đăng ký nhà. Anh yêu cầu: số điện thoại có chọn quốc gia; mật khẩu + nhập lại mật khẩu; mật khẩu phải có chữ, số và ít nhất 1 ký tự đặc biệt. Claude thêm: tối thiểu 8, tối đa 64 ký tự; chỉ nhận số di động (để sau gửi OTP); mặc định Việt Nam; mật khẩu băm PBKDF2 trước khi lưu.

- 2026-11-03: Đổi màu app từ cam san hô sang xanh lá cây `#5DBB63`, sau khi anh xem ảnh chụp 11 bảng màu. Anh muốn để sẵn cam san hô và xanh dương đậm `#2F5DA8` trong code nhưng tắt, và tắt giao diện tối: app luôn sáng, code giao diện tối vẫn giữ.
- 2026-11-03: Thêm tab thứ 3 "Cộng đồng" (thứ tự Bản đồ → Nhà của tôi → Cộng đồng), để mọi người tạo nhóm, chia sẻ bài viết. Anh chọn bản đầu chỉ gồm nhóm (tạo, tham gia, rời, đăng bài chữ trong nhóm) và vài nhóm chủ đề có sẵn, lưu trên máy. Các phần để sau: bảng tin chung, ảnh trong bài, thích và bình luận.

## Bối cảnh

- 2026-11-02: Máy dev chạy Windows. Flutter 3.47.9 cài ở `C:\develop\flutter` từ file zip chính thức (đã đối chiếu SHA-256), đã có trong PATH của user.
- 2026-11-02: Đã cài Android Studio. Android SDK ở `%LOCALAPPDATA%\Android\sdk` (platform android-37, build-tools 36). Flutter dùng JDK kèm Android Studio, không dùng Java 8 có sẵn trong PATH. Lệnh `sdkmanager` đã bị thay bằng Android CLI (`android sdk`), và bước `flutter doctor --android-licenses` không còn cần nữa.
- 2026-11-02: Build Android cần NDK `28.2.13676358` (đây là `flutter.ndkVersion` của Flutter 3.47.9). Gradle tự cài NDK thì bị lỗi `Package ndk not found`, phải cài tay: Android Studio → SDK Manager → SDK Tools → NDK (Side by side).
- 2026-11-02: Project ở ổ D: còn pub cache ở ổ C:, nên incremental compile của Kotlin lỗi `different roots` khi build plugin Android. Đã tắt bằng `kotlin.incremental=false` trong `android/gradle.properties`. Nếu sau này dời project sang ổ C: (hoặc đặt `PUB_CACHE` ở ổ D:) thì có thể bỏ dòng đó.

- 2026-11-03: Trên mạng của máy dev, `tile.openstreetmap.org` bị chặn hẳn (connection reset, cả từ PC lẫn emulator), còn CARTO basemaps giờ đòi API key. Tile vector của OpenFreeMap (`tiles.openfreemap.org`) thì tải được, nên bản đồ MapLibre dùng nguồn này.
- 2026-11-03: Ghi chú khi dùng `maplibre_gl` 0.28: đổi `styleString` thì plugin tự nạp style mới (qua options), ảnh và lớp thêm bằng controller mất theo style cũ; feature trong GeoJSON phải có `id` ở cấp feature thì Android/iOS mới báo lại khi chạm; trong `MapScreen` phải bọc `PetMap` bằng `Positioned.fill`, không thì Stack co theo bản đồ. Nút (i) ghi nguồn cần `attributionButtonMargins`, không thì lệch vào giữa vì chừa chỗ cho logo.
- 2026-11-03: Dữ liệu tòa nhà OSM ở trung tâm Hà Nội/TP.HCM khá đủ nên kiểu Mô hình đẹp; ngoại thành, nông thôn ít tòa nhà thì bản đồ phẳng hơn.
- 2026-11-03: Đo bản profile trên S20+ (mỗi trường hợp đo 1 lần, chờ 30 s sau khi mở, rồi kéo bản đồ 12 lần). RAM (PSS) lúc mở → sau khi kéo: flutter_map cũ 181 → 190 MB; MapLibre kiểu Thường 308 → 326 MB; kiểu Mô hình 294 → 337 MB. Phần tăng chủ yếu là bộ nhớ đồ hoạ (24 MB → khoảng 100 MB) và native. CPU khi bản đồ đứng yên: cả 3 gần 0. CPU cho 12 lần kéo: cũ 11,9 s; Thường 9,2 s; Mô hình 12,5 s, tức là MapLibre không tốn CPU hơn, chỉ tốn RAM hơn. App nặng thêm khoảng 12 MB trên mỗi máy (`libmaplibre.so` arm64 11 MB + dex). Bản debug đo được tới khoảng 860 MB, không dùng để đánh giá.
- 2026-11-03: Làm lại giao diện theo hướng ấm áp, dễ thương sau khi anh chê xấu. Quy ước nằm trong CLAUDE.md, mục "Quy ước giao diện".
- 2026-11-03: Cách làm ảnh xem trước bảng màu (đã dùng để chọn màu, code tạm đã gỡ):
  - Thêm file tạm chỉ chạy ở bản debug, đọc số thứ tự bảng màu từ `theme_preview.txt` trong thư mục documents của app.
  - Trên emulator, ghi file đó bằng `adb shell run-as`, khởi động lại app, rồi chụp bằng `adb exec-out screencap`. Đổi sáng/tối bằng `adb shell cmd uimode night`.
  - Chỉ làm trên emulator, không đổi cài đặt trên máy của anh. Emulator có thêm 3 bé thú cưng mẫu (Milu, Mochi, Bông).
- 2026-11-03: Các màu đã thử mà anh không chọn: hồng phấn `#F4A3C0`, xanh da trời `#7EC8F0`, xanh bạc hà `#7FD8BE`, trắng hồng, tím oải hương `#B9A6F0`, xanh lá mạ `#A6D96A` (anh chọn trước rồi đổi sang xanh lá cây), xanh dương nhạt `#B3DAF7`, kem bạc hà (`#9EE0C8`, nền `#FFFBF2`).
- 2026-11-03: Chọn thư viện cho ô số điện thoại. `country_picker` không có tên nước tiếng Việt. `phone_form_field` 12 có tiếng Việt nhưng dùng `material_ui` (bản Material tách khỏi SDK), lớp `Theme` khác với `package:flutter/material.dart` nên không ăn theme của app. Vì vậy app dùng `phone_numbers_parser` + ô chọn quốc gia tự làm, tên nước tiếng Việt lấy từ bản dịch của `phone_form_field` (MIT).
- 2026-11-03: Đo trên PC: PBKDF2 100.000 vòng mất khoảng 0,3 s (Dart VM). Trên điện thoại có thể tới khoảng 1 s, nên chạy ở isolate riêng và nút "Tạo tài khoản" hiện vòng xoay trong lúc chờ.

## Việc cần làm sau

- Build/chạy iOS cần máy Mac có Xcode. Chưa build thử iOS với MapLibre (đã nâng deployment target lên 15.5 theo yêu cầu của `maplibre_gl`).
- Trước khi phát hành: OpenFreeMap sống nhờ quyên góp, không cam kết thời gian hoạt động. Tự host file PMTiles bản đồ Việt Nam (MapLibre Android hỗ trợ `pmtiles://` từ bản 11.7) hoặc dùng nhà cung cấp có hợp đồng (vd MapTiler). Nguồn tile nằm ở `shared/map/pet_map_style.dart`.
- Bản đồ: máy yếu nên tự chuyển sang kiểu Thường (chưa làm, cần cách nhận biết máy yếu). Chưa đo pin, chưa đo trên máy tầm trung/giá rẻ. Nếu cần giảm tải: giới hạn khung hình (`setMaximumFps`), bớt góc nghiêng.
- Cân nhắc thêm font tròn, thân thiện, hỗ trợ tiếng Việt tốt (vd Nunito, Be Vietnam Pro), đóng gói font vào app thay vì tải lúc chạy.
- Nối Supabase: đăng nhập, bảng houses / pets / pet_photos, bucket lưu ảnh, RLS bảo vệ vị trí thật. Thêm kiểm tra chống giả vị trí ở server (vd Play Integrity / App Attest), vì kiểm tra `isMocked` trên máy bị máy root lách được.
- Tính năng sau: video thú cưng, trò chuyện với người xung quanh, chia sẻ kiến thức chăm sóc, tìm thú cưng đi lạc.
- Bắt buộc trước khi lên store: báo cáo nội dung, chặn người dùng, xoá tài khoản trong app. Có tab Cộng đồng (nội dung do người dùng đăng) nên phần báo cáo bài viết và kiểm duyệt càng cần.
- Cộng đồng khi nối Supabase:
  - Bảng: `groups`, `group_members`, `group_posts`.
  - RLS: chỉ thành viên được đăng bài; chỉ tác giả được xoá bài.
  - Nhóm có sẵn chuyển thành dữ liệu trên server, giữ nguyên id `builtin-...`.
  - Bài viết nên lưu id tài khoản, ngoài id ngôi nhà.
- Còn thiếu: sửa/xoá thú cưng và ảnh, đổi tên nhà.
- Tài khoản: chưa xác minh số điện thoại (OTP), chưa có đăng nhập, quên mật khẩu, đổi mật khẩu. Khi nối Supabase Auth: đăng ký bằng phone + password rồi xác minh OTP qua SMS (cần nhà cung cấp SMS, vd Twilio). Khi đó bỏ mã băm lưu trên máy, vì Supabase tự băm (bcrypt chỉ lấy 72 byte đầu, mật khẩu tối đa 64 ký tự có dấu vẫn có thể vượt 72 byte, cần kiểm tra lại). Gắn ngôi nhà với tài khoản (`owner_id`).
