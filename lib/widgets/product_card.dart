import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';

/// Thẻ hiển thị sản phẩm được thiết kế lại theo chuẩn UI Engineering hiện đại:
/// Tỉ lệ ảnh chuẩn 16:10, phân cấp thông tin rõ ràng, thao tác mượt mà.
class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;

  String _formatPrice(double price) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(price);
  }

  Widget _buildProductImage() {
    final img = widget.product.image;
    if (img.isEmpty) {
      return Container(
        color: AppTheme.background,
        child: const Center(
          child: Icon(Icons.inventory_2_outlined, size: 36, color: AppTheme.textMuted),
        ),
      );
    }

    if (img.startsWith('data:image')) {
      try {
        final base64Content = img.split(',').last;
        return Image.memory(
          base64Decode(base64Content),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.broken_image, size: 32, color: AppTheme.textMuted),
          ),
        );
      } catch (_) {
        return const Center(child: Icon(Icons.broken_image, size: 32, color: AppTheme.textMuted));
      }
    }

    return Image.network(
      img,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Center(
        child: Icon(Icons.broken_image, size: 32, color: AppTheme.textMuted),
      ),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: AppTheme.background,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered ? AppTheme.primary.withOpacity(0.5) : AppTheme.border,
            width: 1,
          ),
          boxShadow: _isHovered ? AppTheme.hoverShadow : AppTheme.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Khung Ảnh sản phẩm (image)
              Expanded(
                flex: 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildProductImage(),
                    // Badge trạng thái số lượng tồn kho (soluong)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: StatusBadge(soluong: widget.product.soluong),
                    ),
                  ],
                ),
              ),

              // 2. Thông tin Tên, Giá và Thao tác
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tên sản phẩm (name)
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Giá sản phẩm (price) & Thao tác
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _formatPrice(widget.product.price),
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: widget.onEdit,
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.edit_outlined, size: 16, color: AppTheme.primary),
                                ),
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: widget.onDelete,
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.dangerBg,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.delete_outline, size: 16, color: AppTheme.danger),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
