import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/kpi_card.dart';
import '../widgets/product_card.dart';
import '../widgets/product_table_view.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';

/// Màn hình Admin Dashboard thiết kế theo chuẩn SaaS hiện đại:
/// - Admin Shell Layout (Sidebar điều hướng + TopBar)
/// - Thống kê KPI Cards cao cấp
/// - Bộ lọc Filter Chips thông minh
/// - Chế độ xem kép (Dual View): Bảng dữ liệu (Table) & Lưới thẻ (Grid)
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _searchController = TextEditingController();
  bool _isTableView = false; // Mặc định hiển thị dạng Grid, có thể chuyển sang Table
  String _stockFilter = 'all'; // 'all', 'in_stock', 'low_stock'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(value);
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
            Icon(Icons.cloud_download, color: AppTheme.primary),
            SizedBox(width: 10),
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
                'Dữ liệu JSON truy vấn thời gian thực từ Firebase Cloud Firestore (chỉ có đúng 4 trường name, price, soluong, image):',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 12),
              Container(
                height: 250,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.sidebarBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    jsonStr,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: AppTheme.success,
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
                  content: Text('Đã sao chép CSDL JSON 4 trường từ Firebase!'),
                  backgroundColor: AppTheme.success,
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
            Icon(Icons.warning_amber_rounded, color: AppTheme.danger),
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
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
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
            content: Text('Đã xóa thành công sản phẩm: ${product.name}'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  List<Product> _applyStockFilter(List<Product> products) {
    if (_stockFilter == 'in_stock') {
      return products.where((p) => p.soluong > 5).toList();
    } else if (_stockFilter == 'low_stock') {
      return products.where((p) => p.soluong <= 5).toList();
    }
    return products;
  }

  Widget _buildTopBar(BuildContext context, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          if (!isDesktop)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quản Lý Sản Phẩm',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.fiber_manual_record, size: 10, color: AppTheme.success),
                  SizedBox(width: 6),
                  Text(
                    'Firebase Realtime Active (Free Spark)',
                    style: TextStyle(
                      color: AppTheme.successText,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),

          // Nút xuất JSON nộp bài
          OutlinedButton.icon(
            onPressed: () => _showExportJsonDialog(context),
            icon: const Icon(Icons.cloud_download_outlined, size: 16),
            label: const Text('Xuất JSON nộp bài'),
          ),
          const SizedBox(width: 12),

          // Nút Thêm sản phẩm mới
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductFormScreen()),
              );
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('THÊM SẢN PHẨM'),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(ProductProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 1000 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
        return GridView.count(
          crossAxisCount: crossCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: crossCount == 4 ? 1.8 : 2.4,
          children: [
            KpiCard(
              title: 'TỔNG SẢN PHẨM',
              value: '${provider.totalProducts}',
              subtitle: 'Mặt hàng đang kinh doanh',
              icon: Icons.inventory_2_outlined,
              accentColor: AppTheme.primary,
            ),
            KpiCard(
              title: 'TỔNG LƯỢNG TỒN',
              value: '${provider.totalStock}',
              subtitle: 'Sản phẩm có trong kho',
              icon: Icons.layers_outlined,
              accentColor: const Color(0xFF0284C7),
            ),
            KpiCard(
              title: 'TỔNG GIÁ TRỊ KHO',
              value: _formatCurrency(provider.totalInventoryValue),
              subtitle: 'Tính theo giá niêm yết',
              icon: Icons.account_balance_wallet_outlined,
              accentColor: AppTheme.success,
            ),
            KpiCard(
              title: 'CẢNH BÁO SẮP HẾT',
              value: '${provider.lowStockCount}',
              subtitle: 'Mặt hàng tồn <= 5 cái',
              icon: Icons.warning_amber_rounded,
              accentColor: AppTheme.warning,
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterAndControls(ProductProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Thanh tìm kiếm
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm sản phẩm theo tên...',
                    prefixIcon: const Icon(Icons.search, size: 18, color: AppTheme.textMuted),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              provider.setSearchQuery('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onChanged: (val) => provider.setSearchQuery(val),
                ),
              ),
              const SizedBox(width: 12),

              // Dropdown Sắp xếp
              DropdownButtonHideUnderline(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: DropdownButton<String>(
                    value: provider.sortBy,
                    icon: const Icon(Icons.sort, size: 18, color: AppTheme.textSecondary),
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
                    items: const [
                      DropdownMenuItem(value: 'default', child: Text('Mặc định')),
                      DropdownMenuItem(value: 'name_asc', child: Text('Tên (A-Z)')),
                      DropdownMenuItem(value: 'price_asc', child: Text('Giá: Thấp đến Cao')),
                      DropdownMenuItem(value: 'price_desc', child: Text('Giá: Cao đến Thấp')),
                      DropdownMenuItem(value: 'soluong_asc', child: Text('Tồn: Ít đến Nhiều')),
                      DropdownMenuItem(value: 'soluong_desc', child: Text('Tồn: Nhiều đến Ít')),
                    ],
                    onChanged: (val) {
                      if (val != null) provider.setSortBy(val);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Nút chuyển đổi View Mode (Bảng Table vs Lưới Grid)
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.grid_view,
                        size: 18,
                        color: !_isTableView ? AppTheme.primary : AppTheme.textMuted,
                      ),
                      tooltip: 'Xem dạng Thẻ (Grid View)',
                      onPressed: () => setState(() => _isTableView = false),
                    ),
                    Container(width: 1, height: 24, color: AppTheme.border),
                    IconButton(
                      icon: Icon(
                        Icons.table_rows_outlined,
                        size: 18,
                        color: _isTableView ? AppTheme.primary : AppTheme.textMuted,
                      ),
                      tooltip: 'Xem dạng Bảng (Table View)',
                      onPressed: () => setState(() => _isTableView = true),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Filter Chips
          Row(
            children: [
              _buildFilterChip('all', 'Tất cả (${provider.allProducts.length})'),
              const SizedBox(width: 8),
              _buildFilterChip('in_stock', 'Còn hàng (${provider.allProducts.where((p) => p.soluong > 5).length})'),
              const SizedBox(width: 8),
              _buildFilterChip('low_stock', 'Sắp hết hàng (${provider.lowStockCount})'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _stockFilter == filterKey;
    return InkWell(
      onTap: () => setState(() => _stockFilter = filterKey),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildProductList(List<Product> products) {
    if (products.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(60),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 54, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              const Text(
                'Không tìm thấy sản phẩm nào',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text(
                'Thử thay đổi từ khóa tìm kiếm hoặc bỏ bộ lọc.',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    if (_isTableView) {
      return ProductTableView(
        products: products,
        onTap: (product) => _navigateToDetail(product),
        onEdit: (product) => _navigateToEdit(product),
        onDelete: (product) => _confirmDeleteProduct(context, product),
      );
    }

    // Grid View
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 850) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 500) {
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
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: crossAxisCount == 1 ? 1.25 : 0.78,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              product: product,
              onTap: () => _navigateToDetail(product),
              onEdit: () => _navigateToEdit(product),
              onDelete: () => _confirmDeleteProduct(context, product),
            );
          },
        );
      },
    );
  }

  void _navigateToDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
    );
  }

  void _navigateToEdit(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductFormScreen(productToEdit: product)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final filteredProducts = _applyStockFilter(provider.filteredProducts);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;

          final mainContent = Column(
            children: [
              _buildTopBar(context, isDesktop),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Thống kê KPI
                            _buildKpiGrid(provider),
                            const SizedBox(height: 24),

                            // 2. Toolbar Tìm kiếm, Sắp xếp & Chế độ xem
                            _buildFilterAndControls(provider),
                            const SizedBox(height: 20),

                            // 3. Danh sách sản phẩm (Table hoặc Grid)
                            _buildProductList(filteredProducts),
                          ],
                        ),
                      ),
              ),
            ],
          );

          if (isDesktop) {
            return Row(
              children: [
                AdminSidebar(
                  selectedIndex: 1,
                  onItemSelected: (_) {},
                  onExportJson: () => _showExportJsonDialog(context),
                ),
                Expanded(child: mainContent),
              ],
            );
          }

          return Scaffold(
            drawer: Drawer(
              child: AdminSidebar(
                selectedIndex: 1,
                onItemSelected: (_) => Navigator.pop(context),
                onExportJson: () {
                  Navigator.pop(context);
                  _showExportJsonDialog(context);
                },
              ),
            ),
            body: mainContent,
          );
        },
      ),
    );
  }
}
