class ApiEndpoints {
  static const String baseUrl =
      'https://glowauraapimongodb-production.up.railway.app';

  // ─── Auth ────────────────────────────────────────────────────
  static const String register = '/api/Auth/register';
  static const String login = '/api/Auth/login';
  static const String refreshToken = '/api/Auth/refresh-token';
  static const String logout = '/api/Auth/logout';
  static const String changePassword = '/api/Auth/change-password';

  // ─── Checkout ────────────────────────────────────────────────
  static const String checkoutPreview = '/api/Checkout/preview';
  static const String checkout = '/api/Checkout';

  // ─── Order ───────────────────────────────────────────────────
  static const String orders = '/api/Order';
  static const String myOrders = '/api/Order/my-orders';
  static const String orderStats = '/api/Order/stats';
  static const String pendingOrders = '/api/Order/pending';
  static String orderById(String id) => '/api/Order/$id';
  static String cancelOrder(String id) => '/api/Order/$id/cancel';
  static String payOrder(String id) => '/api/Order/$id/pay';
  static String confirmOrder(String id) => '/api/Order/$id/confirm';
  static String orderStatus(String id) => '/api/Order/$id/status';
  static String orderByNumber(String orderNumber) =>
      '/api/Order/by-number/$orderNumber';

  // ─── Products ────────────────────────────────────────────────
  static const String products = '/api/Products';
  static const String productsStats = '/api/Products/stats';
  static const String productsExpiringSoon = '/api/Products/expiring-soon';
  static const String productsExpired = '/api/Products/expired';
  static const String productsFlashSale = '/api/Products/flash-sale';
  static const String productBrands = '/api/Products/brands';
  static const String productCategories = '/api/Products/categories';
  static const String productsByPriceRange = '/api/Products/price-range';
  static const String productsLowStock = '/api/Products/low-stock';
  static const String productsOutOfStock = '/api/Products/out-of-stock';
  static const String productsSearch = '/api/Products/search';
  static const String productsAdvancedSearch = '/api/Products/advanced-search';

  static String productById(String id) => '/api/Products/$id';
  static String productStock(String id) => '/api/Products/$id/stock';
  static String productImage(String id) => '/api/Products/$id/image';
  static String productImageFromUrl(String id) =>
      '/api/Products/$id/image/from-url';
  static String productFlashSale(String id) => '/api/Products/$id/flash-sale';
  static String productsBySkinType(String skinType) =>
      '/api/Products/skin-type/$skinType';
  static String productsBySkinTypePaged(String skinType) =>
      '/api/Products/skin-type/$skinType/paged';
  static String productsByBrand(String brand) => '/api/Products/brand/$brand';
  static String productsByCategory(String category) =>
      '/api/Products/category/$category';

  // ─── SkinQuiz ────────────────────────────────────────────────
  static const String skinQuizQuestions = '/api/SkinQuiz/questions';
  static const String skinQuizAnalyze = '/api/SkinQuiz/analyze';
  static const String skinTypes = '/api/SkinQuiz/skin-types';
  static String skinTypeDetail(String skinType) =>
      '/api/SkinQuiz/skin-types/$skinType';
  static String skinQuizRecommendations(String skinType) =>
      '/api/SkinQuiz/recommendations/$skinType';
  static String skinQuizStatus(String userId) =>
      '/api/SkinQuiz/status/$userId';

  // ─── User ────────────────────────────────────────────────────
  static const String myProfile = '/api/User/me';
  static const String myLoyalty = '/api/User/me/loyalty';
  static const String users = '/api/User';
  static const String userStats = '/api/User/stats';
  static String userById(String id) => '/api/User/$id';
  static String userRole(String id) => '/api/User/$id/role';
  static String userStatus(String id) => '/api/User/$id/status';

  // ─── Skin Analysis ────────────────────────────────────────────────────
  static const String skinAnalysisAnalyze = '/api/skin-analysis/analyze';
  static const String skinAnalysisHistory = '/api/skin-analysis/history';
  static String skinAnalysisDetail(String analysisCode) =>
      '/api/skin-analysis/$analysisCode';
 

}