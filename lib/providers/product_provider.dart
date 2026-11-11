import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/product_service.dart';

/// Provider quản lý dữ liệu thời gian thực (Realtime Stream) từ Firebase Cloud Firestore.
/// Tự động cập nhật giao diện khi có thay đổi từ bất kỳ client nào (Web hoặc Mobile).
class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();
  StreamSubscription<List<Product>>? _subscription;

  List<Product> _products = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _sortBy = 'default';

  ProductProvider() {
    _initRealtimeStream();
  }

  void _initRealtimeStream() {
    _isLoading = true;
    notifyListeners();

    _subscription = _service.getProductsStream().listen(
      (products) {
        _products = products;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // Getters
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  bool get isConnectedToFirebase => _service.isUsingFirebase;
  List<Product> get allProducts => List.unmodifiable(_products);

  /// Danh sách sản phẩm sau khi lọc từ khóa và sắp xếp nâng cao
  List<Product> get filteredProducts {
    List<Product> list = List.from(_products);

    // 1. Lọc theo tên sản phẩm
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      list = list.where((p) => p.name.toLowerCase().contains(query)).toList();
    }

    // 2. Sắp xếp nâng cao
    switch (_sortBy) {
      case 'price_asc':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'soluong_asc':
        list.sort((a, b) => a.soluong.compareTo(b.soluong));
        break;
      case 'soluong_desc':
        list.sort((a, b) => b.soluong.compareTo(a.soluong));
        break;
      case 'name_asc':
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      default:
        break;
    }

    return list;
  }

  // Thống kê kho hàng nâng cao từ dữ liệu Realtime
  int get totalProducts => _products.length;

  int get totalStock => _products.fold<int>(0, (sum, p) => sum + p.soluong);

  double get totalInventoryValue =>
      _products.fold<double>(0.0, (sum, p) => sum + (p.price * p.soluong));

  int get lowStockCount => _products.where((p) => p.soluong <= 5).length;

  /// Thêm mới sản phẩm trực tiếp lên Firebase Firestore
  Future<void> addProduct(Product product) async {
    await _service.addProduct(product);
  }

  /// Cập nhật sản phẩm trực tiếp trên Firebase Firestore
  Future<void> updateProduct(Product oldProduct, Product updatedProduct) async {
    final docId = oldProduct.id ?? '';
    await _service.updateProduct(docId, updatedProduct);
  }

  /// Xóa sản phẩm trực tiếp trên Firebase Firestore
  Future<void> deleteProduct(Product product) async {
    final docId = product.id ?? '';
    await _service.deleteProduct(docId);
  }

  /// Cập nhật từ khóa tìm kiếm
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Cập nhật tiêu chí sắp xếp
  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  /// Xuất toàn bộ CSDL Firebase ra JSON nộp bài
  Future<String> exportJson() async {
    return await _service.exportToJson();
  }
}
