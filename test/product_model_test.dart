import 'package:flutter_test/flutter_test.dart';
import 'package:admin_product_manager/models/product.dart';

void main() {
  group('Product Model Tests - Kiểm tra ràng buộc CSDL', () {
    test('Product.fromJson khởi tạo chính xác từ Map', () {
      final json = {
        'name': 'Laptop Dell XPS 13',
        'price': 25000000.0,
        'soluong': 10,
        'image': 'https://example.com/dell.jpg',
      };

      final product = Product.fromJson(json);

      expect(product.name, 'Laptop Dell XPS 13');
      expect(product.price, 25000000.0);
      expect(product.soluong, 10);
      expect(product.image, 'https://example.com/dell.jpg');
    });

    test('Product.toJson chỉ chứa đúng 4 trường bắt buộc (name, price, soluong, image)', () {
      final product = Product(
        name: 'Bàn phím cơ',
        price: 1500000,
        soluong: 25,
        image: 'https://example.com/keyboard.jpg',
      );

      final json = product.toJson();

      // Ràng buộc số lượng key đúng bằng 4
      expect(json.keys.length, 4);
      expect(json.containsKey('name'), isTrue);
      expect(json.containsKey('price'), isTrue);
      expect(json.containsKey('soluong'), isTrue);
      expect(json.containsKey('image'), isTrue);

      // Đảm bảo không tồn tại bất kỳ trường nào khác
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('created_at'), isFalse);
      expect(json.containsKey('description'), isFalse);
    });

    test('Product.fromJson xử lý an toàn các kiểu dữ liệu dạng chuỗi ép kiểu', () {
      final jsonStringTypes = {
        'name': 'Chuột không dây',
        'price': '350000',
        'soluong': '50',
        'image': 'https://example.com/mouse.jpg',
      };

      final product = Product.fromJson(jsonStringTypes);

      expect(product.name, 'Chuột không dây');
      expect(product.price, 350000.0);
      expect(product.soluong, 50);
      expect(product.image, 'https://example.com/mouse.jpg');
    });
  });
}
