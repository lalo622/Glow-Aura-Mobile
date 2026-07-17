import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../product/models/product_model.dart';
import 'data/models/cart_item_model.dart';
import 'services/cart_service.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class CartState {
  final bool isLoading;
  final List<CartItemModel> items;
  final String? errorMessage;

  static const double shippingThreshold = 500000;
  static const double flatShippingFee = 30000;

  const CartState({
    this.isLoading = false,
    this.items = const [],
    this.errorMessage,
  });

  int get totalQuantity => items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => items.fold(0.0, (sum, i) => sum + i.lineTotal);

  bool get isFreeShipping => subtotal >= shippingThreshold;

  double get shippingFee => isFreeShipping ? 0 : flatShippingFee;

  bool get isEmpty => items.isEmpty;

  CartState copyWith({
    bool? isLoading,
    List<CartItemModel>? items,
    String? errorMessage,
    bool clearError = false,
  }) =>
      CartState(
        isLoading: isLoading ?? this.isLoading,
        items: items ?? this.items,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );
}

// ─── ViewModel ────────────────────────────────────────────────────────────────

class CartViewModel extends StateNotifier<CartState> {
  final CartService _cartService;

  CartViewModel(this._cartService) : super(const CartState()) {
    loadCart();
  }

  Future<void> loadCart() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _cartService.getCartItems();

    if (result.error != null) {
      state = state.copyWith(isLoading: false, errorMessage: result.error!.message);
      return;
    }
    state = state.copyWith(isLoading: false, items: result.data!);
  }

  /// Thêm sản phẩm vào giỏ, gọi từ ProductDetailScreen / ProductCard
  Future<bool> addToCart(ProductModel product, {int quantity = 1}) async {
    final item = CartItemModel.fromProduct(product, quantity: quantity);
    final result = await _cartService.addItem(item);

    if (result.error != null) {
      state = state.copyWith(errorMessage: result.error!.message);
      return false;
    }
    await loadCart();
    return true;
  }

  Future<void> increment(CartItemModel item) async {
    if (item.isMaxQuantity) return;
    await _updateQuantity(item.productId, item.quantity + 1);
  }

  Future<void> decrement(CartItemModel item) async {
    if (item.quantity <= 1) return;
    await _updateQuantity(item.productId, item.quantity - 1);
  }

  Future<void> _updateQuantity(String productId, int quantity) async {
    // update optimistic trước để UI mượt, rollback nếu lỗi
    final previousItems = state.items;
    state = state.copyWith(
      items: [
        for (final i in state.items)
          if (i.productId == productId) i.copyWith(quantity: quantity) else i,
      ],
    );

    final result = await _cartService.updateQuantity(productId, quantity);
    if (result.error != null) {
      state = state.copyWith(items: previousItems, errorMessage: result.error!.message);
    }
  }

  Future<void> removeItem(String productId) async {
    final previousItems = state.items;
    state = state.copyWith(
      items: state.items.where((i) => i.productId != productId).toList(),
    );

    final result = await _cartService.removeItem(productId);
    if (result.error != null) {
      state = state.copyWith(items: previousItems, errorMessage: result.error!.message);
    }
  }

  Future<void> clearCart() async {
    final result = await _cartService.clearCart();
    if (result.error == null) {
      state = state.copyWith(items: []);
    } else {
      state = state.copyWith(errorMessage: result.error!.message);
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

// ─── Providers ────────────────────────────────────────────────────────────────

final cartViewModelProvider = StateNotifierProvider<CartViewModel, CartState>((ref) {
  return CartViewModel(ref.watch(cartServiceProvider));
});

final cartTotalQuantityProvider = Provider<int>((ref) {
  return ref.watch(cartViewModelProvider).totalQuantity;
});