import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:glow_aura/shared/widgets/main_scaffold.dart';
import 'models/product_model.dart';
import 'product_viewmodel.dart';
import 'package:glow_aura/shared/widgets/product_image.dart';


class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  bool _showFilter = false;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  static const _sortOptions = {
    'all': 'Mặc định',
    'priceAsc': 'Giá tăng dần',
    'priceDesc': 'Giá giảm dần',
    'newest': 'Mới nhất',
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(productViewModelProvider.notifier).init());

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(productViewModelProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productViewModelProvider);
    final vm = ref.read(productViewModelProvider.notifier);

    return MainScaffold(
      currentIndex: 2,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ───────────────────────────────────────────────────
            _AppBar(
              searchController: _searchController,
              onSearch: (v) => vm.search(v),
              onFilter: () => setState(() => _showFilter = !_showFilter),
              showFilter: _showFilter,
            ),

            // ── Category tabs ─────────────────────────────────────────────
            _CategoryTabs(
              categories: state.categories.isEmpty
                  ? const ['Tất cả']
                  : state.categories,
              selected: state.selectedCategory,
              onSelect: (c) => vm.selectCategory(c),
            ),

            // ── Filter bar ────────────────────────────────────────────────
            if (_showFilter)
              _FilterBar(
                sortOption: state.sortOption,
                sortOptions: _sortOptions,
                onSortChanged: (v) => vm.setSortOption(v),
              ),

            // ── Error banner ──────────────────────────────────────────────
            if (state.errorMessage != null)
              _ErrorBanner(
                message: state.errorMessage!,
                onDismiss: () => vm.clearError(),
              ),

            // ── Product count ─────────────────────────────────────────────
            if (!state.isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppColors.s16, vertical: AppColors.s8),
                child: Row(
                  children: [
                    Text('Hiển thị ${state.products.length} sản phẩm',
                        style: AppTextStyles.caption()),
                  ],
                ),
              ),

            // ── Product grid ──────────────────────────────────────────────
            Expanded(
              child: state.isLoading
                  ? const _LoadingGrid()
                  : state.products.isEmpty
                      ? _EmptyState(
                          onClear: () {
                            _searchController.clear();
                            vm.resetFilters();
                          },
                        )
                      : GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(AppColors.s16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: AppColors.s12,
                            mainAxisSpacing: AppColors.s12,
                          ),
                          itemCount: state.products.length +
                              (state.isLoadingMore ? 2 : 0),
                          itemBuilder: (_, i) {
                            if (i >= state.products.length) {
                              return const _SkeletonCard();
                            }
                            final product = state.products[i];
                            return _ProductCard(
                              product: product,
                              onTap: () =>
                                  context.go('/product-detail/${product.id}'),
                            );
                          },
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
                child: Text('Sản phẩm', style: AppTextStyles.title()),
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
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                      child: Center(
                        child: Text('2',
                            style: AppTextStyles.label(color: Colors.white)
                                .copyWith(fontSize: 8)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppColors.s8),
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
        separatorBuilder: (_, __) => const SizedBox(width: AppColors.s8),
        itemBuilder: (_, i) {
          final cat = categories[i];
          final isSelected = cat == selected;
          return GestureDetector(
            onTap: () => onSelect(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: AppColors.s12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
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
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
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
              style:
                  AppTextStyles.caption(color: AppColors.textSecondary)),
          const SizedBox(width: AppColors.s8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: sortOptions.entries.map((entry) {
                  final isSelected = sortOption == entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppColors.s8),
                    child: GestureDetector(
                      onTap: () => onSortChanged(entry.key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppColors.s12, vertical: 4),
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
  final ProductModel product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  String _formatPrice(double price) {
    final thousands = (price / 1000).toStringAsFixed(0);
    final formatted = thousands.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return '$formatted.000đ';
  }

  @override
  Widget build(BuildContext context) {
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
            // ── Image ────────────────────────────────────────────────────
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: ProductImageWidget(
                      imageUrl: product.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  // Discount badge
                  if (product.hasDiscount)
                    Positioned(
                      top: AppColors.s8,
                      left: AppColors.s8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('-${product.discountPercent}%',
                            style:
                                AppTextStyles.label(color: Colors.white)),
                      ),
                    ),
                  // Wishlist
                  Positioned(
                    top: AppColors.s8,
                    right: AppColors.s8,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border,
                          size: 14, color: AppColors.primary),
                    ),
                  ),
                  // Flash sale badge
                  if (product.isFlashSale)
                    Positioned(
                      bottom: AppColors.s8,
                      left: AppColors.s8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.flash_on,
                                size: 10, color: Colors.white),
                            Text('Flash Sale',
                                style: AppTextStyles.label(
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Info ─────────────────────────────────────────────────────
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(AppColors.s8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.brand, style: AppTextStyles.label()),
                    const SizedBox(height: 2),
                    Text(product.name,
                        style: AppTextStyles.body(
                            color: AppColors.textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatPrice(product.displayPrice),
                                style: AppTextStyles.body(
                                        color: AppColors.primary)
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                              if (product.hasDiscount)
                                Text(
                                  _formatPrice(product.price),
                                  style: AppTextStyles.caption().copyWith(
                                      decoration:
                                          TextDecoration.lineThrough),
                                ),
                            ],
                          ),
                        ),
                        // Add to cart
                        GestureDetector(
                          onTap: () {}, 
                          child: Container(
                            width: 28,
                            height: 28,
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

// ── Loading skeleton grid ─────────────────────────────────────────────────────
class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppColors.s16),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: AppColors.s12,
        mainAxisSpacing: AppColors.s12,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(AppColors.s8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 10, width: 60, color: AppColors.border),
                  const SizedBox(height: 6),
                  Container(
                      height: 12, width: double.infinity, color: AppColors.border),
                  const SizedBox(height: 4),
                  Container(height: 12, width: 80, color: AppColors.border),
                  const Spacer(),
                  Container(height: 14, width: 70, color: AppColors.border),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error banner ──────────────────────────────────────────────────────────────
class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppColors.s16, vertical: AppColors.s8),
      padding: const EdgeInsets.symmetric(
          horizontal: AppColors.s12, vertical: AppColors.s8),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 16),
          const SizedBox(width: AppColors.s8),
          Expanded(
            child: Text(message,
                style: AppTextStyles.caption(color: AppColors.error)),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close, color: AppColors.error, size: 16),
          ),
        ],
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
          const Icon(Icons.search_off, size: 64, color: AppColors.primaryTint),
          const SizedBox(height: AppColors.s16),
          Text('Không có sản phẩm nào phù hợp',
              style:
                  AppTextStyles.title(color: AppColors.textSecondary)),
          const SizedBox(height: AppColors.s8),
          TextButton(
            onPressed: onClear,
            child: Text('Xóa bộ lọc',
                style: AppTextStyles.body(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}