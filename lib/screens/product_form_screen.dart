import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/image_input_widget.dart';
import '../widgets/product_card.dart';

/// Form Thêm / Sửa sản phẩm được tái thiết kế theo dạng 2 cột kèm Live Preview Card
class ProductFormScreen extends StatefulWidget {
  final Product? productToEdit;

  const ProductFormScreen({super.key, this.productToEdit});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _soluongController;
  String _imageUrl = '';
  bool _isSaving = false;

  bool get _isEditMode => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;
    _nameController = TextEditingController(text: p?.name ?? '');
    _priceController = TextEditingController(text: p != null ? p.price.toStringAsFixed(0) : '');
    _soluongController = TextEditingController(text: p != null ? p.soluong.toString() : '1');
    _imageUrl = p?.image ?? '';

    // Lắng nghe thay đổi để cập nhật Live Preview
    _nameController.addListener(() => setState(() {}));
    _priceController.addListener(() => setState(() {}));
    _soluongController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _soluongController.dispose();
    super.dispose();
  }

  Product _getPreviewProduct() {
    final name = _nameController.text.trim().isEmpty ? 'Tên sản phẩm mẫu' : _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final soluong = int.tryParse(_soluongController.text.trim()) ?? 0;
    return Product(
      name: name,
      price: price,
      soluong: soluong,
      image: _imageUrl,
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageUrl.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ảnh từ thiết bị hoặc dán link URL ảnh'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final soluong = int.tryParse(_soluongController.text.trim()) ?? 0;
    final image = _imageUrl.trim();

    // Ràng buộc nghiêm ngặt: Product chỉ mang 4 trường
    final productData = Product(
      name: name,
      price: price,
      soluong: soluong,
      image: image,
    );

    final provider = context.read<ProductProvider>();

    try {
      if (_isEditMode) {
        await provider.updateProduct(widget.productToEdit!, productData);
      } else {
        await provider.addProduct(productData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'Cập nhật sản phẩm lên Firebase thành công!' : 'Thêm sản phẩm mới lên Firebase thành công!'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildFormFields() {
    final previewPrice = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final formattedPreview = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(previewPrice);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thông tin CSDL 4 trường
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primaryBorder),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified, color: AppTheme.primary, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ràng buộc CSDL: Lưu và đồng bộ đúng 4 trường (name, price, soluong, image) lên Firebase.',
                      style: TextStyle(fontSize: 12, color: AppTheme.primaryDark, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 1. Tên sản phẩm (name)
            const Text('Tên sản phẩm (name)*', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Ví dụ: iPhone 15 Pro Max 256GB',
                prefixIcon: Icon(Icons.shopping_bag_outlined, size: 18, color: AppTheme.textMuted),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên sản phẩm' : null,
            ),
            const SizedBox(height: 18),

            // 2. Giá sản phẩm (price) & 3. Số lượng (soluong)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Giá bán (price)*', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          if (previewPrice > 0)
                            Text(
                              formattedPreview,
                              style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          hintText: '29990000',
                          prefixIcon: Icon(Icons.attach_money, size: 18, color: AppTheme.textMuted),
                          suffixText: 'VNĐ',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Nhập giá bán';
                          final p = double.tryParse(v.trim());
                          if (p == null || p <= 0) return 'Giá phải > 0';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Số lượng (soluong)*', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _soluongController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          hintText: '15',
                          prefixIcon: Icon(Icons.inventory_2_outlined, size: 18, color: AppTheme.textMuted),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Nhập số lượng';
                          final sl = int.tryParse(v.trim());
                          if (sl == null || sl < 0) return 'SL >= 0';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 4. Hình ảnh sản phẩm (image)
            ImageInputWidget(
              initialImageUrl: _imageUrl,
              onImageChanged: (newImage) => setState(() => _imageUrl = newImage),
            ),
            const SizedBox(height: 28),

            // Nút Lưu và Hủy
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('HỦY BỎ'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _submitForm,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(_isEditMode ? 'LƯU THAY ĐỔI' : 'THÊM VÀO FIREBASE'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLivePreviewPanel() {
    final preview = _getPreviewProduct();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.remove_red_eye_outlined, size: 16, color: AppTheme.primary),
              ),
              const SizedBox(width: 10),
              const Text(
                'LIVE PREVIEW (XEM TRƯỚC)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Thẻ sản phẩm sẽ hiển thị trên hệ thống như bên dưới:',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),

          // Khung hiển thị mô phỏng thẻ sản phẩm thực tế
          Center(
            child: SizedBox(
              width: 280,
              height: 340,
              child: ProductCard(
                product: preview,
                onTap: () {},
                onEdit: () {},
                onDelete: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditMode ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm mới';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Trên Web/Desktop >= 800px -> Bố cục 2 cột Form + Live Preview
                if (constraints.maxWidth >= 800) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: _buildFormFields()),
                      const SizedBox(width: 24),
                      Expanded(flex: 4, child: _buildLivePreviewPanel()),
                    ],
                  );
                }

                // Trên Mobile -> Bố cục dọc
                return Column(
                  children: [
                    _buildFormFields(),
                    const SizedBox(height: 24),
                    _buildLivePreviewPanel(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
