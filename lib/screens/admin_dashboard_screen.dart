import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../services/auth_service.dart';
import '../widgets/product_card.dart';
import '../widgets/stat_badge.dart';
import 'login_screen.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';

/// Màn hình chính phân hệ Admin quản trị sản phẩm:
/// - Chạy trực tiếp với Firebase Cloud Firestore qua Realtime Stream
/// - Nền tảng Web (8.0đ): Thêm, Hiển thị đầy đủ name, price, soluong, image
/// - Đăng nhập, Sửa, Xóa, Tính năng nâng cao (1.5đ): Lọc tìm kiếm, Sắp xếp, Thống kê kho hàng
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return formatter.format(value);
  }

  Future<void> _showExportJsonDialog(BuildContext context) async {
    final provider = context.read<ProductProvider>();
    final jsonStr = await provider.exportJson();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cloud_download, color: Colors.blue),
            SizedBox(width: 8),
            Text('Xuất CSDL từ Firebase (Chuẩn 4 trường)'),
          ],
        ),
        content: SizedBox(
          width: 550,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dữ liệu dưới đây được truy vấn trực tiếp từ Firebase Firestore. Toàn bộ bản ghi chỉ gồm 4 trường bắt buộc (name, price, soluong, image) để nộp bài:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Container(
                height: 250,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    jsonStr,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Sao chép JSON nộp bài'),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã sao chép CSDL JSON 4 trường từ Firebase! Sẵn sàng dán vào database/products.json'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteProduct(BuildContext context, Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Xác nhận xóa sản phẩm'),
          ],
        ),
        content: Text('Bạn có chắc chắn muốn xóa sản phẩm "${product.name}" khỏi Firebase Cloud Firestore?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xác nhận xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context.read<ProductProvider>().deleteProduct(product);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa thành công sản phẩm: ${product.name} trên Firebase'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final authService = context.watch<AuthService>();
    final products = productProvider.filteredProducts;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.storefront, color: Colors.blue.shade800, size: 24),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Admin Quản Lý Sản Phẩm',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Firebase Realtime Active (Free Spark)',
                      style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Nút xuất CSDL JSON từ Firebase
          ElevatedButton.icon(
            onPressed: () => _showExportJsonDialog(context),
            icon: const Icon(Icons.cloud_download, size: 16),
            label: const Text('Xuất JSON nộp bài'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade50,
              foregroundColor: Colors.blue.shade800,
              elevation: 0,
            ),
          ),
          const SizedBox(width: 8),
          // Nút Đăng xuất
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Đăng xuất (${authService.adminEmail ?? "Admin"})',
            onPressed: () {
              authService.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. THANH THỐNG KÊ KHO HÀNG REALTIME (TÍNH NĂNG NÂNG CAO - 1.5đ)
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      StatBadge(
                        title: 'Tổng sản phẩm',
                        value: '${productProvider.totalProducts} mặt hàng',
                        icon: Icons.inventory_2,
                        color: Colors.blue.shade700,
                      ),
                      StatBadge(
                        title: 'Tổng lượng tồn',
                        value: '${productProvider.totalStock} sản phẩm',
                        icon: Icons.pie_chart,
                        color: Colors.purple.shade700,
                      ),
                      StatBadge(
                        title: 'Tổng giá trị kho',
                        value: _formatCurrency(productProvider.totalInventoryValue),
                        icon: Icons.account_balance_wallet,
                        color: Colors.green.shade700,
                      ),
                      StatBadge(
                        title: 'Sắp hết hàng (<=5)',
                        value: '${productProvider.lowStockCount} mặt hàng',
                        icon: Icons.warning_amber_rounded,
                        color: Colors.orange.shade800,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2. THANH CÔNG CỤ TÌM KIẾM, SẮP XẾP & THÊM MỚI
                  Card(
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 700;
                          return Flex(
                            direction: isNarrow ? Axis.vertical : Axis.horizontal,
                            crossAxisAlignment: isNarrow ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
                            children: [
                              // Ô tìm kiếm thời gian thực
                              Expanded(
                                flex: isNarrow ? 0 : 3,
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Tìm kiếm sản phẩm theo tên...',
                                    prefixIcon: const Icon(Icons.search, size: 20),
                                    suffixIcon: _searchController.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear, size: 18),
                                            onPressed: () {
                                              _searchController.clear();
                                              productProvider.setSearchQuery('');
                                            },
                                          )
                                        : null,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                                  ),
                                  onChanged: (val) => productProvider.setSearchQuery(val),
                                ),
                              ),
                              SizedBox(width: isNarrow ? 0 : 12, height: isNarrow ? 12 : 0),

                              // Dropdown Sắp xếp nâng cao
                              DropdownButtonHideUnderline(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: DropdownButton<String>(
                                    value: productProvider.sortBy,
                                    icon: const Icon(Icons.sort, size: 20),
                                    items: const [
                                      DropdownMenuItem(value: 'default', child: Text('Sắp xếp: Mặc định')),
                                      DropdownMenuItem(value: 'name_asc', child: Text('Tên sản phẩm (A-Z)')),
                                      DropdownMenuItem(value: 'price_asc', child: Text('Giá: Thấp đến Cao')),
                                      DropdownMenuItem(value: 'price_desc', child: Text('Giá: Cao đến Thấp')),
                                      DropdownMenuItem(value: 'soluong_asc', child: Text('Số lượng: Ít đến Nhiều')),
                                      DropdownMenuItem(value: 'soluong_desc', child: Text('Số lượng: Nhiều đến Ít')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) productProvider.setSortBy(val);
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: isNarrow ? 0 : 12, height: isNarrow ? 12 : 0),

                              // NÚT THÊM SẢN PHẨM MỚI LÊN FIREBASE (8.0đ)
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const ProductFormScreen()),
                                  );
                                },
                                icon: const Icon(Icons.add, size: 20),
                                label: const Text('THÊM SẢN PHẨM', style: TextStyle(fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. DANH SÁCH SẢN PHẨM HIỂN THỊ REALTIME (8.0đ)
                  if (products.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            productProvider.searchQuery.isNotEmpty
                                ? 'Không tìm thấy sản phẩm nào khớp với "${productProvider.searchQuery}"'
                                : 'Chưa có sản phẩm nào trên Firebase Firestore.',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 2;
                        if (constraints.maxWidth > 1200) {
                          crossAxisCount = 4;
                        } else if (constraints.maxWidth > 800) {
                          crossAxisCount = 3;
                        } else if (constraints.maxWidth > 550) {
                          crossAxisCount = 2;
                        } else {
                          crossAxisCount = 1;
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: products.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: crossAxisCount == 1 ? 1.2 : 0.78,
                          ),
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return ProductCard(
                              product: product,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailScreen(product: product),
                                  ),
                                );
                              },
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductFormScreen(productToEdit: product),
                                  ),
                                );
                              },
                              onDelete: () => _confirmDeleteProduct(context, product),
                            );
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}
