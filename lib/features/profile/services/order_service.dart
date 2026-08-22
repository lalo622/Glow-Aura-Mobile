import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/safe_call.dart';
import '../models/order_model.dart';

class OrderService {
  final Dio _dio = ApiClient.instance.dio;

  Future<SafeResult<List<OrderModel>>> getMyOrders() => safeCall(() async {
        final response = await _dio.get(ApiEndpoints.myOrders);
        final data = response.data;

        if (data is List) {
          return data
              .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        if (data is Map<String, dynamic> && data['data'] is List) {
          return (data['data'] as List)
              .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return <OrderModel>[];
      });
}

final orderServiceProvider = Provider<OrderService>((ref) => OrderService());

final myOrdersProvider =
    FutureProvider.autoDispose<List<OrderModel>>((ref) async {
  final result = await ref.watch(orderServiceProvider).getMyOrders();
  if (result.error != null) throw result.error!;
  return result.data!;
});