# Implementation Plan: Redesign Giao Diện & Trải Nghiệm Người Dùng (UX/UI Engineering)

## Overview
Dự án được tái thiết kế toàn diện theo chuẩn **Frontend UI Engineering** và tiêu chuẩn giao diện sản phẩm SaaS/Admin Dashboard hiện đại (như Shopify Admin, Linear, Stripe Dashboard). Mục tiêu là nâng cấp ứng dụng từ phong cách mặc định sang một sản phẩm quản trị cao cấp, chỉn chu, có hệ thống Design System nhất quán, tính năng xem trước (Live Preview), hỗ trợ 2 chế độ xem (Bảng dữ liệu Table & Lưới thẻ Grid), tối ưu hóa trải nghiệm tương tác trên cả Web và Mobile.

---

## Architecture & UX/UI Decisions (Nguyên tắc thiết kế)

### 1. Loại bỏ "AI Aesthetic" & Xây dựng Design System chuẩn mực
- **Bảng màu (Color Palette):**
  - Surface & Background: Slate 50 (`#F8FAFC`), Pure White (`#FFFFFF`), Border Slate 200 (`#E2E8F0`).
  - Primary Brand: Deep Indigo (`#4F46E5` / `#4338CA`) — tạo cảm giác chuyên nghiệp, tin cậy.
  - Semantic Status:
    - Thành công / Còn hàng: Emerald (`#10B981` / text: `#065F46`, bg: `#ECFDF5`).
    - Cảnh báo / Sắp hết hàng (<=5): Amber (`#F59E0B` / text: `#92400E`, bg: `#FFFBEB`).
    - Báo động / Hết hàng / Xóa: Rose (`#F43F5E` / text: `#9F1239`, bg: `#FFF1F2`).
- **Typography & Scale:**
  - Tiêu đề Trang: 24px SemiBold.
  - Tiêu đề Mục: 16px Medium.
  - Nội dung: 14px Regular.
  - Metadata / Nhãn phụ: 12px Regular/Medium.
- **Border Radius:** Nhất quán `8px` cho nút/input, `12px` cho cards/dialogs, `20px` cho badges (không bo tròn quá đà).

### 2. Cấu trúc Giao diện Admin Shell (Modern SaaS Layout)
- **Web Desktop (>= 900px):**
  - **Sidebar Cố Định (Collapsible):** Logo thương hiệu, menu chức năng (Tổng quan, Sản phẩm, Báo cáo CSDL, Cài đặt), thông tin tài khoản Admin đang đăng nhập.
  - **Top Navigation Bar:** Thanh tìm kiếm nhanh kèm phím tắt gợi ý, chỉ báo trạng thái Firebase Realtime với hiệu ứng Pulse xanh lá, nút Quick Action ("+ Thêm sản phẩm", "Xuất JSON").
  - **Content Area:** Thống kê KPI Cards với trend indicators -> Bộ lọc nhanh (Tất cả, Còn hàng, Sắp hết) -> Nút chuyển đổi View Mode (Bảng dữ liệu Table & Lưới thẻ Grid) -> Danh sách sản phẩm.
- **Mobile Responsive (< 900px):**
  - Drawer Navigation mở từ cạnh trái.
  - Bố cục một cột co giãn linh hoạt, các thẻ sản phẩm tối ưu diện tích chạm (Touch Target >= 44px).

### 3. Cải tiến Form Thêm/Sửa Sản Phẩm (2-Column & Live Preview)
- **Trên Web:** Chia làm 2 cột:
  - Cột trái: Nhập thông tin (Tên, Giá có format VNĐ realtime, Số lượng có nút tăng giảm Stepper).
  - Cột phải: Media Dropzone & **Live Preview Card** (Admin gõ đến đâu, chiếc thẻ sản phẩm thực tế hiển thị ngay đến đó giúp hình dung giao diện cuối cùng).
- **Trên Mobile:** Xếp chồng dọc tự nhiên, giữ nguyên tính năng xem trước ảnh.

### 4. Đảm bảo 100% Ràng buộc Đề bài:
- Toàn bộ cơ sở dữ liệu và model vẫn giữ nghiêm ngặt **CHỈ ĐÚNG 4 TRƯỜNG**: `name`, `price`, `soluong`, `image`.
- Toàn bộ cải tiến UX/UI là nâng cao ở tầng Presentation & Interaction, không làm thay đổi cấu trúc dữ liệu.

---

