import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:glow_aura/shared/widgets/main_scaffold.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _selectedCategory = 'Tất cả';
  String _sortOption = 'all';
  String _searchQuery = '';
  bool _showFilter = false;
  final _searchController = TextEditingController();

  static const _mockProducts = [
    _ProductData(
      id: '1',
      name: 'Vitamin C E Ferulic',
      brand: 'SkinCeuticals',
      price: 1200000,
      discountedPrice: 850000,
      category: 'Dưỡng da',
      bgColor: Color(0xFFFFF3E8),
      iconColor: Color(0xFFD4821C),
    ),
    _ProductData(
      id: '2',
      name: 'Moisture Surge 100H',
      brand: 'Clinique',
      price: 650000,
      discountedPrice: null,
      category: 'Dưỡng da',
      bgColor: Color(0xFFE8F0FB),
      iconColor: Color(0xFF3B7DD8),
    ),
    _ProductData(
      id: '3',
      name: 'Niacinamide 10%',
      brand: 'The Ordinary',
      price: 320000,
      discountedPrice: null,
      category: 'Dưỡng da',
      bgColor: Color(0xFFF7D0E0),
      iconColor: Color(0xFFC0356B),
    ),
    _ProductData(
      id: '4',
      name: 'Kem Nền Cushion',
      brand: 'Laneige',
      price: 780000,
      discountedPrice: 620000,
      category: 'Trang điểm',
      bgColor: Color(0xFFEDE7F6),
      iconColor: Color(0xFF6A1B9A),
    ),
    _ProductData(
      id: '5',
      name: 'Son Kem Lì',
      brand: 'MAC',
      price: 450000,
      discountedPrice: null,
      category: 'Trang điểm',
      bgColor: Color(0xFFFCE4EC),
      iconColor: Color(0xFFC2185B),
    ),
    _ProductData(
      id: '6',
      name: 'Mascara Volume',
      brand: 'Maybelline',
      price: 220000,
      discountedPrice: 180000,
      category: 'Mắt',
      bgColor: Color(0xFFE8F5E9),
      iconColor: Color(0xFF388E3C),
    ),
    _ProductData(
      id: '7',
      name: 'SPF 50+ Sunscreen',
      brand: 'Anessa',
      price: 580000,
      discountedPrice: 480000,
      category: 'Dưỡng da',
      bgColor: Color(0xFFFBF1DE),
      iconColor: Color(0xFFD4A24C),
    ),
    _ProductData(
      id: '8',
      name: 'Retinol Cream 0.3%',
      brand: 'La Roche-Posay',
      price: 520000,
      discountedPrice: 420000,
      category: 'Dưỡng da',
      bgColor: Color(0xFFE3F2FD),
      iconColor: Color(0xFF1565C0),
    ),
  ];

  static const _categories = [
    'Tất cả', 'Dưỡng da', 'Trang điểm', 'Mắt', 'Môi',
  ];

  static const _sortOptions = {
    'all': 'Mặc định',
    'priceAsc': 'Giá tăng dần',
    'priceDesc': 'Giá giảm dần',
    'newest': 'Mới nhất',
  };

  List<_ProductData> get _filteredProducts {
    var list = _mockProducts.where((p) {
      final matchCat = _selectedCategory == 'Tất cả' ||
          p.category == _selectedCategory;
      final matchSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.brand.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchSearch;
    }).toList();

    if (_sortOption == 'priceAsc') {
      list.sort((a, b) =>
          (a.discountedPrice ?? a.price)
              .compareTo(b.discountedPrice ?? b.price));
    } else if (_sortOption == 'priceDesc') {
      list.sort((a, b) =>
          (b.discountedPrice ?? b.price)
              .compareTo(a.discountedPrice ?? a.price));
    }

    return list;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;

    return MainScaffold(
      currentIndex: 2,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ───────────────────────────────────────────────────
            _AppBar(
              searchController: _searchController,
              onSearch: (v) => setState(() => _searchQuery = v),
              onFilter: () => setState(() => _showFilter = !_showFilter),
              showFilter: _showFilter,
            ),

            // ── Category tabs ─────────────────────────────────────────────
            _CategoryTabs(
              categories: _categories,
              selected: _selectedCategory,
              onSelect: (c) => setState(() => _selectedCategory = c),
            ),

            // ── Filter bar ────────────────────────────────────────────────
            if (_showFilter)
              _FilterBar(
                sortOption: _sortOption,
                sortOptions: _sortOptions,
                onSortChanged: (v) => setState(() => _sortOption = v),
              ),

            // ── Product count ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppColors.s16, vertical: AppColors.s8),
              child: Row(
                children: [
                  Text('Hiển thị ${products.length} sản phẩm',
                      style: AppTextStyles.caption()),
                ],
              ),
            ),

            // ── Product grid ──────────────────────────────────────────────
            Expanded(
              child: products.isEmpty
                  ? _EmptyState(
                      onClear: () => setState(() {
                        _selectedCategory = 'Tất cả';
                        _sortOption = 'all';
                        _searchQuery = '';
                        _searchController.clear();
                      }),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(AppColors.s16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: AppColors.s12,
                        mainAxisSpacing: AppColors.s12,
                      ),
                      itemCount: products.length,
                      itemBuilder: (_, i) => _ProductCard(
                        data: products[i],
                        onTap: () => context.go(
                            '/product-detail/${products[i].id}'),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────
class _AppBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final VoidCallback onFilter;
  final bool showFilter;

  const _AppBar({
    required this.searchController,
    required this.onSearch,
    required this.onFilter,
    required this.showFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppColors.s16, AppColors.s12, AppColors.s16, AppColors.s8),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.arrow_back,
                    color: AppColors.textPrimary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: AppColors.s12),
              Expanded(
                child: Text('Sản phẩm',
                    style: AppTextStyles.title()),
              ),
              IconButton(
                onPressed: onFilter,
                icon: Icon(
                  Icons.tune,
                  color: showFilter
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: AppColors.s8),
              Stack(
                children: [
                  IconButton(
                    onPressed: () => context.go('/cart'),
                    icon: const Icon(Icons.shopping_bag_outlined,
                        color: AppColors.textSecondary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Positioned(
                    top: 0, right: 0,
                    child: Container(
                      width: 14, height: 14,
                      decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle),
                      child: Center(
                        child: Text('2',
                            style: AppTextStyles.label(
                                color: Colors.white)
                                .copyWith(fontSize: 8)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppColors.s8),
          // Search bar
          TextFormField(
            controller: searchController,
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm sản phẩm...',
              prefixIcon: const Icon(Icons.search,
                  color: AppColors.textTertiary, size: 20),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close,
                          color: AppColors.textTertiary, size: 18),
                      onPressed: () {
                        searchController.clear();
                        onSearch('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppColors.s16, vertical: AppColors.s8),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category tabs ─────────────────────────────────────────────────────────────
class _CategoryTabs extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;

  const _CategoryTabs({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      color: AppColors.surface,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: AppColors.s16, vertical: AppColors.s8),
        itemCount: categories.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppColors.s8),
        itemBuilder: (_, i) {
          final cat = categories[i];
          final isSelected = cat == selected;
          return GestureDetector(
            onTap: () => onSelect(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppColors.s12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.border,
                ),
              ),
              child: Center(
                child: Text(
                  cat,
                  style: AppTextStyles.body(
                    color: isSelected
                        ? Colors.white
                        : AppColors.textSecondary,
                  ).copyWith(
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Filter bar ────────────────────────────────────────────────────────────────
class _FilterBar extends StatelessWidget {
  final String sortOption;
  final Map<String, String> sortOptions;
  final ValueChanged<String> onSortChanged;

  const _FilterBar({
    required this.sortOption,
    required this.sortOptions,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppColors.s16, vertical: AppColors.s8),
      decoration: const BoxDecoration(
        color: AppColors.primarySubtle,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text('Sắp xếp:',
              style: AppTextStyles.caption(
                  color: AppColors.textSecondary)),
          const SizedBox(width: AppColors.s8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: sortOptions.entries.map((entry) {
                  final isSelected = sortOption == entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(
                        right: AppColors.s8),
                    child: GestureDetector(
                      onTap: () => onSortChanged(entry.key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppColors.s12,
                            vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          entry.value,
                          style: AppTextStyles.caption(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Product card ──────────────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final _ProductData data;
  final VoidCallback onTap;

  const _ProductCard({required this.data, required this.onTap});

  String _formatPrice(int price) {
    return '${(price / 1000).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}.000đ';
  }

  @override
  Widget build(BuildContext context) {
    final hasDiscount = data.discountedPrice != null;
    final displayPrice = data.discountedPrice ?? data.price;
    final discountPercent = hasDiscount
        ? (((data.price - data.discountedPrice!) / data.price) * 100)
            .toInt()
        : 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: data.bgColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: Icon(Icons.inventory_2_outlined,
                          size: 52, color: data.iconColor),
                    ),
                  ),
                  // Discount badge
                  if (hasDiscount)
                    Positioned(
                      top: AppColors.s8, left: AppColors.s8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('-$discountPercent%',
                            style: AppTextStyles.label(
                                color: Colors.white)),
                      ),
                    ),
                  // Wishlist
                  Positioned(
                    top: AppColors.s8, right: AppColors.s8,
                    child: Container(
                      width: 28, height: 28,
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border,
                          size: 14, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),

            // Product info
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(AppColors.s8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.brand,
                        style: AppTextStyles.label()),
                    const SizedBox(height: 2),
                    Text(data.name,
                        style: AppTextStyles.body(
                            color: AppColors.textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatPrice(displayPrice),
                                style: AppTextStyles.body(
                                        color: AppColors.primary)
                                    .copyWith(
                                        fontWeight:
                                            FontWeight.w700),
                              ),
                              if (hasDiscount)
                                Text(
                                  _formatPrice(data.price),
                                  style: AppTextStyles.caption()
                                      .copyWith(
                                          decoration: TextDecoration
                                              .lineThrough),
                                ),
                            ],
                          ),
                        ),
                        // Add to cart button
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 28, height: 28,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onClear;
  const _EmptyState({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off,
              size: 64, color: AppColors.primaryTint),
          const SizedBox(height: AppColors.s16),
          Text('Không có sản phẩm nào phù hợp',
              style: AppTextStyles.title(
                  color: AppColors.textSecondary)),
          const SizedBox(height: AppColors.s8),
          TextButton(
            onPressed: onClear,
            child: Text('Xóa bộ lọc',
                style:
                    AppTextStyles.body(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────
class _ProductData {
  final String id, name, brand, category;
  final int price;
  final int? discountedPrice;
  final Color bgColor, iconColor;

  const _ProductData({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.category,
    required this.bgColor,
    required this.iconColor,
    this.discountedPrice,
  });
}