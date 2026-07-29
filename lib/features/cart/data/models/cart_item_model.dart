import '../../../product/data/models/product_model.dart';


class CartItemModel {
  final String productId;
  final String brand;
  final String name;
  final String? volume;
  final String? imageUrl;
  final double price; 
  final double? originalPrice; 
  final int stockQuantity; 
  final int quantity;
  final DateTime addedAt;

  const CartItemModel({
    required this.productId,
    required this.brand,
    required this.name,
    required this.price,
    required this.stockQuantity,
    required this.quantity,
    required this.addedAt,
    this.volume,
    this.imageUrl,
    this.originalPrice,
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  double get lineTotal => price * quantity;

  bool get isMaxQuantity => quantity >= stockQuantity;

  CartItemModel copyWith({
    int? quantity,
    int? stockQuantity,
  }) =>
      CartItemModel(
        productId: productId,
        brand: brand,
        name: name,
        volume: volume,
        imageUrl: imageUrl,
        price: price,
        originalPrice: originalPrice,
        stockQuantity: stockQuantity ?? this.stockQuantity,
        quantity: quantity ?? this.quantity,
        addedAt: addedAt,
      );

  /// Tạo CartItemModel từ ProductModel 
  factory CartItemModel.fromProduct(ProductModel product, {int quantity = 1}) =>
      CartItemModel(
        productId: product.id,
        brand: product.brand,
        name: product.name,
        volume: product.volume,
        imageUrl: product.imageUrl,
        price: product.displayPrice,
        originalPrice: product.hasDiscount ? product.price : null,
        stockQuantity: product.stockQuantity,
        quantity: quantity,
        addedAt: DateTime.now(),
      );

  factory CartItemModel.fromMap(Map<String, dynamic> map) => CartItemModel(
        productId: map['productId'] as String,
        brand: map['brand'] as String,
        name: map['name'] as String,
        volume: map['volume'] as String?,
        imageUrl: map['imageUrl'] as String?,
        price: (map['price'] as num).toDouble(),
        originalPrice: map['originalPrice'] != null
            ? (map['originalPrice'] as num).toDouble()
            : null,
        stockQuantity: map['stockQuantity'] as int,
        quantity: map['quantity'] as int,
        addedAt: DateTime.parse(map['addedAt'] as String),
      );

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'brand': brand,
        'name': name,
        'volume': volume,
        'imageUrl': imageUrl,
        'price': price,
        'originalPrice': originalPrice,
        'stockQuantity': stockQuantity,
        'quantity': quantity,
        'addedAt': addedAt.toIso8601String(),
      };
}