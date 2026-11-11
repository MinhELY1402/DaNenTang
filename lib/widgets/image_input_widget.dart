import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';

/// Widget chọn hình ảnh sản phẩm đa nền tảng theo phong cách Dropzone cao cấp
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
          SnackBar(content: Text('Không thể chọn ảnh: $e'), backgroundColor: AppTheme.danger),
        );
      }
    }
  }

  Widget _buildPreview() {
    if (_currentImage.isEmpty) {
      return Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_upload_outlined, size: 28, color: AppTheme.primary),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tải lên hình ảnh sản phẩm',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Chọn file từ thiết bị hoặc dán đường dẫn URL bên dưới',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ],
        ),
      );
    }

    Widget imgWidget;
    if (_currentImage.startsWith('data:image')) {
      final base64Content = _currentImage.split(',').last;
      imgWidget = Image.memory(
        base64Decode(base64Content),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, size: 40)),
      );
    } else {
      imgWidget = Image.network(
        _currentImage,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.broken_image, size: 36, color: AppTheme.danger),
              const SizedBox(height: 4),
              const Text('Không tải được ảnh từ URL', style: TextStyle(color: AppTheme.dangerText, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: imgWidget,
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
              child: const Icon(Icons.close, color: Colors.white, size: 16),
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
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary),
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
                  hintText: 'Nhập đường dẫn URL ảnh (https://...)',
                  prefixIcon: const Icon(Icons.link, size: 18, color: AppTheme.textMuted),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.check, color: AppTheme.success, size: 18),
                    tooltip: 'Áp dụng URL',
                    onPressed: () {
                      final url = _urlController.text.trim();
                      if (url.isNotEmpty && !url.startsWith('[')) {
                        setState(() => _currentImage = url);
                        widget.onImageChanged(_currentImage);
                      }
                    },
                  ),
                ),
                onChanged: (val) {
                  final url = val.trim();
                  if (url.startsWith('http://') || url.startsWith('https://')) {
                    setState(() => _currentImage = url);
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
            OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined, size: 16, color: AppTheme.primary),
              label: const Text('Chọn ảnh từ máy', style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 8),
            if (!kIsWeb)
              OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined, size: 16, color: AppTheme.primary),
                label: const Text('Chụp ảnh', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
      ],
    );
  }
}