## Dependency Graph
```
lib/theme/app_theme.dart (Hệ thống màu sắc, typography, card style, button style)
    │
    ├── lib/widgets/admin_sidebar.dart (Thanh điều hướng Sidebar cho Admin)
    ├── lib/widgets/top_nav_bar.dart (Thanh Top Bar với Search & Pulse Status)
    ├── lib/widgets/kpi_card.dart (Thẻ chỉ số thống kê kho hàng cao cấp)
    │
    ├── lib/widgets/product_table_view.dart (Chế độ xem Bảng dữ liệu quản trị chuẩn)
    ├── lib/widgets/product_grid_view.dart (Chế độ xem Lưới sản phẩm nâng cao)
    │
    ├── lib/screens/login_screen.dart (Redesign Split-screen hiện đại)
    ├── lib/screens/admin_dashboard_screen.dart (Tổng hợp Admin Shell)
    ├── lib/screens/product_form_screen.dart (2-Column + Live Preview)
    └── lib/screens/product_detail_screen.dart (Mobile Product Sheet cao cấp)
```

---

## Task Breakdown Phases

### Phase 1: Hệ Thống Theme & Token Thiết Kế (Design System Foundation)
- **Task 1:** Tạo `lib/theme/app_theme.dart` định nghĩa toàn bộ palette màu, typography, card decoration, shadow tinh tế và component themes.
- **Task 2:** Tạo các widget hiển thị trạng thái chuẩn UI: `kpi_card.dart` (thẻ thống kê) và `status_badge.dart` (huy hiệu tình trạng tồn kho: Còn hàng, Sắp hết, Hết hàng).

### Checkpoint 1: Theme Ready
- [ ] Bảng màu nhất quán, không dùng màu mặc định hay gradient lòe loẹt.
- [ ] Typography phân cấp rõ ràng theo chuẩn 8px grid.

---

### Phase 2: Redesign Màn Hình Đăng Nhập (Login Screen Split-Layout)
- **Task 3:** Tái thiết kế `LoginScreen` với bố cục Split-Screen trên Web (Cột trái: Giới thiệu hệ thống quản trị & minh họa; Cột phải: Form đăng nhập tinh tế với autofill 1-click cho người chấm thi).
- **Task 4:** Responsive tự động chuyển sang Card đơn thanh lịch trên Mobile.

### Checkpoint 2: Login Screen Polished
- [ ] Màn hình đăng nhập đạt chuẩn doanh nghiệp, mượt mà và trực quan.

---

### Phase 3: Redesign Dashboard Admin Shell & 2 Chế Độ Xem (Table & Grid)
- **Task 5:** Xây dựng `AdminSidebar` và `TopNavBar` mang lại trải nghiệm hệ thống quản trị chuyên nghiệp.
- **Task 6:** Xây dựng `ProductTableView` (Bảng dữ liệu quản trị với thumbnail tròn/bo góc, tên, giá nổi bật, chip số lượng, nút thao tác Sửa/Xóa).
- **Task 7:** Nâng cấp `ProductCard` và `ProductGridView` với hover effect, badge tình trạng kho hàng và tỉ lệ ảnh chuẩn mực.
- **Task 8:** Tích hợp bộ lọc Filter Tabs (Tất cả, Còn hàng, Cảnh báo sắp hết) và nút chuyển đổi qua lại giữa Table và Grid view trong `AdminDashboardScreen`.

### Checkpoint 3: Admin Dashboard Transformed
- [ ] Chuyển đổi mượt mà giữa Table view và Grid view.
- [ ] Thống kê KPI hiển thị đẹp mắt, lọc sản phẩm nhanh chóng.

---

### Phase 4: Redesign Form Thêm/Sửa với Live Preview
- **Task 9:** Tái thiết kế `ProductFormScreen` theo dạng 2 cột: Form nhập liệu bên trái + Khung xem trước thẻ sản phẩm thực tế bên phải (Live Preview).
- **Task 10:** Nâng cấp `ImageInputWidget` với khung dropzone trực quan, preview tức thì và nút xóa ảnh tinh tế.

### Checkpoint 4: Form Experience Enhanced
- [ ] Người dùng thấy ngay kết quả sản phẩm khi đang gõ tên/giá/số lượng/ảnh.

---

### Phase 5: Redesign Mobile Detail & Cập Nhật Báo Cáo
- **Task 11:** Tinh chỉnh `ProductDetailScreen` tối ưu hóa trải nghiệm vuốt chạm trên Mobile.
- **Task 12:** Cập nhật ảnh chụp và tài liệu `docs/REPORT.md` phản ánh thiết kế UI mới.

---

## Risks and Mitigations
| Rủi ro | Mức độ | Biện pháp giảm thiểu |
|---|---|---|
| Giao diện quá phức tạp làm vỡ bố cục trên màn hình nhỏ | Trung bình | Áp dụng triệt để `LayoutBuilder` và breakpoints (360px, 600px, 900px, 1200px) để tự động co giãn. |
| Thay đổi UI vô tình vi phạm cấu trúc 4 trường của CSDL | Cao | Tuyệt đối giữ nguyên `Product` model và Firestore data payload: CHỈ CÓ 4 TRƯỜNG `name`, `price`, `soluong`, `image`. |
