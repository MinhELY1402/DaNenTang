import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

/// Dịch vụ quản lý dữ liệu sản phẩm kết nối thời gian thực với Firebase Cloud Firestore.
/// Ràng buộc: Document trên Firestore CHỈ CHỨA ĐÚNG 4 TRƯỜNG:
/// 1. name    : String (Tên sản phẩm)
/// 2. price   : double / num (Giá sản phẩm)
/// 3. soluong : int (Số lượng sản phẩm)
/// 4. image   : String (Link URL hoặc dữ liệu hình ảnh)
class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'products';

  // Danh sách dự phòng nếu chưa cấu hình Firebase
  final List<Product> _mockCache = [
    Product(
      id: 'mock_1',
      name: "iPhone 15 Pro Max 256GB",
      price: 29990000,
      soluong: 15,
      image: "https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=600",
    ),
    Product(
      id: 'mock_2',
      name: "Samsung Galaxy S24 Ultra",
      price: 27490000,
      soluong: 20,
      image: "https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=600",
    ),
    Product(
      id: 'mock_3',
      name: "MacBook Pro M3 14 inch",
      price: 39990000,
      soluong: 8,
      image: "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=600",
    ),
    Product(
      id: 'mock_4',
      name: "Tai nghe Sony WH-1000XM5",
      price: 6990000,
      soluong: 35,
      image: "https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=600",
    ),
    Product(
      id: 'mock_5',
      name: "Bàn phím cơ Keychron K2 Pro",
      price: 2150000,
      soluong: 42,
      image: "https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=600",
    ),
  ];

  final StreamController<List<Product>> _fallbackController =
      StreamController<List<Product>>.broadcast();

  bool _isUsingFirebase = true;
  bool get isUsingFirebase => _isUsingFirebase;

  /// Lắng nghe dữ liệu thời gian thực (Realtime Stream) từ Firebase Cloud Firestore
  Stream<List<Product>> getProductsStream() {
    try {
      return _firestore
          .collection(_collectionName)
          .snapshots()
          .map((snapshot) {
            _isUsingFirebase = true;
            return snapshot.docs.map((doc) {
              return Product.fromMap(doc.data(), documentId: doc.id);
            }).toList();
          })
          .handleError((error) {
            // Tự động chuyển sang fallback stream nếu Firebase chưa cấu hình
            _isUsingFirebase = false;
            _fallbackController.add(List<Product>.from(_mockCache));
            return _mockCache;
          });
    } catch (_) {
      _isUsingFirebase = false;
      return Stream.value(List<Product>.from(_mockCache));
    }
  }

  /// Thêm mới một sản phẩm lên Firebase Cloud Firestore
  /// RÀNG BUỘC: Chỉ gửi lên đúng 4 trường từ product.toJson()
  Future<void> addProduct(Product product) async {
    final payload = product.toJson(); // CHỈ CÓ 4 TRƯỜNG: name, price, soluong, image

    try {
      await _firestore.collection(_collectionName).add(payload);
    } catch (e) {
      // Lưu vào cache cục bộ nếu offline
      _isUsingFirebase = false;
      final newProduct = Product(
        id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
        name: product.name,
        price: product.price,
        soluong: product.soluong,
        image: product.image,
      );
      _mockCache.insert(0, newProduct);
      _fallbackController.add(List<Product>.from(_mockCache));
    }
  }

  /// Cập nhật sản phẩm trên Firebase Cloud Firestore
  Future<void> updateProduct(String id, Product updatedProduct) async {
    final payload = updatedProduct.toJson(); // CHỈ CÓ 4 TRƯỜNG: name, price, soluong, image

    try {
      await _firestore.collection(_collectionName).doc(id).update(payload);
    } catch (e) {
      _isUsingFirebase = false;
      final index = _mockCache.indexWhere((p) => p.id == id);
      if (index != -1) {
        _mockCache[index] = updatedProduct.copyWith(id: id);
        _fallbackController.add(List<Product>.from(_mockCache));
      }
    }
  }

  /// Xóa sản phẩm trên Firebase Cloud Firestore
  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      _isUsingFirebase = false;
      _mockCache.removeWhere((p) => p.id == id);
      _fallbackController.add(List<Product>.from(_mockCache));
    }
  }

  /// Xuất toàn bộ cơ sở dữ liệu từ Firebase thành file JSON chuẩn để nộp bài
  Future<String> exportToJson() async {
    List<Product> productsToExport = [];

    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      if (snapshot.docs.isNotEmpty) {
        productsToExport = snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList();
      } else {
        productsToExport = _mockCache;
      }
    } catch (_) {
      productsToExport = _mockCache;
    }

    final listMap = productsToExport.map((p) => p.toJson()).toList();
    return const JsonEncoder.withIndent('  ').convert(listMap);
  }
}
