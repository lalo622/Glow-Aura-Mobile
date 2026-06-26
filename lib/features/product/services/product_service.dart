import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/safe_call.dart';
import '../models/product_model.dart';

class ProductService {
  final Dio _dio = ApiClient.instance.dio;

  Future<SafeResult<ProductListResponse>> getProducts({
    ProductSearchParams? params,
  }) => safeCall(() async {
    final response = await _dio.get(
      ApiEndpoints.products,
      queryParameters: params?.toQueryParams(),
    );
    return ProductListResponse.fromDynamic(response.data);
  });

  Future<SafeResult<ProductResponse>> getProductById(String id) => safeCall(() async {
    final response = await _dio.get(ApiEndpoints.productById(id));
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('isSuccess')) {
      return ProductResponse.fromJson(data);
    }
    return ProductResponse(
      isSuccess: true,
      message: '',
      product: ProductModel.fromJson(data as Map<String, dynamic>),
    );
  });

  Future<SafeResult<ProductListResponse>> searchProducts(String keyword, {
    int page = 1,
    int pageSize = 20,
  }) => safeCall(() async {
    final response = await _dio.get(
      ApiEndpoints.productsSearch,
      queryParameters: {'keyword': keyword, 'page': page, 'pageSize': pageSize},
    );
    return ProductListResponse.fromDynamic(response.data);
  });

  Future<SafeResult<ProductListResponse>> advancedSearch(ProductSearchParams params) =>
    safeCall(() async {
      final response = await _dio.get(
        ApiEndpoints.productsAdvancedSearch,
        queryParameters: params.toQueryParams(),
      );
      return ProductListResponse.fromDynamic(response.data);
    });

  Future<SafeResult<ProductListResponse>> getByCategory(String category, {
    int page = 1, int pageSize = 20,
  }) => safeCall(() async {
    final response = await _dio.get(
      ApiEndpoints.productsByCategory(category),
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return ProductListResponse.fromDynamic(response.data);
  });

  Future<SafeResult<ProductListResponse>> getByBrand(String brand, {
    int page = 1, int pageSize = 20,
  }) => safeCall(() async {
    final response = await _dio.get(
      ApiEndpoints.productsByBrand(brand),
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return ProductListResponse.fromDynamic(response.data);
  });

  Future<SafeResult<ProductListResponse>> getBySkinType(String skinType, {
    int page = 1, int pageSize = 20,
  }) => safeCall(() async {
    final response = await _dio.get(
      ApiEndpoints.productsBySkinTypePaged(skinType),
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return ProductListResponse.fromDynamic(response.data);
  });

  Future<SafeResult<ProductListResponse>> getFlashSale() =>
    safeCall(() async {
      final response = await _dio.get(ApiEndpoints.productsFlashSale);
      return ProductListResponse.fromDynamic(response.data);
    });

  Future<SafeResult<StringListResponse>> getBrands() =>
    safeCall(() async {
      final response = await _dio.get(ApiEndpoints.productBrands);
      return StringListResponse.fromDynamic(response.data);
    });

  Future<SafeResult<StringListResponse>> getCategories() =>
    safeCall(() async {
      final response = await _dio.get(ApiEndpoints.productCategories);
      return StringListResponse.fromDynamic(response.data);
    });

  Future<SafeResult<ProductListResponse>> getByPriceRange({
    required double minPrice,
    required double maxPrice,
    int page = 1, int pageSize = 20,
  }) => safeCall(() async {
    final response = await _dio.get(
      ApiEndpoints.productsByPriceRange,
      queryParameters: {
        'minPrice': minPrice, 'maxPrice': maxPrice,
        'page': page, 'pageSize': pageSize,
      },
    );
    return ProductListResponse.fromJson(response.data);
  });
}