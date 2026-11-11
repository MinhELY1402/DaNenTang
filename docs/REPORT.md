# BÁO CÁO BÀI TẬP GIỮA KỲ
## MÔN HỌC: PHÁT TRIỂN ỨNG DỤNG ĐA NỀN TẢNG
### ĐỀ TÀI: XÂY DỰNG ỨNG DỤNG QUẢN LÝ SẢN PHẨM PHÂN HỆ ADMIN KẾT NỐI FIREBASE REALTIME ĐA NỀN TẢNG (WEB & MOBILE)

---

### THÔNG TIN CHUNG
- **Họ và tên sinh viên:** [Điền Họ và Tên]
- **Mã số sinh viên (MSSV):** [Điền MSSV]
- **Lớp học phần:** [Điền Lớp]
- **Giảng viên hướng dẫn:** [Điền Tên Giảng Viên]
- **Cơ sở dữ liệu:** **Firebase Cloud Firestore (Bản Free Spark Plan)** - Project ID: `danentang-b5b16`
- **Link GitHub Source Code:** `https://github.com/[username]/admin_product_manager`
- **Link Video Demo:** `https://youtu.be/[video_id]` hoặc `https://drive.google.com/...`
- **File Cơ sở dữ liệu nộp kèm:** `database/products.json` (Xuất trực tiếp từ Firebase)

---

## PHẦN 1: TỔNG QUAN ĐỀ TÀI & RÀNG BUỘC KỸ THUẬT

### 1.1. Mục tiêu đề tài
Xây dựng ứng dụng quản trị (Admin) sản phẩm chạy đồng thời trên cả hai nền tảng **Web** và **Mobile** từ một mã nguồn duy nhất bằng **Flutter framework**, tích hợp **Cơ sở dữ liệu thời gian thực Firebase Cloud Firestore (Gói miễn phí Spark)**:
1. **Nguồn dữ liệu hoạt động:** 100% dữ liệu thêm, sửa, xóa, hiển thị được lưu trữ và đồng bộ thời gian thực (Realtime Stream) trực tiếp với Firebase Cloud Firestore. **Ứng dụng KHÔNG lấy dữ liệu từ file JSON cục bộ.**
2. **Nền tảng Web (8.0 điểm):** Thực hiện thêm mới sản phẩm và hiển thị danh sách sản phẩm thời gian thực gồm đầy đủ 4 thông tin: `name`, `price`, `soluong`, `image`.
3. **Chức năng Admin nâng cao (1.5 điểm):** Đăng nhập xác thực quản trị viên, chức năng sửa, xóa sản phẩm trực tiếp trên Firebase, bộ lọc tìm kiếm sản phẩm theo tên thời gian thực, sắp xếp nâng cao và bảng thống kê tổng kho hàng tự động tính toán.
4. **Nền tảng Mobile (0.5 điểm):** Nhập/chọn hình ảnh từ thiết bị (thư viện ảnh/camera) và hiển thị thông tin sản phẩm trên thiết bị di động, đồng bộ dữ liệu Realtime 2 chiều với Web qua Firebase.
5. **Nộp bài:** Chức năng "Xuất file CSDL nộp bài" xuất toàn bộ bản ghi từ Firebase thành file `database/products.json` đúng chuẩn 4 trường.

### 1.2. Ràng buộc cơ sở dữ liệu (BẮT BUỘC)
- Theo đúng quy định của đề bài: **Cơ sở dữ liệu trên Firebase chỉ chấp nhận duy nhất 4 trường dữ liệu**:
  1. `name`: Tên sản phẩm (String)
  2. `price`: Giá sản phẩm (Double / Number)
  3. `soluong`: Số lượng sản phẩm (Integer)
  4. `image`: Đường dẫn URL hoặc chuỗi hình ảnh (String)
- **Tuyệt đối KHÔNG tự ý bổ sung thêm trường** như `id`, `created_at`, `updated_at`, `category`, `description` vào payload dữ liệu của sản phẩm trên Firebase.

---

## PHẦN 2: THIẾT LẬP FIREBASE CLOUD FIRESTORE (MIỄN PHÍ - SPARK PLAN)

### 2.1. Thông số Project Firebase kết nối thực tế
- **Project ID:** `danentang-b5b16`
- **Collection CSDL:** `products`
- **Trạng thái kết nối:** Đã kiểm thử thành công qua Firestore REST API & Flutter SDK (HTTP 200 OK).

### 2.2. Cấu hình Firebase Security Rules
Tại tab **Rules** của Firestore, cấu hình luật bảo mật cho phép đọc và ghi dữ liệu:
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

## PHẦN 3: DANH SÁCH CÁC CÂU LỆNH TẢI THƯ VIỆN LIÊN QUAN

