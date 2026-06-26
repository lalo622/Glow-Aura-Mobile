import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/product_model.dart';
import 'services/product_service.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class ProductState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<ProductModel> products;
  final ProductModel? selectedProduct;
  final List<String> categories;
  final List<String> brands;
  final String? errorMessage;

  // Filter state
  final String selectedCategory;
  final String searchQuery;
  final String sortOption; // 'all' | 'priceAsc' | 'priceDesc' | 'newest'

  // Pagination
  final int currentPage;
  final bool hasNextPage;

  const ProductState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.products = const [],
    this.selectedProduct,
    this.categories = const [],
    this.brands = const [],
    this.errorMessage,
    this.selectedCategory = 'Tất cả',
    this.searchQuery = '',
    this.sortOption = 'all',
    this.currentPage = 1,
    this.hasNextPage = false,
  });

  ProductState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<ProductModel>? products,
    ProductModel? selectedProduct,
    List<String>? categories,
    List<String>? brands,
    String? errorMessage,
    String? selectedCategory,
    String? searchQuery,
    String? sortOption,
    int? currentPage,
    bool? hasNextPage,
    bool clearError = false,
    bool clearSelected = false,
  }) =>
      ProductState(
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        products: products ?? this.products,
        selectedProduct:
            clearSelected ? null : selectedProduct ?? this.selectedProduct,
        categories: categories ?? this.categories,
        brands: brands ?? this.brands,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
        selectedCategory: selectedCategory ?? this.selectedCategory,
        searchQuery: searchQuery ?? this.searchQuery,
        sortOption: sortOption ?? this.sortOption,
        currentPage: currentPage ?? this.currentPage,
        hasNextPage: hasNextPage ?? this.hasNextPage,
      );
}

// ─── ViewModel ────────────────────────────────────────────────────────────────

class ProductViewModel extends StateNotifier<ProductState> {
  final ProductService _productService;

  ProductViewModel(this._productService) : super(const ProductState());

  Future<void> init() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.wait([
      _fetchProducts(reset: true),
      _fetchCategories(),
    ]);
  }

  Future<void> _fetchProducts({bool reset = false}) async {
    final page = reset ? 1 : state.currentPage + 1;

    final sortBy = switch (state.sortOption) {
      'priceAsc'  => 'price_asc',
      'priceDesc' => 'price_desc',
      'newest'    => 'newest',
      _           => null,
    };

    final params = ProductSearchParams(
      keyword: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      category: state.selectedCategory != 'Tất cả' ? state.selectedCategory : null,
      sortBy: sortBy,
      page: page,
      pageSize: 20,
    );

    final result = state.searchQuery.isNotEmpty
        ? await _productService.searchProducts(state.searchQuery, page: page)
        : await _productService.getProducts(params: params);

    if (result.error != null) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: result.error!.message, 
      );
      return;
    }

    final data = result.data!;
    if (data.isSuccess) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        products: reset ? data.products : [...state.products, ...data.products],
        currentPage: page,
        hasNextPage: data.pagination?.hasNextPage ?? false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: data.message,
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasNextPage) return;
    state = state.copyWith(isLoadingMore: true);
    await _fetchProducts(reset: false); 
  }

  Future<void> loadProductDetail(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _productService.getProductById(id);

    if (result.error != null) {
      state = state.copyWith(isLoading: false, errorMessage: result.error!.message);
      return;
    }

    final data = result.data!;
    if (data.isSuccess && data.product != null) {
      state = state.copyWith(isLoading: false, selectedProduct: data.product);
    } else {
      state = state.copyWith(isLoading: false, errorMessage: data.message);
    }
  }

  Future<void> _fetchCategories() async {
    final result = await _productService.getCategories();
    if (result.error == null && result.data!.isSuccess) {
      state = state.copyWith(categories: ['Tất cả', ...result.data!.data]);
    }
  }

  Future<void> selectCategory(String category) async {
    if (state.selectedCategory == category) return;
    state = state.copyWith(selectedCategory: category, isLoading: true, clearError: true);
    await _fetchProducts(reset: true);
  }

  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query, isLoading: true, clearError: true);
    await _fetchProducts(reset: true);
  }

  Future<void> setSortOption(String option) async {
    if (state.sortOption == option) return;
    state = state.copyWith(sortOption: option, isLoading: true, clearError: true);
    await _fetchProducts(reset: true);
  }

  Future<void> resetFilters() async {
    state = state.copyWith(
      selectedCategory: 'Tất cả',
      searchQuery: '',
      sortOption: 'all',
      isLoading: true,
      clearError: true,
    );
    await _fetchProducts(reset: true);
  }

  void clearError() => state = state.copyWith(clearError: true);
}

// ─── Providers ────────────────────────────────────────────────────────────────

final productServiceProvider =
    Provider<ProductService>((ref) => ProductService());

final productViewModelProvider =
    StateNotifierProvider<ProductViewModel, ProductState>((ref) {
  return ProductViewModel(ref.watch(productServiceProvider));
});

// Convenience providers
final productListProvider = Provider<List<ProductModel>>((ref) {
  return ref.watch(productViewModelProvider).products;
});

final productLoadingProvider = Provider<bool>((ref) {
  return ref.watch(productViewModelProvider).isLoading;
});

final productErrorProvider = Provider<String?>((ref) {
  return ref.watch(productViewModelProvider).errorMessage;
});

final selectedProductProvider = Provider<ProductModel?>((ref) {
  return ref.watch(productViewModelProvider).selectedProduct;
});