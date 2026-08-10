import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/network/safe_call.dart';
import '../data/models/checkout_models.dart';

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

  Future<SafeResult<OrderStatusResponse>> getOrderStatus(String orderId) {
    return safeCall(() async {
      final response = await _dio.get('/api/Order/$orderId');

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const AppException(
          type: AppErrorType.unknown,
          message: 'Phản hồi từ server không đúng định dạng.',
        );
      }

      return OrderStatusResponse.fromJson(data);
    });
  }
}

final checkoutServiceProvider = Provider<CheckoutService>((ref) {
  return CheckoutService(dio: ApiClient.instance.dio);
});