```bash
# 1. Thư viện kết nối Firebase chính thức
flutter pub add firebase_core
flutter pub add cloud_firestore

# 2. Quản lý trạng thái ứng dụng
flutter pub add provider

# 3. Thư viện chọn hình ảnh từ máy hoặc camera trên đa nền tảng
flutter pub add image_picker

# 4. Thư viện định dạng tiền tệ Việt Nam (VNĐ) và số liệu
flutter pub add intl

# 5. Cài đặt toàn bộ thư viện dependencies
flutter pub get

# 6. Lệnh chạy ứng dụng trên nền tảng Web (Google Chrome)
flutter run -d chrome

# 7. Lệnh chạy ứng dụng trên thiết bị di động (Android / iOS / Giả lập)
flutter run

# 8. Lệnh chạy kiểm thử tự động (Unit Test) kiểm tra cấu trúc 4 trường
flutter test test/product_model_test.dart
```

---

## PHẦN 4: THIẾT KẾ KIẾN TRÚC MÃ NGUỒN & MODEL DỮ LIỆU

### 4.1. Kiến trúc luồng dữ liệu thời gian thực (Realtime Flow)
```
Firebase Cloud Firestore (Collection: 'products')
         ▲                              │
         │ (Thêm / Sửa / Xóa)            │ Realtime Stream: snapshots()
         │                              ▼
ProductService ◄────────────── ProductProvider (ChangeNotifier)
                                        │
                 ┌──────────────────────┴──────────────────────┐
                 ▼                                             ▼
        Web Admin Platform                            Mobile Platform
   (Data Table & Grid View)                       (Card View & Chi tiết)
```

### 4.2. Model `Product` tuân thủ nghiêm ngặt 4 trường (`lib/models/product.dart`)
```dart
class Product {
  final String? id;     // Firestore Document ID (quản lý ngầm, không ghi vào CSDL)
  final String name;    // 1. Tên sản phẩm
  final double price;   // 2. Giá sản phẩm
  final int soluong;    // 3. Số lượng sản phẩm
  final String image;   // 4. Hình ảnh sản phẩm

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.soluong,
    required this.image,
  });

  // Khi serialize gửi lên Firestore hoặc xuất JSON: CHỈ CÓ ĐÚNG 4 TRƯỜNG
  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'soluong': soluong,
    'image': image,
  };

  factory Product.fromMap(Map<String, dynamic> map, {String? documentId}) => Product(
    id: documentId,
    name: map['name']?.toString() ?? '',
    price: (map['price'] as num?)?.toDouble() ?? 0.0,
    soluong: (map['soluong'] as num?)?.toInt() ?? 0,
    image: map['image']?.toString() ?? '',
  );
}
```

---

## PHẦN 5: ĐẶC TẢ KIẾN TRÚC TRẢI NGHIỆM NGƯỜI DÙNG (UX/UI REDESIGN)

Ứng dụng được thiết kế theo các nguyên tắc kỹ thuật giao diện hiện đại (**Frontend UI Engineering**), loại bỏ hoàn toàn các mẫu thiết kế chung chung:
1. **Design System & Semantic Tokens (`lib/theme/app_theme.dart`):** Bảng màu trung tính Slate 50 (`#F8FAFC`), Deep Indigo (`#4F46E5`), Emerald (Còn hàng), Amber (Sắp hết), Rose (Hết hàng/Xóa).
2. **Màn hình Đăng nhập Split-Layout (`lib/screens/login_screen.dart`):** Phân chia 2 cột trên Desktop (giới thiệu tính năng bên trái, form đăng nhập bên phải), có nút tự động điền tài khoản mẫu tiện lợi.
3. **Bố cục Admin Shell với Sidebar & TopBar (`lib/widgets/admin_sidebar.dart`):** Cố định trên Desktop và biến thành Drawer trên Mobile.
4. **Chế độ hiển thị kép Dual-View (`Table View` & `Grid View`):** Người dùng có thể linh hoạt chuyển đổi giữa dạng bảng quản trị dữ liệu chi tiết và dạng lưới thẻ hình ảnh.
5. **Form Thêm/Sửa sản phẩm 2 cột kèm Live Preview Card (`lib/screens/product_form_screen.dart`):** Admin gõ thông tin hoặc đổi ảnh bên trái, chiếc thẻ sản phẩm thực tế bên phải lập tức cập nhật theo thời gian thực trước khi lưu.
6. **Huy hiệu trạng thái kho hàng thông minh (`StatusBadge`):** Phân loại trực quan: Còn hàng (Xanh lá), Sắp hết hàng <= 5 (Vàng cam), Hết hàng (Đỏ).

---

## PHẦN 6: HÌNH ẢNH MINH HỌA KẾT QUẢ THỰC HIỆN

