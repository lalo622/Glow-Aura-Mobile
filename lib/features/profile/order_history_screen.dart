import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'models/order_model.dart';
import '../profile/services/order_service.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(myOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
        title: Text('Lịch sử đơn hàng', style: AppTextStyles.title()),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        child: ordersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppColors.s16),
              child: Text('Không tải được đơn hàng.\n$e',
                  textAlign: TextAlign.center, style: AppTextStyles.body()),
            ),
          ),
          data: (orders) {
            if (orders.isEmpty) {
              return Center(
                child: Text('Chưa có đơn hàng nào', style: AppTextStyles.body()),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(myOrdersProvider),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppColors.s16),
                itemCount: orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppColors.s12),
                itemBuilder: (_, i) => _OrderCard(order: orders[i]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  ({Color color, Color bg}) get _statusStyle {
    switch (order.paymentStatus.toLowerCase()) {
      case 'paid':
        return (color: AppColors.success, bg: AppColors.success.withValues(alpha: 0.12));
      case 'unpaid':
        return (color: AppColors.warning, bg: AppColors.warning.withValues(alpha: 0.12));
      default:
        return (color: AppColors.textTertiary, bg: AppColors.border);
    }
  }

  String get _formattedAmount {
    final s = order.totalAmount.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '${buf.toString()}đ';
  }

  String get _formattedDate {
    final d = order.createdAt;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final st = _statusStyle;
    return Container(
      padding: const EdgeInsets.all(AppColors.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(order.orderNumber,
                    style: AppTextStyles.body().copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppColors.s8, vertical: 4),
                decoration: BoxDecoration(color: st.bg, borderRadius: BorderRadius.circular(20)),
                child: Text(order.statusDescription,
                    style: AppTextStyles.label(color: st.color)),
              ),
            ],
          ),
          const SizedBox(height: AppColors.s8),
          Text(_formattedDate, style: AppTextStyles.caption(color: AppColors.textTertiary)),
          const SizedBox(height: AppColors.s8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${order.itemCount} sản phẩm • ${order.paymentMethod}',
                  style: AppTextStyles.caption(color: AppColors.textSecondary)),
              Text(_formattedAmount,
                  style: AppTextStyles.body(color: AppColors.primary)
                      .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}