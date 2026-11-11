import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Widget hỗ trợ chọn ảnh trên cả Web và Mobile:
/// - Chọn ảnh từ thư viện (Gallery) hoặc Camera qua [image_picker]
/// - Nhập trực tiếp đường dẫn URL hình ảnh
/// - Có khung xem trước (Preview) ảnh
class ImageInputWidget extends StatefulWidget {
  final String initialImageUrl;
  final ValueChanged<String> onImageChanged;

  const ImageInputWidget({
    super.key,
    required this.initialImageUrl,
    required this.onImageChanged,
  });

  @override
  State<ImageInputWidget> createState() => _ImageInputWidgetState();
}

class _ImageInputWidgetState extends State<ImageInputWidget> {
  late TextEditingController _urlController;
  final ImagePicker _picker = ImagePicker();
  String _currentImage = '';

  @override
  void initState() {
    super.initState();
    _currentImage = widget.initialImageUrl;
    _urlController = TextEditingController(text: widget.initialImageUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Chuyển ảnh thành chuỗi Base64 Data URL để hoạt động đồng nhất trên cả Web và Mobile
        final bytes = await pickedFile.readAsBytes();
        final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        setState(() {
          _currentImage = base64String;
          _urlController.text = '[Ảnh đã chọn từ thiết bị]';
        });
        widget.onImageChanged(_currentImage);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể chọn ảnh: $e')),
        );
      }
    }
  }

  Widget _buildPreview() {
    if (_currentImage.isEmpty) {
      return Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'Chưa có ảnh (Chọn từ máy hoặc nhập URL)',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      );
    }

    // Xử lý xem trước ảnh: Base64 hoặc Network URL
    Widget imageWidget;
    if (_currentImage.startsWith('data:image')) {
      final base64Content = _currentImage.split(',').last;
      imageWidget = Image.memory(
        base64Decode(base64Content),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, size: 40)),
      );
    } else {
      imageWidget = Image.network(
        _currentImage,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.broken_image, size: 40, color: Colors.redAccent),
              const SizedBox(height: 4),
              Text(
                'URL ảnh không tải được',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 180,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: imageWidget,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: InkWell(
            onTap: () {
              setState(() {
                _currentImage = '';
                _urlController.clear();
              });
              widget.onImageChanged('');
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hình ảnh sản phẩm (image)*',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        _buildPreview(),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'Nhập đường dẫn URL ảnh',
                  hintText: 'https://...',
                  prefixIcon: const Icon(Icons.link, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    tooltip: 'Tải ảnh từ URL',
                    onPressed: () {
                      final url = _urlController.text.trim();
                      if (url.isNotEmpty && !url.startsWith('[')) {
                        setState(() {
                          _currentImage = url;
                        });
                        widget.onImageChanged(_currentImage);
                      }
                    },
                  ),
                ),
                onChanged: (value) {
                  final url = value.trim();
                  if (url.startsWith('http://') || url.startsWith('https://')) {
                    setState(() {
                      _currentImage = url;
                    });
                    widget.onImageChanged(_currentImage);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library, size: 18),
              label: const Text('Chọn từ máy'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(width: 8),
            if (!kIsWeb)
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt, size: 18),
                label: const Text('Chụp ảnh'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