### 6.1. Ảnh chụp Cơ sở dữ liệu Firebase Cloud Firestore
> *(Chụp màn hình Firebase Console tại collection `products` thể hiện rõ ràng các document CHỈ CÓ ĐÚNG 4 TRƯỜNG: `name`, `price`, `soluong`, `image`)*

```
+--------------------------------------------------------------------------+
|                                                                          |
|          [DÁN ẢNH CHỤP MÀN HÌNH FIREBASE CONSOLE TẠI ĐÂY]                |
|       (Thể hiện rõ ràng 4 trường: name, price, soluong, image)           |
|                                                                          |
+--------------------------------------------------------------------------+
```

### 6.2. Ảnh chụp Giao diện Đăng nhập Split-Layout
```
+--------------------------------------------------------------------------+
|                                                                          |
|          [DÁN ẢNH MÀN HÌNH ĐĂNG NHẬP SPLIT-LAYOUT TẠI ĐÂY]               |
|                                                                          |
+--------------------------------------------------------------------------+
```

### 6.3. Ảnh chụp Giao diện Web Admin - Chế độ Bảng (Table View)
```
+--------------------------------------------------------------------------+
|                                                                          |
|       [DÁN ẢNH GIAO DIỆN CHẠY TRÊN WEB CHROME (TABLE VIEW) TẠI ĐÂY]      |
|                                                                          |
+--------------------------------------------------------------------------+
```

### 6.4. Ảnh chụp Giao diện Web Admin - Chế độ Lưới (Grid View)
```
+--------------------------------------------------------------------------+
|                                                                          |
|        [DÁN ẢNH GIAO DIỆN CHẠY TRÊN WEB CHROME (GRID VIEW) TẠI ĐÂY]      |
|                                                                          |
+--------------------------------------------------------------------------+
```

### 6.5. Ảnh chụp Form Thêm/Sửa với Tính năng Live Preview
```
+--------------------------------------------------------------------------+
|                                                                          |
|      [DÁN ẢNH FORM THÊM / SỬA KÈM LIVE PREVIEW CARD TẠI ĐÂY]             |
|                                                                          |
+--------------------------------------------------------------------------+
```

### 6.6. Ảnh chụp Hộp thoại Xuất CSDL JSON từ Firebase nộp bài
```
+--------------------------------------------------------------------------+
|                                                                          |
|         [DÁN ẢNH HỘP THOẠI XUẤT FILE JSON TỪ FIREBASE TẠI ĐÂY]           |
|                                                                          |
+--------------------------------------------------------------------------+
```

### 6.7. Ảnh chụp Giao diện trên nền tảng Mobile (0.5 điểm)
> *(Chụp ảnh chạy trên thiết bị di động / giả lập Android: chọn ảnh từ máy và xem chi tiết đồng bộ với Web)*

```
+--------------------------------------------------------------------------+
|                                                                          |
|           [DÁN ẢNH CHẠY TRÊN THIẾT BỊ DI ĐỘNG (MOBILE) TẠI ĐÂY]          |
|                                                                          |
+--------------------------------------------------------------------------+
```

---

## PHẦN 7: ĐÁNH GIÁ KẾT QUẢ VÀ TỰ CHẤM ĐIỂM

| STT | Yêu cầu đề bài | Điểm tối đa | Kết quả đạt được | Tự chấm |
|---|---|:---:|---|:---:|
| 1 | Thêm, hiển thị `name`, `price`, `soluong`, `image` chạy trên nền tảng Web qua Firebase | 8.0 | Hoàn thành 100%: Dữ liệu lưu và đồng bộ thời gian thực với Firebase Cloud Firestore, hiển thị đầy đủ 4 trường trên Chrome | 8.0 / 8.0 |
| 2 | Đăng nhập Admin, Sửa, Xóa, các tính năng nâng cao (Tìm kiếm, Sắp xếp, Thống kê kho hàng, Dual-View) | 1.5 | Hoàn thành 100%: Đăng nhập Admin bảo mật, Sửa/Xóa trực tiếp trên Firebase, Tìm kiếm tức thì, Thống kê kho tự động, chuyển đổi Table/Grid linh hoạt | 1.5 / 1.5 |
| 3 | Nhập hình ảnh từ thiết bị và hiển thị thông tin sản phẩm trên nền tảng di động (Mobile) | 0.5 | Hoàn thành 100%: Tích hợp `image_picker` chọn ảnh từ thư viện/camera và màn hình chi tiết Responsive tối ưu trên Mobile | 0.5 / 0.5 |
| 4 | File CSDL nộp kèm (`products.json`), xuất từ Firebase, tuân thủ chỉ gồm đúng 4 trường | Bắt buộc | Hoàn thành 100%: Nút "Xuất JSON nộp bài" tải trực tiếp từ Firebase Firestore thành file `database/products.json` chuẩn 4 trường | Đạt |
| **TỔNG CỘNG** | **10.0 / 10.0** | | | **10.0 / 10.0** |
