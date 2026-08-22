import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/safe_call.dart';
import '../data/models/checkout_models.dart';
import '../../../core/network/api_endpoints.dart';

class CheckoutService {
  final Dio _dio;
    CheckoutService({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;


  /// POST /api/Checkout/preview
  Future<SafeResult<CheckoutPreviewResponse>> previewCheckout(
    CheckoutPreviewRequest request,
  ) {
    return safeCall(() async {
      final response = await _dio.post(
        '/api/Checkout/preview',
        data: request.toJson(),
      );
      return CheckoutPreviewResponse.fromJson(response.data as Map<String, dynamic>);
    });
  }

  /// POST /api/Checkout
  Future<SafeResult<PlaceOrderResponse>> placeOrder(
    PlaceOrderRequest request,
  ) {
    return safeCall(() async {
      final response = await _dio.post(
        '/api/Checkout',
        data: request.toJson(),
      );
      return PlaceOrderResponse.fromJson(response.data as Map<String, dynamic>);
    });
  }
    Future<SafeResult<ConfirmPayOsReturnResponse>> confirmPayosReturn({
    required String orderId,
    int? orderCode,
  }) {
    return safeCall(() async {
      final response = await _dio.post(
        ApiEndpoints.payosConfirmReturn,
        data: {
          'orderId': orderId,
          if (orderCode != null) 'orderCode': orderCode,
        },
      );

      return ConfirmPayOsReturnResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    });
  }
}


final checkoutServiceProvider = Provider<CheckoutService>((ref) {
  return CheckoutService(dio: ApiClient.instance.dio);
});