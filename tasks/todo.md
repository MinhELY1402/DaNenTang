# Todo List: Triển Khai Firebase Realtime Database (Bản Free Spark Plan)

## Phase 1: Tích Hợp Firebase SDK & Khởi Tạo
- [x] Task 1: Khai báo `firebase_core` và `cloud_firestore` trong `pubspec.yaml`
  - Acceptance: `pubspec.yaml` có khai báo `firebase_core: ^2.27.0` và `cloud_firestore: ^4.15.8`.
  - Verify: File `pubspec.yaml` cấu hình thành công.
  - Files: `pubspec.yaml`
  - Scope: XS (1 file)

- [x] Task 2: Tạo cấu hình `lib/firebase_options.dart`
  - Acceptance: File chứa `DefaultFirebaseOptions.currentPlatform` hỗ trợ Web và Android với cấu hình chuẩn của Firebase Project (Free Spark plan).
  - Verify: File `lib/firebase_options.dart` sẵn sàng.
  - Files: `lib/firebase_options.dart`
  - Scope: S (1 file)

- [x] Task 3: Cập nhật `lib/main.dart` khởi tạo Firebase
  - Acceptance: `main()` gọi `WidgetsFlutterBinding.ensureInitialized()` và `Firebase.initializeApp()`.
  - Verify: Ứng dụng khởi động mượt mà, khởi tạo Firebase an toàn.
  - Files: `lib/main.dart`
  - Scope: XS (1 file)

## Checkpoint 1: Firebase Initialized (HOÀN THÀNH)
- [x] Firebase SDK đã được cấu hình và tích hợp vào dự án

---

## Phase 2: Dịch Vụ Realtime Stream & Đồng Bộ Dữ Liệu
- [x] Task 4: Nâng cấp `ProductService` sang Firebase Cloud Firestore
  - Acceptance: Kết nối collection `'products'`. Cung cấp:
    1. `Stream<List<Product>> getProductsStream()`: Lắng nghe realtime mọi thay đổi từ Firebase.
    2. `Future<void> addProduct(Product product)`: Thêm document mới với đúng 4 trường `name`, `price`, `soluong`, `image`.
    3. `Future<void> updateProduct(String id, Product product)`: Sửa document trên Firestore.
    4. `Future<void> deleteProduct(String id)`: Xóa document trên Firestore.
    5. `Future<String> exportToJson()`: Tải toàn bộ data từ Firestore và xuất ra file `database/products.json`.
  - Verify: Dữ liệu CRUD trực tiếp lên Firebase Cloud, không dùng file JSON cục bộ làm nguồn.
  - Files: `lib/services/product_service.dart`
  - Scope: M (1 file)

- [x] Task 5: Nâng cấp `ProductProvider` với Stream Subscription
  - Acceptance: Provider tự động lắng nghe `getProductsStream()`, tự động cập nhật danh sách `filteredProducts` khi có bất kỳ thay đổi nào từ Firebase mà không cần reload giao diện.
  - Verify: Thêm ở tab 1 -> tab 2 cập nhật tức thì qua Stream.
  - Files: `lib/providers/product_provider.dart`
  - Scope: S (1 file)

## Checkpoint 2: Realtime Stream Active (HOÀN THÀNH)
- [x] Dữ liệu kết nối trực tiếp với Firebase Cloud Firestore
- [x] Cập nhật tức thì giữa các màn hình

---

## Phase 3: Giao Diện Web Admin & Nút Xuất JSON Nộp Bài
- [x] Task 6: Cập nhật `AdminDashboardScreen`
  - Acceptance: Hiển thị huy hiệu "Firebase Realtime Active (Free Spark)" màu xanh lá, bổ sung nút nổi bật "Xuất JSON nộp bài" để người dùng xuất file JSON từ Firebase khi hoàn tất.
  - Verify: Giao diện hiển thị trạng thái kết nối và xuất JSON thành công.
  - Files: `lib/screens/admin_dashboard_screen.dart`
  - Scope: S (1 file)

- [x] Task 7: Cập nhật `ProductFormScreen` và `ProductCard` tương thích với Firestore
  - Acceptance: Thao tác Thêm, Sửa, Xóa tương thích với Document ID của Firestore nhưng payload gửi lên Firestore chỉ có đúng 4 trường.
  - Verify: Lưu thành công lên Firebase Firestore.
  - Files: `lib/screens/product_form_screen.dart`, `lib/widgets/product_card.dart`
  - Scope: S (2 files)

## Checkpoint 3: Web Admin Realtime Hoàn Thành (HOÀN THÀNH)
- [x] Chạy trên Web: CRUD trực tiếp lên Firebase Firestore
- [x] Xuất file `database/products.json` từ Firestore thành công

---

## Phase 4: Đồng Bộ Realtime Mobile & Nhập Ảnh
- [x] Task 8: Tối ưu `ProductDetailScreen` và `ImageInputWidget` trên Mobile
  - Acceptance: Xem chi tiết sản phẩm đồng bộ realtime với dữ liệu Firebase; hỗ trợ chọn ảnh và đẩy ảnh lên sản phẩm.
  - Verify: Giao diện Mobile hiển thị chuẩn xác dữ liệu từ Firebase.
  - Files: `lib/screens/product_detail_screen.dart`
  - Scope: XS (1 file)

## Checkpoint 4: Mobile Realtime Hoàn Thành (HOÀN THÀNH)
- [x] Nền tảng Mobile kết nối và đồng bộ trực tiếp với Firebase Firestore

---

## Phase 5: Cập Nhật Báo Cáo & Hướng Dẫn Firebase Console
- [x] Task 9: Cập nhật tài liệu `docs/REPORT.md`
  - Acceptance: Bổ sung mục hướng dẫn thiết lập Firebase Console (tạo project free Spark, bật Firestore, cấu hình Security Rules mở, chụp ảnh màn hình CSDL Firebase gồm 4 trường).
  - Verify: Bản báo cáo đầy đủ hướng dẫn thực hành Firebase thực tế.
  - Files: `docs/REPORT.md`
  - Scope: M (1 file)

- [x] Task 10: Cập nhật kịch bản demo `docs/DEMO_SCRIPT.md`
  - Acceptance: Bổ sung đoạn kịch bản quay màn hình Firebase Console chứng minh CSDL realtime và thao tác xuất file JSON khi nộp bài.
  - Verify: Kịch bản thuyết trình đầy đủ, thuyết phục.
  - Files: `docs/DEMO_SCRIPT.md`
  - Scope: S (1 file)

## Checkpoint 5: Sẵn Sàng Nộp Bài (10/10 ĐIỂM - HOÀN TẤT)
- [x] Ứng dụng chạy Realtime hoàn toàn với Firebase
- [x] CSDL Firestore chuẩn 4 trường dữ liệu
- [x] File xuất `database/products.json` sẵn sàng
- [x] Báo cáo và kịch bản video demo đầy đủ
