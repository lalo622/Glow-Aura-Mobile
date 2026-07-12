import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:glow_aura/features/scan/data/models/skin_analysis_history.dart';
import 'package:glow_aura/features/scan/data/scan_database.dart';
import 'package:glow_aura/features/scan/providers/skin_history_provider.dart';

const int _kRecentScansLimit = 3;

final _imagePathByTimeProvider =
    FutureProvider.autoDispose.family<String?, DateTime>((ref, capturedAt) async {
  final db = ref.watch(scanDatabaseProvider);
  return db.getImagePathNearTime(capturedAt);
});

// ── Tab chính ────────────────────────────────────────────────────────────
class ScanHistoryTab extends ConsumerWidget {
  const ScanHistoryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(recentScansProvider(_kRecentScansLimit));

    return historyAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (e, _) => _ErrorView(
        onRetry: () =>
            ref.invalidate(recentScansProvider(_kRecentScansLimit)),
      ),
      data: (response) {
        final items = response.items;
        if (items.isEmpty) return const _EmptyHistoryView();

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async =>
              ref.invalidate(recentScansProvider(_kRecentScansLimit)),
          child: GridView.builder(
            padding: const EdgeInsets.all(2),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _ScanGridTile(
                item: item,
                onTap: () => _showDetail(context, item),
              );
            },
          ),
        );
      },
    );
  }

  void _showDetail(BuildContext context, SkinAnalysisHistoryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ScanDetailSheet(item: item),
    );
  }
}

Color _severityColor(String severity) => switch (severity.toLowerCase()) {
      'mild' => const Color(0xFF4CAF50),
      'moderate' => const Color(0xFFFF9800),
      'severe' => const Color(0xFFF44336),
      _ => AppColors.primary,
    };

String _severityLabelShort(String severity) => switch (severity.toLowerCase()) {
      'mild' => 'Nhẹ',
      'moderate' => 'TB',
      'severe' => 'Nặng',
      _ => '?',
    };

String _severityLabelFull(String severity) => switch (severity.toLowerCase()) {
      'mild' => 'Nhẹ',
      'moderate' => 'Trung bình',
      'severe' => 'Nặng',
      _ => severity,
    };

// ── Grid Tile ────────────────────────────────────────────────────────────
class _ScanGridTile extends ConsumerWidget {
  final SkinAnalysisHistoryItem item;
  final VoidCallback onTap;

