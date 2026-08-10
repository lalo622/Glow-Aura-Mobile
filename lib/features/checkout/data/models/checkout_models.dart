class CheckoutItemRequest {
  final String productId;
  final int quantity;

  const CheckoutItemRequest({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity,
      };
}

/// Body cho POST /api/Checkout/preview
/// flat 30k / miễn phí từ 500k, không dựa vào phương thức vận chuyển nữa.
class CheckoutPreviewRequest {
  final List<CheckoutItemRequest> items;
  final String? couponCode;

  const CheckoutPreviewRequest({
    required this.items,
    this.couponCode,
  });

  Map<String, dynamic> toJson() => {
        'items': items.map((i) => i.toJson()).toList(),
        if (couponCode != null && couponCode!.isNotEmpty) 'couponCode': couponCode,
      };
}

/// Body cho POST /api/Checkout
class PlaceOrderRequest {
  final String fullName;
  final String phoneNumber;
  final String? email;
  final String shippingAddress;
  final String paymentMethod;
  final String? couponCode;
  final List<CheckoutItemRequest> items;
  final String? returnUrl;
  final String? cancelUrl;

  const PlaceOrderRequest({
    required this.fullName,
    required this.phoneNumber,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.items,
    this.email,
    this.couponCode,
    this.returnUrl,
    this.cancelUrl,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        if (email != null && email!.isNotEmpty) 'email': email,
        'shippingAddress': shippingAddress,
        'paymentMethod': paymentMethod,
        if (couponCode != null && couponCode!.isNotEmpty) 'couponCode': couponCode,
        'items': items.map((i) => i.toJson()).toList(),
        if (returnUrl != null) 'returnUrl': returnUrl,
        if (cancelUrl != null) 'cancelUrl': cancelUrl,
      };
}

// ─── Response models ──

class CheckoutItemDetail {
  final String productId;
  final String productName;
  final int quantity;
  final double originalPrice;
  final double finalPrice;
  final double totalPrice;
  final List<String> appliedDiscounts;

  const CheckoutItemDetail({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.originalPrice,
    required this.finalPrice,
    required this.totalPrice,
    required this.appliedDiscounts,
  });

  factory CheckoutItemDetail.fromJson(Map<String, dynamic> json) => CheckoutItemDetail(
        productId: json['productId'] as String,
        productName: json['productName'] as String,
        quantity: json['quantity'] as int,
        originalPrice: (json['originalPrice'] as num).toDouble(),
        finalPrice: (json['finalPrice'] as num).toDouble(),
        totalPrice: (json['totalPrice'] as num).toDouble(),
        appliedDiscounts: (json['appliedDiscounts'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
      );
}

class CheckoutPreviewResponse {
  final bool isValid;
  final String? errorMessage;
  final double subTotal;
  final double shippingFee;
  final double totalDiscount;
  final double totalAmount;
  final List<CheckoutItemDetail> itemDetails;
  final List<String> warnings;

  const CheckoutPreviewResponse({
    required this.isValid,
    required this.subTotal,
    required this.shippingFee,
    required this.totalDiscount,
    required this.totalAmount,
    required this.itemDetails,
    required this.warnings,
    this.errorMessage,
  });

  factory CheckoutPreviewResponse.fromJson(Map<String, dynamic> json) => CheckoutPreviewResponse(
        isValid: json['isValid'] as bool,
        errorMessage: json['errorMessage'] as String?,
        subTotal: (json['subTotal'] as num).toDouble(),
        shippingFee: (json['shippingFee'] as num).toDouble(),
        totalDiscount: (json['totalDiscount'] as num).toDouble(),
        totalAmount: (json['totalAmount'] as num).toDouble(),
        itemDetails: (json['itemDetails'] as List<dynamic>? ?? [])
            .map((e) => CheckoutItemDetail.fromJson(e as Map<String, dynamic>))
            .toList(),
        warnings: (json['warnings'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      );
}

class PlaceOrderResponse {
  final bool isSuccess;
  final String message;
  final String? orderId;
  final String? orderNumber;
  final double totalAmount;
  final String? paymentUrl;
  final String? transactionId;
  final List<CheckoutItemDetail> itemDetails;

  const PlaceOrderResponse({
    required this.isSuccess,
    required this.message,
    required this.totalAmount,
    required this.itemDetails,
    this.orderId,
    this.orderNumber,
    this.paymentUrl,
    this.transactionId,
  });

  factory PlaceOrderResponse.fromJson(Map<String, dynamic> json) => PlaceOrderResponse(
        isSuccess: json['isSuccess'] as bool,
        message: json['message'] as String? ?? '',
        orderId: json['orderId'] as String?,
        orderNumber: json['orderNumber'] as String?,
        totalAmount: (json['totalAmount'] as num).toDouble(),
        paymentUrl: json['paymentUrl'] as String?,
        transactionId: json['transactionId'] as String?,
        itemDetails: (json['itemDetails'] as List<dynamic>? ?? [])
            .map((e) => CheckoutItemDetail.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class OrderStatusResponse {
  final String status;

  const OrderStatusResponse({required this.status});

  factory OrderStatusResponse.fromJson(Map<String, dynamic> json) =>
      OrderStatusResponse(status: json['status'] as String? ?? '');
}