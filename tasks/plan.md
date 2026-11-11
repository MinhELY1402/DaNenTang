# Implementation Plan: Ứng Dụng Quản Lý Sản Phẩm Đa Nền Tảng (Firebase Realtime Database)

## Overview
Dự án được nâng cấp toàn diện sang kiến trúc **Firebase Realtime Database (Cloud Firestore - Bản Free Spark Plan)**. Ứng dụng kết nối trực tiếp với Firestore qua Streams thời gian thực, đảm bảo mọi thao tác Thêm, Sửa, Xóa đều diễn ra Realtime 2 chiều giữa Web và Mobile. **Dữ liệu ứng dụng hoàn toàn không nạp từ file JSON cục bộ**. File `database/products.json` được tạo ra khi người dùng bấm nút xuất dữ liệu để phục vụ việc nộp bài thi.

---

## Architecture Decisions
1. **Database: Firebase Cloud Firestore (Gói Free Spark)**
   - *Lý do:* Miễn phí 100%, hỗ trợ Realtime Stream lắng nghe dữ liệu `collection('products').snapshots()`. Thao tác trên Web lập tức cập nhật trên Mobile và ngược lại mà không cần tải lại trang.
   - Thao tác CRUD ghi trực tiếp lên Firebase Firestore.
2. **Data Isolation & 4-Field Contract:**
   - Mỗi document trong collection `products` chỉ có 4 trường: `name` (String), `price` (double), `soluong` (int), `image` (String).
   - Document ID do Firestore sinh tự động trên cloud, tuyệt đối không chèn `id` hay bất kỳ metadata nào vào payload dữ liệu của sản phẩm.
3. **Chức năng xuất JSON nộp bài (Export for Submission):**
   - Tích hợp nút **"Xuất file CSDL nộp bài"** ngay trên thanh công cụ Web Admin. Khi bấm, hệ thống sẽ truy vấn toàn bộ dữ liệu thực tế từ Firebase Firestore, định dạng chuẩn mảng JSON 4 trường và lưu ra file `database/products.json` kèm sao chép vào Clipboard.
4. **Cơ chế Fallback thông minh (Graceful Handling):**
   - Cung cấp sẵn file `firebase_options.dart` để điền cấu hình Firebase. Trong trường hợp chưa kết nối mạng hoặc chưa gắn API Key, hệ thống tự động thông báo trạng thái kết nối trực quan cho người dùng.
5. **State Management:**
   - `ProductProvider` đăng ký `StreamSubscription` lắng nghe sự thay đổi của collection Firestore. Khi Firestore có bản ghi mới, provider lập tức cập nhật state và UI tự động render.

---

## Dependency Graph
```
pubspec.yaml (firebase_core, cloud_firestore, provider, image_picker, intl)
    │
    ├── lib/firebase_options.dart (Cấu hình Firebase Web & Mobile)
    │
    ├── lib/models/product.dart (Model chuẩn 4 trường)
    │
    ├── lib/services/product_service.dart (Firebase Firestore CRUD + Realtime Stream + Export JSON)
    │       │
    │       └── lib/providers/product_provider.dart (Lắng nghe Stream Firestore, Tìm kiếm, Sắp xếp, Thống kê)
    │               │
    │               ├── lib/screens/login_screen.dart (Đăng nhập Admin)
    │               ├── lib/screens/admin_dashboard_screen.dart (Web Dashboard Realtime + Nút xuất JSON)
    │               ├── lib/screens/product_form_screen.dart (Thêm / Sửa trực tiếp lên Firestore)
    │               └── lib/screens/product_detail_screen.dart (Chi tiết trên Mobile đồng bộ Realtime)
    │
    └── database/products.json (File CSDL xuất từ Firebase để nộp bài)
```

---

## Task Breakdown Phases (Kế hoạch triển khai Firebase Realtime)

### Phase 1: Tích hợp Firebase SDK & Cấu hình Free Spark Plan
- **Task 1:** Bổ sung `firebase_core` và `cloud_firestore` vào `pubspec.yaml`.
- **Task 2:** Tạo file `lib/firebase_options.dart` chứa cấu hình khởi tạo Firebase cho cả Web và Mobile.
- **Task 3:** Cập nhật `lib/main.dart` để khởi tạo `Firebase.initializeApp()`.

