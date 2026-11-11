# SPEC: Ứng Dụng Quản Lý Sản Phẩm Đa Nền Tảng (Admin Subsystem) - Firebase Realtime Architecture

## 1. Objective (Mục tiêu)
Xây dựng ứng dụng quản trị (Admin) sản phẩm chạy đa nền tảng (**Web** và **Mobile**) sử dụng **Firebase Cloud Firestore (Bản Free Spark Plan)** làm cơ sở dữ liệu thời gian thực (Realtime Database).
- **Nguồn dữ liệu hoạt động:** 100% dữ liệu thêm, sửa, xóa, hiển thị được lưu trữ và đồng bộ thời gian thực (Realtime Stream) trực tiếp với Firebase Cloud Firestore. **Ứng dụng KHÔNG lấy dữ liệu cố định từ file JSON.**
- **Nhiệm vụ của file JSON:** File `database/products.json` được xuất từ Firebase khi hoàn thành để phục vụ việc nộp bài theo yêu cầu đề bài.
- **Nền tảng Web (8.0 điểm):** Thực hiện thêm sản phẩm, hiển thị danh sách sản phẩm thời gian thực gồm đầy đủ 4 thông tin: `name`, `price`, `soluong`, `image`.
- **Chức năng Admin nâng cao (1.5 điểm):** Đăng nhập xác thực Admin, sửa, xóa sản phẩm, tìm kiếm, sắp xếp và thống kê kho hàng theo dữ liệu Realtime từ Firebase.
- **Nền tảng Mobile (0.5 điểm):** Nhập/chọn hình ảnh từ thiết bị di động (Camera/Gallery) và hiển thị thông tin sản phẩm, đồng bộ Realtime 2 chiều với Web qua Firebase.
- **Sản phẩm bàn giao (Deliverables):**
  - File cơ sở dữ liệu xuất ra từ Firebase: `database/products.json` (chỉ gồm 4 trường).
  - Ảnh chụp CSDL Firestore trên Firebase Console thể hiện đúng 4 trường.
  - File báo cáo chi tiết: `docs/REPORT.md`.
  - Source code trên Git/GitHub & Kịch bản video demo.

> **RÀNG BUỘC ĐẶC BIỆT (BẮT BUỘC):**
> Document trên Firebase Firestore **CHỈ chấp nhận đúng 4 trường:**
> 1. `name` (String - Tên sản phẩm)
> 2. `price` (Number / Double - Giá sản phẩm)
> 3. `soluong` (Integer - Số lượng)
> 4. `image` (String - URL hoặc chuỗi hình ảnh)
> **Tuyệt đối KHÔNG tự ý thêm trường khác** vào document sản phẩm trên Firebase.

---

## 2. Tech Stack (Công nghệ)
- **Framework:** Flutter (Dart) - 1 code base duy nhất build & chạy đồng thời cho cả Web (`flutter run -d chrome`) và Mobile (`flutter run`).
- **Cơ sở dữ liệu Realtime:** **Firebase Cloud Firestore (Gói Spark miễn phí)**:
  - Đồng bộ thời gian thực qua `snapshots()` stream.
  - Khi thêm/sửa/xóa trên Web -> Mobile cập nhật tức thì.
  - Khi thêm/sửa/xóa trên Mobile -> Web cập nhật tức thì.
- **Authentication:** Firebase Auth / Admin Auth Provider.
- **State Management:** `provider` kết hợp StreamSubscription từ Firestore.
- **Image Handling:** `image_picker` (Mobile & Web) + hỗ trợ URL hình ảnh.

---

## 3. Commands (Lệnh thực thi)
```bash
# Cài đặt thư viện dependencies (bao gồm firebase_core và cloud_firestore)
flutter pub get

# Chạy trên nền tảng Web (Google Chrome) - Đáp ứng yêu cầu 1 (8.0đ)
flutter run -d chrome

# Chạy trên nền tảng Mobile (Android Emulator / Thiết bị thật) - Đáp ứng yêu cầu 3 (0.5đ)
flutter run

# Build bản Web production
flutter build web

# Chạy kiểm thử tự động (Unit Test)
flutter test
```

---

## 4. Project Structure (Cấu trúc thư mục)
```
GiuaKy/
├── database/
│   └── products.json              # File CSDL JSON xuất từ Firebase để nộp bài
├── docs/
│   ├── REPORT.md                  # Bản báo cáo chi tiết các bước, lệnh cài, chụp ảnh Firebase
│   └── DEMO_SCRIPT.md             # Kịch bản chi tiết quay video demo nộp bài
├── lib/
│   ├── main.dart                  # Khởi tạo Firebase và App
│   ├── firebase_options.dart      # Cấu hình Firebase Web & Mobile
│   ├── models/
│   │   └── product.dart           # Model chuẩn CHỈ CÓ 4 TRƯỜNG: name, price, soluong, image
│   ├── services/
│   │   ├── auth_service.dart      # Xác thực đăng nhập Admin
│   │   └── product_service.dart   # Dịch vụ kết nối trực tiếp Firestore (Realtime Stream & CRUD)
│   ├── providers/
│   │   └── product_provider.dart  # Lắng nghe Realtime Stream từ Firebase, Search, Filter, Thống kê
│   ├── screens/
│   │   ├── login_screen.dart           # Giao diện Đăng nhập Admin
│   │   ├── admin_dashboard_screen.dart # Giao diện Web Admin Realtime (kèm nút xuất JSON nộp bài)
│   │   ├── product_form_screen.dart    # Giao diện Form Thêm / Sửa sản phẩm
│   │   └── product_detail_screen.dart  # Chi tiết sản phẩm trên Mobile
│   └── widgets/
│       ├── product_card.dart      # Widget thẻ sản phẩm
│       ├── image_input_widget.dart# Widget chọn ảnh đa nền tảng
│       └── stat_badge.dart        # Widget thống kê kho hàng Realtime
└── test/
    └── product_model_test.dart    # Unit test kiểm tra tính toàn vẹn 4 trường
```

---

## 5. Data Contract & Firebase Rules
### Cấu trúc Document trong Collection `products` trên Firestore:
```json
{
  "name": "iPhone 15 Pro Max 256GB",
  "price": 29990000,
  "soluong": 15,
  "image": "https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=600"
}
```

### Firebase Security Rules (Gói miễn phí Spark cho bài tập sinh viên):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /products/{document=**} {
      allow read, write: if true;
    }
  }
}
```

---

## 6. Success Criteria (Tiêu chí nghiệm thu)
1. **[Realtime Database]** Dữ liệu ứng dụng kết nối trực tiếp với Firebase Cloud Firestore gói miễn phí; thay đổi từ một client lập tức phản hồi trên các client khác mà không cần F5/tải lại trang.
2. **[Web 8.0đ]** Chạy trên Chrome: thêm và hiển thị sản phẩm trực tiếp từ Firestore đầy đủ 4 trường `name`, `price`, `soluong`, `image`.
3. **[Admin & Nâng cao 1.5đ]** Đăng nhập Admin, sửa, xóa, tìm kiếm, lọc và thống kê kho hàng tự động tính toán từ Firestore.
4. **[Mobile 0.5đ]** Trên giao diện di động: chọn được ảnh và hiển thị sản phẩm, đồng bộ với Web.
5. **[Nộp bài]** Tính năng "Xuất file CSDL nộp bài" xuất ra file `database/products.json` chứa dữ liệu thật từ Firebase với chuẩn đúng 4 trường.
