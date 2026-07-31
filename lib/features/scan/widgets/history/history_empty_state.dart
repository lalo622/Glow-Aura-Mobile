import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:glow_aura/core/network/app_exception.dart';

class HistoryEmptyState extends StatelessWidget {
  final String message;
  final Future<void> Function()? onRefresh;
  const HistoryEmptyState({super.key, required this.message, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history, size: 48, color: AppColors.primaryTint),
          const SizedBox(height: AppColors.s12),
          Text(message,
              style: AppTextStyles.body(color: AppColors.textTertiary)),
        ],
      ),
    );

    if (onRefresh == null) return content;

    return RefreshIndicator(
      onRefresh: onRefresh!,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: content,
          ),
        ],
      ),
    );
  }
}

class HistoryErrorState extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  const HistoryErrorState({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final err = error;
    final isUnauthorized =
        err is AppException && err.type == AppErrorType.unauthorized;
    final message = err is AppException
        ? err.message
        : 'Không thể tải lịch sử quét. Vui lòng thử lại.';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUnauthorized ? Icons.lock_outline : Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: AppColors.s12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppColors.s24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(color: AppColors.textTertiary),
            ),
          ),
          const SizedBox(height: AppColors.s12),
          TextButton(
            onPressed: isUnauthorized
                ? () => context.go('/login')
                : onRetry,
            child: Text(isUnauthorized ? 'Đăng nhập lại' : 'Thử lại'),
          ),
        ],
      ),
    );
  }
}