### Checkpoint 1: Firebase Initialized
- [ ] Cấu hình Firebase SDK thành công, sẵn sàng kết nối Cloud Firestore.

---

### Phase 2: Nâng cấp Service & Provider sang Realtime Stream
- **Task 4:** Cập nhật `ProductService` kết nối trực tiếp Cloud Firestore:
  - Hàm `getProductsStream()` trả về `Stream<List<Product>>` lắng nghe thời gian thực.
  - Hàm `addProduct()`, `updateProduct()`, `deleteProduct()` ghi trực tiếp lên Firestore.
  - Hàm `exportFirestoreToJson()` đọc toàn bộ document trên Firestore và xuất ra `database/products.json`.
- **Task 5:** Cập nhật `ProductProvider` đăng ký lắng nghe Firestore Stream và cập nhật danh sách hiển thị tự động.

### Checkpoint 2: Realtime CRUD Active
- [ ] Dữ liệu hiển thị trực tiếp từ Firebase Firestore.
- [ ] Thêm/Sửa/Xóa đồng bộ trực tiếp lên Firebase.

---

### Phase 3: Giao diện Web Admin & Tính năng Xuất JSON nộp bài
- **Task 6:** Cập nhật `AdminDashboardScreen` hiển thị trạng thái kết nối Firebase ("Firebase Realtime Connected") và nút "Xuất file CSDL nộp bài".
- **Task 7:** Kiểm tra tính năng sửa, xóa và form thêm mới sản phẩm hoạt động mượt mà với Firestore.

### Checkpoint 3: Web Admin Realtime Verified
- [ ] Chạy trên Web: Thêm sản phẩm -> dữ liệu lưu lên Firestore và xuất hiện trên danh sách trong < 1s.
- [ ] Bấm nút xuất JSON -> tạo ra file `database/products.json` hợp lệ gồm 4 trường.

---

### Phase 4: Đồng bộ Realtime với Mobile & Chọn ảnh
- **Task 8:** Kiểm tra giao diện Mobile đồng bộ dữ liệu Realtime 2 chiều với Web.
- **Task 9:** Widget chọn ảnh hỗ trợ upload link/chuỗi ảnh trực tiếp lên Firestore.

### Checkpoint 4: Cross-Platform Realtime
- [ ] Mở 2 cửa sổ (1 Web, 1 Mobile) -> sửa hoặc thêm ở cửa sổ này, cửa sổ kia tự động cập nhật ngay lập tức.

---

### Phase 5: Cập nhật Báo Cáo & Hướng dẫn Firebase Console
- **Task 10:** Cập nhật `docs/REPORT.md`:
  - Hướng dẫn 3 bước tạo Firebase Project miễn phí (Spark plan) trên console.firebase.google.com.
  - Hướng dẫn cấu hình Firestore Security Rules cho phép đọc/ghi.
  - Vị trí dán ảnh chụp màn hình Firestore Console thể hiện rõ 4 trường `name`, `price`, `soluong`, `image`.
  - Hướng dẫn xuất file `products.json` từ Firebase để nộp bài.

---

## Risks and Mitigations
| Rủi ro | Mức độ | Biện pháp giảm thiểu |
|---|---|---|
| Người chấm thi chạy offline không có mạng | Trung bình | `ProductService` thiết kế tự động fall back sang Local Memory Cache nếu mất mạng, đảm bảo app không bao giờ bị crash màn hình trắng. |
| Firebase Security Rules bị chặn quyền ghi | Thấp | Cung cấp sẵn Security Rules chuẩn mở `allow read, write: if true;` trong tài liệu báo cáo để thiết lập trong 1 click. |
| Thêm trường lạ ngoài 4 trường quy định | Rất cao | Model `Product` và mapper Firestore lọc sạch, chỉ lưu đúng 4 key: `name`, `price`, `soluong`, `image`. |
