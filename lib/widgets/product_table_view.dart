import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';

/// Chế độ hiển thị Bảng dữ liệu quản trị (Data Table View)
class ProductTableView extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onEdit;
  final Function(Product) onDelete;
  final Function(Product) onTap;

  const ProductTableView({
    super.key,
    required this.products,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  String _formatPrice(double price) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(price);
  }

  Widget _buildThumbnail(String image) {
    Widget imgWidget;
    if (image.isEmpty) {
      imgWidget = const Icon(Icons.inventory_2_outlined, size: 20, color: AppTheme.textMuted);
    } else if (image.startsWith('data:image')) {
      try {
        final base64Content = image.split(',').last;
        imgWidget = Image.memory(base64Decode(base64Content), fit: BoxFit.cover);
      } catch (_) {
        imgWidget = const Icon(Icons.broken_image, size: 20, color: AppTheme.textMuted);
      }
    } else {
      imgWidget = Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 20, color: AppTheme.textMuted),
      );
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: imgWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 800),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppTheme.background),
            headingTextStyle: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            dataRowColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.hovered)) {
                return AppTheme.primaryLight.withOpacity(0.5);
              }
              return AppTheme.surface;
            }),
            dataRowMinHeight: 64,
            dataRowMaxHeight: 64,
            columnSpacing: 24,
            columns: const [
              DataColumn(label: Text('SẢN PHẨM (name, image)')),
              DataColumn(label: Text('GIÁ BÁN (price)')),
              DataColumn(label: Text('TỒN KHO (soluong)')),
              DataColumn(label: Text('THAO TÁC')),
            ],
            rows: products.map((product) {
              return DataRow(
                onSelectChanged: (_) => onTap(product),
                cells: [
                  // Cột 1: Ảnh và Tên
                  DataCell(
                    Row(
                      children: [
                        _buildThumbnail(product.image),
                        const SizedBox(width: 12),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Cột 2: Giá bán
                  DataCell(
                    Text(
                      _formatPrice(product.price),
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  // Cột 3: Tồn kho & Trạng thái
                  DataCell(
                    StatusBadge(soluong: product.soluong),
                  ),
                  // Cột 4: Thao tác (Sửa, Xóa)
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primary),
                          tooltip: 'Sửa sản phẩm',
                          onPressed: () => onEdit(product),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.danger),
                          tooltip: 'Xóa sản phẩm',
                          onPressed: () => onDelete(product),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
