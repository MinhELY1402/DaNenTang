# KỊCH BẢN QUAY VIDEO DEMO NỘP BÀI - FIREBASE REALTIME (10/10 ĐIỂM)

Kịch bản quay video demo (~2 đến 3 phút) được thiết kế đặc biệt nhằm làm nổi bật **Cơ sở dữ liệu thời gian thực Firebase Cloud Firestore (Gói miễn phí Spark)** và chứng minh **Dữ liệu KHÔNG PHẢI từ file JSON cục bộ**, chỉ xuất file JSON khi nộp bài.

---

## 1. CHUẨN BỊ TRƯỚC KHI QUAY
1. Mở sẵn 1 tab trình duyệt: **Firebase Console** ([https://console.firebase.google.com](https://console.firebase.google.com)) mở sẵn collection `products`.
2. Mở sẵn 1 tab trình duyệt: Chạy ứng dụng Web Admin trên Chrome (`flutter run -d chrome`).
3. Mở sẵn file `database/products.json` trong VS Code.
4. Bật phần mềm quay màn hình (OBS Studio hoặc phím tắt `Win + Alt + R`).

---

## 2. KỊCH BẢN QUAY VIDEO CHI TIẾT

### Phút 00:00 - 00:30: Chứng minh Cơ sở dữ liệu Firebase Realtime & Ràng buộc 4 trường
- **Hành động:**
  1. Chiếu màn hình **Firebase Console (Cloud Firestore)**:
  2. Lời thoại: "Xin chào thầy/cô, em tên là ..., MSSV ..., hôm nay em xin phép demo bài tập giữa kỳ. Trước tiên em xin chứng minh cơ sở dữ liệu của ứng dụng. Hệ thống kết nối trực tiếp với **Firebase Cloud Firestore gói miễn phí Spark**, toàn bộ dữ liệu là thời gian thực (Realtime), hoàn toàn KHÔNG sử dụng file JSON cục bộ để nạp vào app."
  3. Bấm vào một document trên Firebase Console để chứng minh: "Đặc biệt, theo đúng yêu cầu đề bài, mỗi document trên Firebase chỉ có đúng 4 trường dữ liệu: `name`, `price`, `soluong`, `image`, hoàn toàn không có thêm trường phụ nào."

---

### Phút 00:30 - 00:50: Phân hệ Đăng nhập Admin (Yêu cầu 2 - 1.5 điểm)
- **Hành động:**
  1. Chuyển sang màn hình Đăng nhập ứng dụng trên Chrome.
  2. Nhập tài khoản: `admin@gmail.com` / Mật khẩu: `admin123`.
  3. Bấm "ĐĂNG NHẬP ADMIN" -> Chuyển vào Dashboard có huy hiệu xanh lá: **"Firebase Realtime Active (Free Spark)"**.

---

### Phút 00:50 - 01:45: Nền tảng Web: Thêm & Hiển thị Realtime (Yêu cầu 1 - 8.0 ĐIỂM)
- **Hành động:**
  1. **Hiển thị sản phẩm:** Thuyết minh: "Danh sách sản phẩm được lấy trực tiếp từ Firebase Firestore qua Stream thời gian thực, hiển thị đầy đủ hình ảnh (`image`), tên (`name`), giá (`price`), và số lượng (`soluong`)."
  2. **Thêm sản phẩm mới lên Firebase:**
     - Bấm nút "+ THÊM SẢN PHẨM".
     - Nhập: Tên: `iPad Pro M4 2024`, Giá: `28990000`, Số lượng: `12`, URL ảnh.
     - Bấm "THÊM SẢN PHẨM".
  3. **Chứng minh Realtime:** Chuyển nhanh sang tab Firebase Console: Document mới `iPad Pro M4 2024` lập tức xuất hiện trên Firebase với đúng 4 trường!

---

### Phút 01:45 - 02:25: Sửa, Xóa & Chức năng nâng cao (Yêu cầu 2 - 1.5 ĐIỂM)
- **Hành động:**
  1. **Sửa sản phẩm:** Bấm nút Sửa trên sản phẩm vừa thêm, đổi giá từ `28.990.000` thành `27.500.000` -> Dữ liệu trên Web và Firebase Console cập nhật ngay lập tức.
  2. **Xóa sản phẩm:** Bấm nút Xóa -> Dialog xác nhận "Bạn có chắc chắn muốn xóa sản phẩm này khỏi Firebase Cloud Firestore?" -> Bấm "Xác nhận xóa" -> Sản phẩm được xóa ngay.
  3. **Tính năng nâng cao:**
     - Giới thiệu 4 thẻ thống kê kho hàng tự động tính toán từ Firestore.
     - Gõ tìm kiếm theo tên thời gian thực.
     - Sắp xếp sản phẩm theo giá/số lượng.

---

### Phút 02:25 - 02:50: Nền tảng Mobile: Nhập ảnh & Hiển thị (Yêu cầu 3 - 0.5 ĐIỂM)
- **Hành động:**
  1. Bật chế độ Responsive Device (F12 trên Chrome) hoặc chạy ứng dụng trên giả lập Android.
  2. Mở form thêm sản phẩm, bấm "Chọn từ máy" để chứng minh tính năng nhập hình ảnh trên thiết bị di động.
  3. Mở màn hình xem chi tiết sản phẩm trên Mobile hiển thị đầy đủ 4 trường thông tin.

---

### Phút 02:50 - 03:10: Xuất file JSON nộp bài (Đáp ứng ghi chú đề bài)
- **Hành động:**
  1. Bấm nút **"Xuất JSON nộp bài"** trên thanh Header của ứng dụng Web.
  2. Hộp thoại hiển thị toàn bộ CSDL được tải trực tiếp từ Firebase Firestore, định dạng chuẩn mảng JSON 4 trường:
  3. Thuyết minh: "Khi hoàn tất, em sử dụng tính năng xuất JSON này để lưu dữ liệu Firebase ra file `database/products.json` phục vụ nộp bài theo đúng quy định."
  4. Lời kết: "Em xin cảm ơn thầy/cô đã theo dõi video demo!"

---

## 3. CÁC LỆNH ĐẨY MÃ NGUỒN LÊN GITHUB
```bash
git add .
git commit -m "feat: Nang cap toan dien sang Firebase Cloud Firestore Realtime (Ban Free Spark) va tinh nang xuat JSON nop bai"
git push origin main
```
Sau đó sao chép link repository dán vào file báo cáo nộp bài!
