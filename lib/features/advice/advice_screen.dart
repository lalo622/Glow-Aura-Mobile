import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:glow_aura/shared/widgets/main_scaffold.dart';

class AdviceScreen extends StatelessWidget {
  const AdviceScreen({super.key});

  static const _products = [
    _ProductData(
      brand: 'SKINCEUTICALS',
      name: 'Vitamin C E Ferulic',
      price: '3.850.000đ',
      tagColor: Color(0xFFE8F0FB),
      tagTextColor: Color(0xFF3B7DD8),
      tag: 'VIT C',
    ),
    _ProductData(
      brand: 'LA MER',
      name: 'Crème de la Mer',
      price: '5.200.000đ',
      tagColor: Color(0xFFE8F5E9),
      tagTextColor: Color(0xFF388E3C),
      tag: 'B5',
    ),
    _ProductData(
      brand: 'LA ROCHE',
      name: 'Anthelios',
      price: '490.000đ',
      tagColor: Color(0xFFFFF3E8),
      tagTextColor: Color(0xFFD4821C),
      tag: 'SPF',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 1,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppColors.s16, vertical: AppColors.s12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/scan-result'),
                    icon: const Icon(Icons.arrow_back,
                        color: AppColors.textPrimary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: AppColors.s12),
                  Expanded(
                    child: Text('GLOW AURA',
                        style: AppTextStyles.title(color: AppColors.primary),
                        textAlign: TextAlign.center),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_horiz,
                        color: AppColors.textSecondary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: AppColors.border),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Result summary card ───────────────────────────────
                    _ResultSummaryCard(),

                    Padding(
                      padding: const EdgeInsets.all(AppColors.s16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Expert advice ─────────────────────────────
                          Text('Lời khuyên từ chuyên gia',
                              style: AppTextStyles.heading()),
                          const SizedBox(height: AppColors.s12),
                          _ExpertAdviceCard(),
                          const SizedBox(height: AppColors.s24),

                          // ── Products ───────────────────────────────────
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Sản phẩm khuyến dùng',
                                  style: AppTextStyles.heading()),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero),
                                child: Text('Tất cả',
                                    style: AppTextStyles.body(
                                        color: AppColors.primary)),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppColors.s12),
                          const _ProductsRow(products: _products),
                          const SizedBox(height: AppColors.s24),
                        ],
                      ),
                    ),

                    // ── Daily tip pinned ──────────────────────────────────
                    _DailyTipBar(),
                    const SizedBox(height: 100),
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

// ── Result summary card ───────────────────────────────────────────────────────
class _ResultSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppColors.s16),
      padding: const EdgeInsets.all(AppColors.s16),
      decoration: BoxDecoration(
        color: AppColors.primarySubtle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryTint),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppColors.s8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('KẾT QUẢ PHÂN TÍCH',
                          style: AppTextStyles.label(
                              color: Colors.white)),
                    ),
                    const SizedBox(height: AppColors.s8),
                    Text('Da Hỗn Hợp Thiên\nDầu',
                        style: AppTextStyles.display()),
                  ],
                ),
              ),
              Container(
                width: 56, height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Độ khỏe:',
                        style: AppTextStyles.label(
                            color: Colors.white70)),
                    Text('82%',
                        style: AppTextStyles.title(
                            color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppColors.s12),
          Text(
            'Lỗ chân lông vùng chữ T giãn nở. Cần tập trung cân bằng độ ẩm và làm sáng các vùng thâm mụn nhẹ.',
            style: AppTextStyles.body(),
          ),
        ],
      ),
    );
  }
}

// ── Expert advice card ────────────────────────────────────────────────────────
class _ExpertAdviceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 160,
            decoration: const BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.spa_outlined,
                      size: 48, color: AppColors.primary),
                  const SizedBox(height: AppColors.s8),
                  Text('Ảnh minh hoạ',
                      style: AppTextStyles.caption(
                          color: AppColors.primary)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppColors.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quy trình dưỡng sáng da tối ưu',
                    style: AppTextStyles.title()),
                const SizedBox(height: AppColors.s8),
                Text(
                  'Dựa trên phân tích da của bạn, chúng tôi đề xuất bộ sản phẩm chuyên biệt giúp cải thiện sắc tố và phục hồi hàng rào da trong 28 ngày.',
                  style: AppTextStyles.body(),
                ),
                const SizedBox(height: AppColors.s12),
                Row(
                  children: [
                    const _TagChip(label: 'VIT C'),
                    const SizedBox(width: AppColors.s8),
                    const _TagChip(label: 'B5'),
                    const Spacer(),
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppColors.s16),
                        ),
                        child: Text('Xem chi tiết',
                            style: AppTextStyles.body(
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tag chip ──────────────────────────────────────────────────────────────────
class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppColors.s8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: AppTextStyles.label(color: AppColors.primary)),
    );
  }
}

// ── Products row ──────────────────────────────────────────────────────────────
class _ProductsRow extends StatelessWidget {
  final List<_ProductData> products;
  const _ProductsRow({required this.products});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppColors.s12),
        itemBuilder: (_, i) => _ProductCard(data: products[i]),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final _ProductData data;
  const _ProductCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image placeholder
          Stack(
            children: [
              Container(
                height: 110,
                decoration: BoxDecoration(
                  color: data.tagColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Icon(Icons.inventory_2_outlined,
                      size: 40, color: data.tagTextColor),
                ),
              ),
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
          Padding(
            padding: const EdgeInsets.all(AppColors.s8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.brand, style: AppTextStyles.label()),
                const SizedBox(height: 2),
                Text(data.name,
                    style: AppTextStyles.body(
                        color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: AppColors.s4),
                Text(data.price,
                    style: AppTextStyles.title(
                        color: AppColors.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Daily tip bar ─────────────────────────────────────────────────────────────
class _DailyTipBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppColors.s16),
      padding: const EdgeInsets.all(AppColors.s16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined,
              color: Colors.white70, size: 20),
          const SizedBox(width: AppColors.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MẸO NHỎ HÔM NAY',
                    style: AppTextStyles.label(color: Colors.white70)),
                const SizedBox(height: AppColors.s4),
                Text(
                  'Uống đủ 2L nước và thoa lại kem chống nắng sau mỗi 4 tiếng.',
                  style: AppTextStyles.body(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data models ───────────────────────────────────────────────────────────────
class _ProductData {
  final String brand, name, price, tag;
  final Color tagColor, tagTextColor;

  const _ProductData({
    required this.brand, required this.name, required this.price,
    required this.tag, required this.tagColor, required this.tagTextColor,
  });
}