import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/safe_call.dart';
import '../data/models/address_models.dart';

class AddressService {
  final Dio _dio = ApiClient.instance.dio;

  Future<SafeResult<List<Province>>> getProvinces() {
    return safeCall(() async {
      final res = await _dio.get(ApiEndpoints.provinces);
      return _parseList(res.data).map((e) => Province.fromJson(e)).toList();
    });
  }

  Future<SafeResult<List<Ward>>> getWards(String provinceCode) {
    return safeCall(() async {
      final res = await _dio.get(ApiEndpoints.wards(provinceCode));
      return _parseList(res.data).map((e) => Ward.fromJson(e)).toList();
    });
  }

  List<Map<String, dynamic>> _parseList(dynamic data) {
    final raw = data is List ? data : (data is Map ? data['data'] : null);
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().toList();
  }
}