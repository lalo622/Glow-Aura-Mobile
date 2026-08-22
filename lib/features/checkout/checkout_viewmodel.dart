import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../cart/cart_viewmodel.dart';
import 'data/models/checkout_models.dart';
import 'services/checkout_service.dart';

enum PaymentMethod { cod, payOS }

extension PaymentMethodX on PaymentMethod {
  String get apiValue {
    switch (this) {
      case PaymentMethod.cod:
        return 'COD';
      case PaymentMethod.payOS:
        return 'PayOS';
    }
  }
}

// ─── State ────────────────────────────────────────────────────────────────────

class CheckoutState {
  final bool isLoadingPreview;
  final bool isSubmitting;
  final CheckoutPreviewResponse? preview;
  final PlaceOrderResponse? orderResult;
  final String? errorMessage;

  const CheckoutState({
    this.isLoadingPreview = false,
    this.isSubmitting = false,
    this.preview,
    this.orderResult,
    this.errorMessage,
  });

  CheckoutState copyWith({
    bool? isLoadingPreview,
    bool? isSubmitting,
    CheckoutPreviewResponse? preview,
    PlaceOrderResponse? orderResult,
    String? errorMessage,
    bool clearError = false,
    bool clearOrderResult = false,
  }) =>
      CheckoutState(
        isLoadingPreview: isLoadingPreview ?? this.isLoadingPreview,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        preview: preview ?? this.preview,
        orderResult: clearOrderResult ? null : (orderResult ?? this.orderResult),
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );
}

// ─── ViewModel ────────────────────────────────────────────────────────────────

class CheckoutViewModel extends StateNotifier<CheckoutState> {
  final CheckoutService _checkoutService;
  final Ref _ref;

  CheckoutViewModel(this._checkoutService, this._ref) : super(const CheckoutState());

  Future<void> refreshPreview({
    required List<CheckoutItemRequest> items,
    String? couponCode,
  }) async {
    if (items.isEmpty) return;
    state = state.copyWith(isLoadingPreview: true, clearError: true);

    final request = CheckoutPreviewRequest(
      items: items,
      couponCode: couponCode,
    );

    final result = await _checkoutService.previewCheckout(request);

    if (result.error != null) {
      state = state.copyWith(isLoadingPreview: false, errorMessage: result.error!.message);
      return;
    }

    final preview = result.data!;
    state = state.copyWith(
      isLoadingPreview: false,
      preview: preview,
      errorMessage: preview.isValid ? null : preview.errorMessage,
      clearError: preview.isValid,
    );
  }

  /// Đặt hàng.
  Future<bool> placeOrder({
    required String fullName,
    required String phoneNumber,
    String? email,
    required String shippingAddress,
    required PaymentMethod paymentMethod,
    String? couponCode,
    required List<CheckoutItemRequest> items,
    String? returnUrl,
    String? cancelUrl,
  }) async {
    if (state.isSubmitting) return false;

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearOrderResult: true,
    );

    try {
      final request = PlaceOrderRequest(
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod.apiValue,
        couponCode: couponCode,
        items: items,
        returnUrl: returnUrl,
        cancelUrl: cancelUrl,
      );

      final result = await _checkoutService.placeOrder(request);

      if (result.error != null) {
        state = state.copyWith(errorMessage: result.error!.message);
        return false;
      }

      final data = result.data!;
      if (!data.isSuccess) {
        state = state.copyWith(errorMessage: data.message);
        return false;
      }

      state = state.copyWith(orderResult: data);

      if (paymentMethod == PaymentMethod.cod) {
        await _ref.read(cartViewModelProvider.notifier).clearCart();
      }

      return true;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final checkoutViewModelProvider =
    StateNotifierProvider.autoDispose<CheckoutViewModel, CheckoutState>((ref) {
  return CheckoutViewModel(ref.watch(checkoutServiceProvider), ref);
});