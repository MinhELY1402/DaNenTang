# Todo List: Kế Hoạch UX/UI Redesign Theo Chuẩn Frontend UI Engineering

## Phase 1: Hệ Thống Design System & Tokens
- [x] Task 1: Khởi tạo Design System Theme `lib/theme/app_theme.dart`
  - Acceptance: Định nghĩa bảng màu SaaS chuyên nghiệp (Slate, Indigo, Emerald, Amber, Rose), Typography scale chuẩn mực, Input/Button/Card themes nhất quán.
  - Verify: Áp dụng vào `lib/main.dart` thành công.
  - Files: `lib/theme/app_theme.dart`, `lib/main.dart`
  - Scope: S (2 files)

- [x] Task 2: Tạo Widget hiển thị chỉ số kho hàng `lib/widgets/kpi_card.dart` và `lib/widgets/status_badge.dart`
  - Acceptance: Thẻ KPI thống kê có biểu tượng, số liệu lớn, nhãn phụ và chỉ báo màu sắc ngữ nghĩa; Status Badge phân loại: "Còn hàng" (xanh lá), "Sắp hết" (vàng cam), "Hết hàng" (đỏ).
  - Verify: Hiển thị đúng màu và dữ liệu theo số lượng sản phẩm.
  - Files: `lib/widgets/kpi_card.dart`, `lib/widgets/status_badge.dart`
  - Scope: S (2 files)

## Checkpoint 1: Design Tokens Active (HOÀN THÀNH)
- [x] Theme và các widget hiển thị trạng thái chuẩn sẵn sàng

---

## Phase 2: Redesign Màn Hình Đăng Nhập (Login Screen)
- [x] Task 3: Tái thiết kế `LoginScreen` với phong cách Split-Layout
  - Acceptance: Trên Web/Desktop chia làm 2 phần: Banner giới thiệu thương hiệu và hệ thống quản trị bên trái; Khung đăng nhập tối giản, tương phẩn cao bên phải với nút 1-click Demo credentials. Tự động chuyển sang Card đơn trên Mobile.
  - Verify: Đăng nhập trơn tru, giao diện hiện đại chuẩn SaaS.
  - Files: `lib/screens/login_screen.dart`
  - Scope: S (1 file)

## Checkpoint 2: Login Screen Polished (HOÀN THÀNH)
- [x] Màn hình đăng nhập đạt chuẩn SaaS chuyên nghiệp

---

## Phase 3: Redesign Dashboard Admin Shell & Dual View (Table & Grid)
- [x] Task 4: Xây dựng Admin Sidebar `lib/widgets/admin_sidebar.dart`
  - Acceptance: Thanh điều hướng bên trái cho màn hình máy tính (logo, danh mục menu: Dashboard, Sản phẩm, Báo cáo CSDL, tài khoản admin, nút đăng xuất). Hỗ trợ đóng mở responsive.
  - Verify: Responsive Drawer trên Mobile, Sidebar cố định trên Web.
  - Files: `lib/widgets/admin_sidebar.dart`
  - Scope: S (1 file)

- [x] Task 5: Xây dựng chế độ xem Bảng dữ liệu `lib/widgets/product_table_view.dart`
  - Acceptance: Chế độ Data Table chuẩn quản trị: Cột Ảnh thumbnail, Tên sản phẩm, Giá nổi bật, Huy hiệu tồn kho, và Cột hành động (Sửa/Xóa). Hỗ trợ sắp xếp nhanh theo cột.
  - Verify: Hiển thị dạng bảng sắc nét, cuộn ngang mượt mà khi màn hình hẹp.
  - Files: `lib/widgets/product_table_view.dart`
  - Scope: M (1 file)

- [x] Task 6: Nâng cấp `ProductCard` và `AdminDashboardScreen`
  - Acceptance: Nâng cấp thẻ sản phẩm với tỷ lệ ảnh chuẩn 16:10, hiệu ứng hover viền tinh tế, nút chuyển đổi Toggle qua lại giữa [Xem Dạng Bảng] và [Xem Dạng Thẻ]. Bổ sung các Filter Chips (Tất cả, Còn hàng, Sắp hết).
  - Verify: Bấm chuyển đổi giữa Bảng và Lưới phản hồi ngay lập tức, dữ liệu đồng bộ 100%.
  - Files: `lib/widgets/product_card.dart`, `lib/screens/admin_dashboard_screen.dart`
  - Scope: M (2 files)

## Checkpoint 3: Admin Dashboard Transformed (HOÀN THÀNH)
- [x] Trải nghiệm quản trị sản phẩm hiện đại với 2 chế độ hiển thị linh hoạt

---

## Phase 4: Redesign Form Thêm/Sửa với Live Preview
- [x] Task 7: Tái thiết kế `ProductFormScreen` theo dạng 2 cột kèm Live Preview
  - Acceptance: Trên Web chia 2 cột: Cột trái nhập liệu Tên, Giá (format VNĐ realtime), Số lượng; Cột phải hiển thị thẻ sản phẩm thực tế thời gian thực (Live Preview Card) cập nhật ngay khi admin nhập liệu.
  - Verify: Nhập tên/giá/ảnh bên trái -> thẻ bên phải cập nhật tức thì.
  - Files: `lib/screens/product_form_screen.dart`
  - Scope: M (1 file)

- [x] Task 8: Nâng cấp `ImageInputWidget`
  - Acceptance: Khung chọn ảnh dạng Dropzone chuyên nghiệp, có tab chuyển đổi giữa [Tải ảnh từ máy / Camera] và [Dán liên kết URL], có nút xóa ảnh và khung xem trước bo tròn tinh tế.
  - Verify: Chọn ảnh từ máy hoặc URL hoạt động hoàn hảo.
  - Files: `lib/widgets/image_input_widget.dart`
  - Scope: S (1 file)

## Checkpoint 4: Form & Live Preview Complete (HOÀN THÀNH)
- [x] Trải nghiệm nhập liệu sản phẩm trực quan, đẳng cấp

---

## Phase 5: Tối Ưu Mobile & Hoàn Thiện Hồ Sơ
- [x] Task 9: Tinh chỉnh màn hình Mobile `ProductDetailScreen`
  - Acceptance: Giao diện chi tiết sản phẩm trên Mobile với hình ảnh tràn viền bo góc, thanh thông tin nổi, trạng thái kho hàng và thanh hành động nổi cố định dưới đáy màn hình (Bottom Action Bar).
  - Verify: Thao tác vuốt chạm trên Mobile mượt mà, dễ bấm bằng một tay.
  - Files: `lib/screens/product_detail_screen.dart`
  - Scope: S (1 file)

- [x] Task 10: Cập nhật tài liệu Báo cáo `docs/REPORT.md`
  - Acceptance: Bổ sung phần giới thiệu Design System mới và các cải tiến UX/UI nổi bật để ghi điểm tuyệt đối trong báo cáo.
  - Verify: File báo cáo đầy đủ thông tin nâng cấp.
  - Files: `docs/REPORT.md`
  - Scope: S (1 file)

## Checkpoint 5: UI Redesign Final Review (HOÀN TẤT)
- [x] Toàn bộ ứng dụng lột xác với diện mạo mới
- [x] Ràng buộc 4 trường CSDL vẫn được bảo toàn nguyên vẹn
- [x] Trải nghiệm người dùng đạt chuẩn sản phẩm thực tế
