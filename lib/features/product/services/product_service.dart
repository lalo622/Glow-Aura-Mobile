import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/product_model.dart';

class ProductService {
  final Dio _dio = ApiClient.instance.dio;

  // ─── Danh sách sản phẩm (có phân trang + filter) ─────────────────────────
  Future<ProductListResponse> getProducts({
    ProductSearchParams? params,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.products,
      queryParameters: params?.toQueryParams(),
    );
    return ProductListResponse.fromDynamic(response.data);
  }

  // ─── Chi tiết sản phẩm ────────────────────────────────────────────────────
  Future<ProductResponse> getProductById(String id) async {
    final response = await _dio.get(ApiEndpoints.productById(id));
    // BE có thể trả Map hoặc object trực tiếp
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('isSuccess')) {
      return ProductResponse.fromJson(data);
    }
    return ProductResponse(
      isSuccess: true,
      message: '',
      product: ProductModel.fromJson(data as Map<String, dynamic>),
    );
  }

  // ─── Tìm kiếm ─────────────────────────────────────────────────────────────
  Future<ProductListResponse> searchProducts(String keyword, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.productsSearch,
      queryParameters: {
        'keyword': keyword,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return ProductListResponse.fromDynamic(response.data);
  }

  // ─── Tìm kiếm nâng cao ────────────────────────────────────────────────────
  Future<ProductListResponse> advancedSearch(ProductSearchParams params) async {
    final response = await _dio.get(
      ApiEndpoints.productsAdvancedSearch,
      queryParameters: params.toQueryParams(),
    );
    return ProductListResponse.fromDynamic(response.data);
  }

  // ─── Theo danh mục ────────────────────────────────────────────────────────
  Future<ProductListResponse> getByCategory(String category, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.productsByCategory(category),
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return ProductListResponse.fromDynamic(response.data);
  }

  // ─── Theo thương hiệu ─────────────────────────────────────────────────────
  Future<ProductListResponse> getByBrand(String brand, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.productsByBrand(brand),
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return ProductListResponse.fromDynamic(response.data);
  }

  // ─── Theo loại da ─────────────────────────────────────────────────────────
  Future<ProductListResponse> getBySkinType(String skinType, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.productsBySkinTypePaged(skinType),
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return ProductListResponse.fromDynamic(response.data);
  }

  // ─── Flash sale ───────────────────────────────────────────────────────────
  Future<ProductListResponse> getFlashSale() async {
    final response = await _dio.get(ApiEndpoints.productsFlashSale);
    return ProductListResponse.fromDynamic(response.data);
  }

  // ─── Lấy danh sách brands ─────────────────────────────────────────────────
  Future<StringListResponse> getBrands() async {
    final response = await _dio.get(ApiEndpoints.productBrands);
    return StringListResponse.fromDynamic(response.data);
  }

  // ─── Lấy danh sách categories ─────────────────────────────────────────────
  Future<StringListResponse> getCategories() async {
    final response = await _dio.get(ApiEndpoints.productCategories);
    return StringListResponse.fromDynamic(response.data);
  }

  // ─── Lọc theo giá ─────────────────────────────────────────────────────────
  Future<ProductListResponse> getByPriceRange({
    required double minPrice,
    required double maxPrice,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.productsByPriceRange,
      queryParameters: {
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return ProductListResponse.fromJson(response.data);
  }
}