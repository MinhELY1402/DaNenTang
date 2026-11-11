import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';
import 'product_form_screen.dart';

/// Màn hình Chi tiết sản phẩm tối ưu cho nền tảng Di Động (Mobile First UX)
class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  String _formatPrice(double price) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(price);
  }

  Widget _buildProductHeroImage(String image) {
    if (image.isEmpty) {
      return Container(
        height: 320,
        color: AppTheme.background,
        child: const Center(
          child: Icon(Icons.inventory_2_outlined, size: 72, color: AppTheme.textMuted),
        ),
      );
    }

    if (image.startsWith('data:image')) {
      try {
        final base64Content = image.split(',').last;
        return Image.memory(
          base64Decode(base64Content),
          height: 320,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      } catch (_) {
        return Container(
          height: 320,
          color: AppTheme.background,
          child: const Center(child: Icon(Icons.broken_image, size: 72, color: AppTheme.textMuted)),
        );
      }
    }

    return Image.network(
      image,
      height: 320,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: 320,
        color: AppTheme.background,
        child: const Center(child: Icon(Icons.broken_image, size: 72, color: AppTheme.textMuted)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final currentProduct = provider.allProducts.firstWhere(
      (p) => p.name == product.name,
      orElse: () => product,
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm (Mobile)'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Ảnh sản phẩm Hero Image
            Stack(
              children: [
                _buildProductHeroImage(currentProduct.image),
                Positioned(
                  top: 16,
                  right: 16,
                  child: StatusBadge(soluong: currentProduct.soluong),
                ),
              ],
            ),

            // 2. Thẻ thông tin sản phẩm
            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentProduct.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatPrice(currentProduct.price),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Tồn: ${currentProduct.soluong} cái',
                            style: const TextStyle(
                              color: AppTheme.primaryDark,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 3. Khung kiểm chứng cấu trúc CSDL 4 trường
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.data_object, color: AppTheme.primary, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Cấu trúc Document Firebase (Chuẩn 4 trường)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    _buildFieldRow('name', currentProduct.name),
                    _buildFieldRow('price', '${currentProduct.price} VNĐ'),
                    _buildFieldRow('soluong', '${currentProduct.soluong}'),
                    _buildFieldRow('image', currentProduct.image.length > 40 ? '${currentProduct.image.substring(0, 40)}...' : currentProduct.image),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100), // Khoảng trống cho Bottom Bar
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Xác nhận xóa'),
                        content: Text('Xóa "${currentProduct.name}" khỏi Firebase?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Xác nhận xóa', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      await context.read<ProductProvider>().deleteProduct(currentProduct);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã xóa sản phẩm thành công!')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.danger),
                  label: const Text('XÓA SẢN PHẨM', style: TextStyle(color: AppTheme.danger)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProductFormScreen(productToEdit: currentProduct)),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('SỬA SẢN PHẨM'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              key,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          const Text(': ', style: TextStyle(color: AppTheme.textMuted)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
