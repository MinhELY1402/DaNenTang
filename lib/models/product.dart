/// Model Product đại diện cho một sản phẩm trong hệ thống Admin.
/// CHÚ Ý RÀNG BUỘC ĐỀ BÀI: Chỉ chấp nhận đúng 4 trường trong cơ sở dữ liệu:
/// 1. [name]    : Tên sản phẩm
/// 2. [price]   : Giá sản phẩm
/// 3. [soluong] : Số lượng sản phẩm
/// 4. [image]   : Link URL hoặc chuỗi hình ảnh của sản phẩm
///
/// Thuộc tính [id] là Document ID của Firebase Firestore, KHÔNG được ghi vào
/// payload dữ liệu của sản phẩm để đảm bảo CSDL chỉ chứa đúng 4 trường.
class Product {
  final String? id; // Document ID trên Firebase Firestore
  final String name;
  final double price;
  final int soluong;
  final String image;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.soluong,
    required this.image,
  });

  /// Chuyển đổi từ Firestore Document Snapshot hoặc JSON Map
  factory Product.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return Product(
      id: documentId,
      name: map['name']?.toString() ?? '',
      price: (map['price'] is num)
          ? (map['price'] as num).toDouble()
          : double.tryParse(map['price']?.toString() ?? '0') ?? 0.0,
      soluong: (map['soluong'] is num)
          ? (map['soluong'] as num).toInt()
          : int.tryParse(map['soluong']?.toString() ?? '0') ?? 0,
      image: map['image']?.toString() ?? '',
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) => Product.fromMap(json);

  /// Chuyển đổi đối tượng Product sang JSON Map
  /// RÀNG BUỘC TUYỆT ĐỐI: CHỈ gồm đúng 4 trường: name, price, soluong, image.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'soluong': soluong,
      'image': image,
    };
  }

  /// Tạo bản sao có cập nhật trường
  Product copyWith({
    String? id,
    String? name,
    double? price,
    int? soluong,
    String? image,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      soluong: soluong ?? this.soluong,
      image: image ?? this.image,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          price == other.price &&
          soluong == other.soluong &&
          image == other.image;

  @override
  int get hashCode =>
      name.hashCode ^ price.hashCode ^ soluong.hashCode ^ image.hashCode;
}
