// ─── Product Model ────────────────────────────────────────────────────────────

class ProductModel {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String? skinType;
  final String? description;
  final double price;
  final double? discountedPrice;
  final String? imageUrl;
  final int stockQuantity;
  final bool isFlashSale;
  final double? flashSaleDiscount;
  final DateTime? flashSaleEnd;
  final DateTime? expiryDate;
  final DateTime createdAt;
  // Fields thêm từ BE
  final int? daysUntilExpiry;
  final bool isExpiringSoon;
  final String? ingredients;
  final String? usageInstructions;
  final String? volume;

  const ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.price,
    required this.stockQuantity,
    required this.isFlashSale,
    required this.createdAt,
    this.skinType,
    this.description,
    this.discountedPrice,
    this.imageUrl,
    this.flashSaleDiscount,
    this.flashSaleEnd,
    this.expiryDate,
    this.daysUntilExpiry,
    this.isExpiringSoon = false,
    this.ingredients,
    this.usageInstructions,
    this.volume,
  });

  bool get hasDiscount => discountedPrice != null && discountedPrice! < price;

  double get displayPrice => discountedPrice ?? price;

  int get discountPercent => hasDiscount
      ? (((price - discountedPrice!) / price) * 100).toInt()
      : 0;

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        brand: json['brand'] as String? ?? '',
        category: json['category'] as String? ?? '',
        skinType: json['skinType'] as String?,
        description: json['description'] as String?,
        price: (json['price'] as num?)?.toDouble() ?? 0,
        discountedPrice: json['discountedPrice'] != null
            ? (json['discountedPrice'] as num).toDouble()
            : null,
        imageUrl: json['imageUrl'] as String?,
        // BE trả về 'stock' không phải 'stockQuantity'
        stockQuantity: (json['stock'] as num?)?.toInt() ??
            (json['stockQuantity'] as num?)?.toInt() ?? 0,
        isFlashSale: json['isFlashSale'] as bool? ?? false,
        flashSaleDiscount: json['flashSaleDiscount'] != null
            ? (json['flashSaleDiscount'] as num).toDouble()
            : null,
        // BE dùng 'flashSaleEndTime' không phải 'flashSaleEnd'
        flashSaleEnd: (json['flashSaleEndTime'] ?? json['flashSaleEnd']) != null
            ? DateTime.tryParse(
                (json['flashSaleEndTime'] ?? json['flashSaleEnd']) as String)
            : null,
        expiryDate: json['expiryDate'] != null
            ? DateTime.tryParse(json['expiryDate'] as String)
            : null,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        daysUntilExpiry: (json['daysUntilExpiry'] as num?)?.toInt(),
        isExpiringSoon: json['isExpiringSoon'] as bool? ?? false,
        ingredients: json['ingredients'] as String?,
        usageInstructions: json['usageInstructions'] as String?,
        volume: json['volume'] as String?,
      );
}

// ─── Pagination ───────────────────────────────────────────────────────────────

class PaginationMeta {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;

  const PaginationMeta({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
  });

  bool get hasNextPage => currentPage < totalPages;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => PaginationMeta(
        currentPage: (json['currentPage'] as num).toInt(),
        totalPages: (json['totalPages'] as num).toInt(),
        totalItems: (json['totalItems'] as num).toInt(),
        pageSize: (json['pageSize'] as num).toInt(),
      );
}

// ─── Response Wrappers ────────────────────────────────────────────────────────

/// Single product response — dùng cho GET /api/Products/{id}
class ProductResponse {
  final bool isSuccess;
  final String message;
  final ProductModel? product;

  const ProductResponse({
    required this.isSuccess,
    required this.message,
    this.product,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) =>
      ProductResponse(
        isSuccess: json['isSuccess'] as bool,
        message: json['message'] as String,
        product: json['data'] != null
            ? ProductModel.fromJson(json['data'] as Map<String, dynamic>)
            : null,
      );
}

/// List product response — dùng cho GET /api/Products, /search, /category, ...
class ProductListResponse {
  final bool isSuccess;
  final String message;
  final List<ProductModel> products;
  final PaginationMeta? pagination;

  const ProductListResponse({
    required this.isSuccess,
    required this.message,
    required this.products,
    this.pagination,
  });

  /// Handle 3 kiểu response BE có thể trả về:
  /// 1. Raw List: [ {...}, {...} ]
  /// 2. Wrapper: { isSuccess, message, data: [ {...} ] }
  /// 3. Wrapper: { isSuccess, message, data: { items: [...], pagination: {...} } }
  static ProductListResponse fromDynamic(dynamic raw) {
    // Trường hợp 1: BE trả thẳng List
    if (raw is List) {
      return ProductListResponse(
        isSuccess: true,
        message: '',
        products: raw
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }

    // Trường hợp 2 & 3: BE trả wrapper object
    if (raw is Map<String, dynamic>) {
      return ProductListResponse.fromJson(raw);
    }

    return const ProductListResponse(
      isSuccess: false,
      message: 'Định dạng response không hợp lệ',
      products: [],
    );
  }

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    List<ProductModel> items = [];
    PaginationMeta? meta;

    if (data is List) {
      items = data
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (data is Map<String, dynamic>) {
      final itemsRaw = data['items'] as List?;
      if (itemsRaw != null) {
        items = itemsRaw
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (data['pagination'] != null) {
        meta = PaginationMeta.fromJson(
            data['pagination'] as Map<String, dynamic>);
      }
    }

    return ProductListResponse(
      isSuccess: json['isSuccess'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      products: items,
      pagination: meta,
    );
  }
}

/// String list response — dùng cho /brands, /categories
class StringListResponse {
  final bool isSuccess;
  final String message;
  final List<String> data;

  const StringListResponse({
    required this.isSuccess,
    required this.message,
    required this.data,
  });

  static StringListResponse fromDynamic(dynamic raw) {
    if (raw is List) {
      return StringListResponse(
        isSuccess: true,
        message: '',
        data: raw.map((e) => e.toString()).toList(),
      );
    }
    if (raw is Map<String, dynamic>) {
      return StringListResponse.fromJson(raw);
    }
    return const StringListResponse(isSuccess: false, message: '', data: []);
  }

  factory StringListResponse.fromJson(Map<String, dynamic> json) =>
      StringListResponse(
        isSuccess: json['isSuccess'] as bool? ?? true,
        message: json['message'] as String? ?? '',
        data: (json['data'] as List?)?.map((e) => e.toString()).toList() ?? [],
      );
}

// ─── Search Request ───────────────────────────────────────────────────────────

class ProductSearchParams {
  final String? keyword;
  final String? category;
  final String? brand;
  final String? skinType;
  final double? minPrice;
  final double? maxPrice;
  final String? sortBy; // 'price_asc' | 'price_desc' | 'newest'
  final int page;
  final int pageSize;

  const ProductSearchParams({
    this.keyword,
    this.category,
    this.brand,
    this.skinType,
    this.minPrice,
    this.maxPrice,
    this.sortBy,
    this.page = 1,
    this.pageSize = 20,
  });

  Map<String, dynamic> toQueryParams() => {
        if (keyword != null && keyword!.isNotEmpty) 'keyword': keyword,
        if (category != null) 'category': category,
        if (brand != null) 'brand': brand,
        if (skinType != null) 'skinType': skinType,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (sortBy != null) 'sortBy': sortBy,
        'page': page,
        'pageSize': pageSize,
      };
}