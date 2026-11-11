import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import 'product_form_screen.dart';

/// Màn hình chi tiết sản phẩm tối ưu cho nền tảng Di Động (Mobile)
/// Hiển thị đầy đủ thông tin 4 trường: name, price, soluong, image.
class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  String _formatPrice(double price) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return formatter.format(price);
  }

  Widget _buildImage(String image) {
    if (image.isEmpty) {
      return Container(
        height: 280,
        color: Colors.grey.shade200,
        child: const Center(child: Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey)),
      );
    }

    if (image.startsWith('data:image')) {
      try {
        final base64Content = image.split(',').last;
        return Image.memory(
          base64Decode(base64Content),
          height: 280,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      } catch (_) {
        return Container(
          height: 280,
          color: Colors.grey.shade200,
          child: const Center(child: Icon(Icons.broken_image, size: 80)),
        );
      }
    }

    return Image.network(
      image,
      height: 280,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: 280,
        color: Colors.grey.shade200,
        child: const Center(child: Icon(Icons.broken_image, size: 80, color: Colors.grey)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    // Lấy bản mới nhất của product từ provider
    final currentProduct = provider.allProducts.firstWhere(
      (p) => p.name == product.name,
      orElse: () => product,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm (Mobile)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Sửa sản phẩm',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductFormScreen(productToEdit: currentProduct),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            tooltip: 'Xóa sản phẩm',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Xác nhận xóa'),
                  content: Text('Bạn có chắc chắn muốn xóa "${currentProduct.name}"?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Xóa', style: TextStyle(color: Colors.white)),
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
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Trường image
            _buildImage(currentProduct.image),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Trường name
                  Text(
                    currentProduct.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3. Trường price
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.deepOrange.shade200),
                    ),
                    child: Text(
                      _formatPrice(currentProduct.price),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. Trường soluong
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.inventory, color: Colors.blue, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Số lượng tồn kho (soluong):',
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${currentProduct.soluong} sản phẩm',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bảng tổng kết thông số chuẩn CSDL 4 trường
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cấu trúc dữ liệu ghi nhận (Chuẩn 4 trường):',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const Divider(height: 16),
                        _buildRowInfo('name', currentProduct.name),
                        _buildRowInfo('price', '${currentProduct.price} đ'),
                        _buildRowInfo('soluong', '${currentProduct.soluong}'),
                        _buildRowInfo('image', currentProduct.image.length > 50 ? '${currentProduct.image.substring(0, 50)}...' : currentProduct.image),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRowInfo(String key, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              key,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(val, style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }
}
