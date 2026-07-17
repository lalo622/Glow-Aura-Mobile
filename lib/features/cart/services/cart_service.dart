import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/safe_call.dart';
import '../data/cart_database.dart';
import '../data/models/cart_item_model.dart';

class CartService {
  final CartDatabase _db;

  CartService(this._db);

  Future<SafeResult<List<CartItemModel>>> getCartItems() => safeCall(() async {
        final rows = await _db.getAllItems();
        return rows.map(_toModel).toList();
      });

  Future<SafeResult<void>> addItem(CartItemModel item) => safeCall(() async {
        await _db.addOrUpdateItem(
          productId: item.productId,
          brand: item.brand,
          name: item.name,
          volume: item.volume,
          imageUrl: item.imageUrl,
          price: item.price,
          originalPrice: item.originalPrice,
          stockQuantity: item.stockQuantity,
          quantity: item.quantity,
        );
      });

  Future<SafeResult<void>> updateQuantity(String productId, int quantity) =>
      safeCall(() => _db.updateQuantity(productId, quantity));

  Future<SafeResult<void>> removeItem(String productId) =>
      safeCall(() => _db.removeItem(productId));

  Future<SafeResult<void>> clearCart() => safeCall(() => _db.clearCart());

  CartItemModel _toModel(CartItem row) => CartItemModel(
        productId: row.productId,
        brand: row.brand,
        name: row.name,
        volume: row.volume,
        imageUrl: row.imageUrl,
        price: row.price,
        originalPrice: row.originalPrice,
        stockQuantity: row.stockQuantity,
        quantity: row.quantity,
        addedAt: row.addedAt,
      );
}

final cartServiceProvider = Provider<CartService>((ref) {
  return CartService(ref.watch(cartDatabaseProvider));
});