  const _ScanGridTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final severityColor = _severityColor(item.severity);
    final imageAsync = ref.watch(_imagePathByTimeProvider(item.capturedAt));

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          imageAsync.when(
            loading: () => Container(color: AppColors.primaryTint),
            error: (_, __) =>
                _NetworkOrPlaceholder(item: item, severityColor: severityColor),
            data: (imagePath) {
              if (imagePath != null && imagePath.isNotEmpty) {
                final file = File(imagePath);
                if (file.existsSync()) {
                  return Image.file(
                    file,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _NetworkOrPlaceholder(
                      item: item,
                      severityColor: severityColor,
                    ),
                  );
                }
              }
              return _NetworkOrPlaceholder(item: item, severityColor: severityColor);
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black45, Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('dd/MM').format(item.capturedAt),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${item.overallScore}đ',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: severityColor.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _severityLabelShort(item.severity),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ảnh: local-first, network-fallback, placeholder cuối cùng ────────────
class _NetworkOrPlaceholder extends StatelessWidget {
  final SkinAnalysisHistoryItem item;
  final Color severityColor;

  const _NetworkOrPlaceholder({
    required this.item,
    required this.severityColor,
  });

  @override
  Widget build(BuildContext context) {
    final url = item.fullImageUrl;
    if (url.isEmpty) return _buildPlaceholder();

    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: severityColor.withValues(alpha: 0.08),
          child: const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() => Container(
        color: severityColor.withValues(alpha: 0.15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.face_retouching_natural, color: severityColor, size: 28),
            const SizedBox(height: 4),
            Text(
              '${item.acneCount} mụn',
              style: TextStyle(
                  fontSize: 9,
                  color: severityColor,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
}

// ── Detail Bottom Sheet ────────────────────────────────────────────────
class _ScanDetailSheet extends ConsumerWidget {
  final SkinAnalysisHistoryItem item;
  const _ScanDetailSheet({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final severityColor = _severityColor(item.severity);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ── Ảnh chi tiết ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _DetailImageSection(item: item),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('dd/MM/yyyy • HH:mm').format(item.capturedAt),
                        style: AppTextStyles.body(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _MetricCard(
                        label: 'Glow Score',
                        value: '${item.overallScore}',
                        icon: Icons.auto_awesome,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      _MetricCard(
                        label: 'Số mụn',
                        value: '${item.acneCount}',
                        icon: Icons.bubble_chart_outlined,
                        color: severityColor,
                      ),
                      const SizedBox(width: 10),
                      _MetricCard(
                        label: 'Mức độ',
                        value: _severityLabelFull(item.severity),
                        icon: Icons.warning_amber_rounded,
                        color: severityColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (item.adviceText.isNotEmpty) ...[
                    Text('Lời khuyên', style: AppTextStyles.heading()),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primarySubtle,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryTint),
                      ),
                      child: Text(
                        item.adviceText,
                        style: AppTextStyles.body().copyWith(height: 1.6),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'Mã phiên: ${item.sessionId}',
                    style: AppTextStyles.caption(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Khối ảnh chi tiết + tap để mở fullscreen ──────────────────────────
class _DetailImageSection extends ConsumerWidget {
  final SkinAnalysisHistoryItem item;
  const _DetailImageSection({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageAsync = ref.watch(_imagePathByTimeProvider(item.capturedAt));
    final severityColor = _severityColor(item.severity);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 1,
        child: GestureDetector(
          onTap: () => _openFullscreen(context, imageAsync.valueOrNull),
          child: imageAsync.when(
            loading: () => Container(color: severityColor.withValues(alpha: 0.08)),
            error: (_, __) =>
                _NetworkOrPlaceholder(item: item, severityColor: severityColor),
            data: (imagePath) {
              if (imagePath != null && imagePath.isNotEmpty) {
                final file = File(imagePath);
                if (file.existsSync()) {
                  return Image.file(
                    file,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _NetworkOrPlaceholder(
                      item: item,
                      severityColor: severityColor,
                    ),
                  );
                }
              }
              return _NetworkOrPlaceholder(item: item, severityColor: severityColor);
            },
          ),
        ),
      ),
    );
  }

  void _openFullscreen(BuildContext context, String? localPath) {
    final hasLocal =
        localPath != null && localPath.isNotEmpty && File(localPath).existsSync();

    if (!hasLocal && item.fullImageUrl.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _FullscreenImageViewer(
          localPath: hasLocal ? localPath : null,
          networkUrl: item.fullImageUrl,
        ),
      ),
    );
  }
}

class _FullscreenImageViewer extends StatelessWidget {
  final String? localPath;
  final String networkUrl;

  const _FullscreenImageViewer({this.localPath, required this.networkUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4,
          child: localPath != null
              ? Image.file(
                  File(localPath!),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => networkUrl.isNotEmpty
                      ? _buildNetworkFallback()
                      : _buildBrokenIcon(),
                )
              : _buildNetworkFallback(),
        ),
      ),
    );
  }

  Widget _buildNetworkFallback() => Image.network(
        networkUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const CircularProgressIndicator(color: Colors.white);
        },
        errorBuilder: (_, __, ___) => _buildBrokenIcon(),
      );

  Widget _buildBrokenIcon() => const Icon(
        Icons.broken_image_outlined,
        color: Colors.white54,
        size: 64,
      );
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(value,
                style: AppTextStyles.title(color: color),
                textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.label(), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistoryView extends StatelessWidget {
  const _EmptyHistoryView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt_outlined, size: 64, color: AppColors.border),
          const SizedBox(height: 16),
          Text('Chưa có ảnh nào', style: AppTextStyles.title()),
          const SizedBox(height: 8),
          Text(
            'Hãy chụp ảnh đầu tiên để bắt đầu\ntheo dõi làn da của bạn',
            textAlign: TextAlign.center,
            style: AppTextStyles.body(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.border),
          const SizedBox(height: 12),
          Text('Không tải được dữ liệu', style: AppTextStyles.body()),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}