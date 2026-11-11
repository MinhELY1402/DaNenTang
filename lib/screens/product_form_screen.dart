import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../widgets/image_input_widget.dart';

/// Màn hình Form Thêm mới hoặc Sửa thông tin sản phẩm.
/// Tuân thủ nghiêm ngặt chỉ quản lý 4 trường: name, price, soluong, image.
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _soluongController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_imageUrl.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ảnh hoặc nhập URL hình ảnh sản phẩm'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final soluong = int.tryParse(_soluongController.text.trim()) ?? 0;
    final image = _imageUrl.trim();

    // Tạo đối tượng Product đúng 4 trường
    final newProduct = Product(
      name: name,
      price: price,
      soluong: soluong,
      image: image,
    );

    final provider = context.read<ProductProvider>();

    try {
      if (_isEditMode) {
        await provider.updateProduct(widget.productToEdit!, newProduct);
      } else {
        await provider.addProduct(newProduct);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'Cập nhật sản phẩm thành công!' : 'Thêm sản phẩm mới thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã có lỗi xảy ra: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditMode ? 'Sửa thông tin sản phẩm' : 'Thêm sản phẩm mới';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 1,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Banner ghi chú quy chuẩn 4 trường
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Dữ liệu CSDL bao gồm 4 trường bắt buộc: name, price, soluong, image.',
                                style: TextStyle(fontSize: 12, color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 1. Trường name (Tên sản phẩm)
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Tên sản phẩm (name)*',
                          hintText: 'Ví dụ: iPhone 15 Pro Max',
                          prefixIcon: const Icon(Icons.shopping_bag_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tên sản phẩm';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 2. Trường price (Giá sản phẩm) & 3. Trường soluong (Số lượng)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                labelText: 'Giá sản phẩm (price)*',
                                hintText: 'VNĐ',
                                prefixIcon: const Icon(Icons.attach_money),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Nhập giá';
                                }
                                final p = double.tryParse(value.trim());
                                if (p == null || p <= 0) {
                                  return 'Giá phải > 0';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _soluongController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                labelText: 'Số lượng (soluong)*',
                                hintText: 'Chiếc / cái',
                                prefixIcon: const Icon(Icons.inventory_2_outlined),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Nhập số lượng';
                                }
                                final sl = int.tryParse(value.trim());
                                if (sl == null || sl < 0) {
                                  return 'Số lượng >= 0';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 4. Trường image (Hình ảnh sản phẩm)
                      ImageInputWidget(
                        initialImageUrl: _imageUrl,
                        onImageChanged: (newImage) {
                          _imageUrl = newImage;
                        },
                      ),
                      const SizedBox(height: 28),

                      // Nút Lưu / Cập nhật
                      SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _submitForm,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.save),
                          label: Text(
                            _isEditMode ? 'LƯU THAY ĐỔI' : 'THÊM SẢN PHẨM',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
