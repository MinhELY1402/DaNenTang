# BÁO CÁO BÀI TẬP GIỮA KỲ
## MÔN HỌC: PHÁT TRIỂN ỨNG DỤNG ĐA NỀN TẢNG
### ĐỀ TÀI: XÂY DỰNG ỨNG DỤNG QUẢN LÝ SẢN PHẨM PHÂN HỆ ADMIN KẾT NỐI FIREBASE REALTIME ĐA NỀN TẢNG (WEB & MOBILE)

---

### THÔNG TIN CHUNG
- **Họ và tên sinh viên:** [Điền Họ và Tên]
- **Mã số sinh viên (MSSV):** [Điền MSSV]
- **Lớp học phần:** [Điền Lớp]
- **Giảng viên hướng dẫn:** [Điền Tên Giảng Viên]
- **Cơ sở dữ liệu:** **Firebase Cloud Firestore (Bản Free Spark Plan)**
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

### 2.1. Các bước khởi tạo Firebase Project miễn phí
1. Truy cập vào [https://console.firebase.google.com](https://console.firebase.google.com) và đăng nhập tài khoản Google.
2. Bấm **"Add project"** (Thêm dự án), đặt tên dự án ví dụ: `admin-product-manager` (chọn gói mặc định **Spark - Miễn phí 100%**).
3. Tại menu bên trái, chọn **Build** -> **Firestore Database** -> Bấm **"Create database"**.
4. Chọn vị trí máy chủ (ví dụ: `asia-southeast1` - Singapore hoặc `us-central`).
5. Tạo một Collection có tên là: `products`.

### 2.2. Cấu hình Firebase Security Rules (Cho phép đọc/ghi bài tập giữa kỳ)
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
*Bấm "Publish" để lưu luật bảo mật.*

### 2.3. Cấu hình trong Flutter (`lib/firebase_options.dart`)
Thêm Firebase Web App và Android App trong Firebase Console, sau đó lấy thông số cấu hình điền vào file `lib/firebase_options.dart`.

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
    (Chrome - Realtime Grid)                      (Card View & Chi tiết)
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

## PHẦN 5: HÌNH ẢNH MINH HỌA KẾT QUẢ THỰC HIỆN

### 5.1. Ảnh chụp Cơ sở dữ liệu Firebase Cloud Firestore
> *(Chụp màn hình Firebase Console tại collection `products` thể hiện rõ ràng các document CHỈ CÓ ĐÚNG 4 TRƯỜNG: `name`, `price`, `soluong`, `image`)*

```
+--------------------------------------------------------------------------+
|                                                                          |
|          [DÁN ẢNH CHỤP MÀN HÌNH FIREBASE CONSOLE TẠI ĐÂY]                |
|       (Thể hiện rõ ràng 4 trường: name, price, soluong, image)           |
|                                                                          |
+--------------------------------------------------------------------------+
```

### 5.2. Ảnh chụp Giao diện Đăng nhập Admin
```
+--------------------------------------------------------------------------+
|                                                                          |
|               [DÁN ẢNH MÀN HÌNH ĐĂNG NHẬP ADMIN TẠI ĐÂY]                 |
|                                                                          |
+--------------------------------------------------------------------------+
```

### 5.3. Ảnh chụp Giao diện Web Admin Dashboard (8.0 điểm + 1.5 điểm)
> *(Chụp ảnh Chrome: danh sách sản phẩm thời gian thực, huy hiệu "Firebase Realtime Active", thanh thống kê kho)*

```
+--------------------------------------------------------------------------+
|                                                                          |
|            [DÁN ẢNH GIAO DIỆN CHẠY TRÊN WEB CHROME TẠI ĐÂY]              |
|                                                                          |
+--------------------------------------------------------------------------+
```

### 5.4. Ảnh chụp Form Thêm mới / Chỉnh sửa trực tiếp lên Firebase
```
+--------------------------------------------------------------------------+
|                                                                          |
|              [DÁN ẢNH FORM THÊM / SỬA SẢN PHẨM TẠI ĐÂY]                  |
|                                                                          |
+--------------------------------------------------------------------------+
```

### 5.5. Ảnh chụp Hộp thoại Xuất CSDL JSON từ Firebase nộp bài
```
+--------------------------------------------------------------------------+
|                                                                          |
|         [DÁN ẢNH HỘP THOẠI XUẤT FILE JSON TỪ FIREBASE TẠI ĐÂY]           |
|                                                                          |
+--------------------------------------------------------------------------+
```

### 5.6. Ảnh chụp Giao diện trên nền tảng Mobile (0.5 điểm)
> *(Chụp ảnh chạy trên thiết bị di động / giả lập Android: chọn ảnh và xem chi tiết đồng bộ với Web)*

```
+--------------------------------------------------------------------------+
|                                                                          |
|           [DÁN ẢNH CHẠY TRÊN THIẾT BỊ DI ĐỘNG (MOBILE) TẠI ĐÂY]          |
|                                                                          |
+--------------------------------------------------------------------------+
```

---

## PHẦN 6: ĐÁNH GIÁ KẾT QUẢ VÀ TỰ CHẤM ĐIỂM

| STT | Yêu cầu đề bài | Điểm tối đa | Kết quả đạt được | Tự chấm |
|---|---|:---:|---|:---:|
| 1 | Thêm, hiển thị `name`, `price`, `soluong`, `image` chạy trên nền tảng Web qua Firebase | 8.0 | Hoàn thành 100%: Dữ liệu lưu và đồng bộ thời gian thực với Firebase Cloud Firestore, hiển thị đầy đủ 4 trường trên Chrome | 8.0 / 8.0 |
| 2 | Đăng nhập Admin, Sửa, Xóa, các tính năng nâng cao (Tìm kiếm, Sắp xếp, Thống kê kho hàng) | 1.5 | Hoàn thành 100%: Đăng nhập Admin bảo mật, Sửa/Xóa trực tiếp trên Firebase, Tìm kiếm tức thì, Thống kê kho tự động | 1.5 / 1.5 |
| 3 | Nhập hình ảnh từ thiết bị và hiển thị thông tin sản phẩm trên nền tảng di động (Mobile) | 0.5 | Hoàn thành 100%: Tích hợp `image_picker` chọn ảnh từ thư viện/camera và màn hình chi tiết Responsive tối ưu trên Mobile | 0.5 / 0.5 |
| 4 | File CSDL nộp kèm (`products.json`), xuất từ Firebase, tuân thủ chỉ gồm đúng 4 trường | Bắt buộc | Hoàn thành 100%: Nút "Xuất JSON nộp bài" tải trực tiếp từ Firebase Firestore thành file `database/products.json` chuẩn 4 trường | Đạt |
| **TỔNG CỘNG** | **10.0 / 10.0** | | | **10.0 / 10.0** |
