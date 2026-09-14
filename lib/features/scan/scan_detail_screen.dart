import 'dart:convert';
import 'dart:io';
import '../../../../core/network/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import '../../features/scan/data/models/skin_analysis_result.dart';

class ScanDetailScreen extends StatelessWidget {
  final String imagePath;
  final SkinAnalysisResult result;
  final bool isFrontCamera;

  const ScanDetailScreen({
    super.key,
    required this.imagePath,
    required this.result,
    this.isFrontCamera = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Chi tiết Mụn & Đốm', style: AppTextStyles.title()),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined,
                color: AppColors.textSecondary),
            tooltip: 'Về trang chủ',
            onPressed: () => context.go('/home'),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined,
                color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppColors.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppColors.s16),

              // ── Header card ───────────────────────────────────────────
              _HeaderCard(result: result),
              const SizedBox(height: AppColors.s24),

              // ── Stats row  ───────────────
              _StatsRow(summary: result.acneSummary),
              const SizedBox(height: AppColors.s24),

              // ── Bản đồ mật độ: ảnh vừa chụp + overlay bbox detections ─
              Text('Bản đồ mật độ', style: AppTextStyles.heading()),
              const SizedBox(height: AppColors.s12),
              _FaceMapWithDetections(
                imagePath: imagePath,
                detections: result.detections,
                isFrontCamera: isFrontCamera,
              ),
              const SizedBox(height: AppColors.s24),

              // ── Khuyến nghị chăm sóc (từ RAG, chỉ hiện khi có data thật) ──
              if (result.recommendations.isNotEmpty) ...[
                Text('Khuyến nghị chăm sóc', style: AppTextStyles.heading()),
                const SizedBox(height: AppColors.s12),
                _RecommendationList(items: result.recommendations),
                const SizedBox(height: AppColors.s24),
              ],

              // ── Cảnh báo cần lưu ý (redFlags) ─────────────────────────
              if (result.redFlags.isNotEmpty) ...[
                _RedFlagsCard(items: result.redFlags),
                const SizedBox(height: AppColors.s24),
              ],

              // ── Sản phẩm gợi ý từ RAG ─────────────────────────────────
              if (result.recommendedProducts.isNotEmpty) ...[
                Text('Sản phẩm gợi ý', style: AppTextStyles.heading()),
                const SizedBox(height: AppColors.s12),
                _RecommendedProductsList(products: result.recommendedProducts),
                const SizedBox(height: AppColors.s24),
              ],

              // ── Expert tip / disclaimer ───────────────────────────────
              _ExpertTipCard(
                advice: result.advice,
                disclaimer: result.disclaimer,
              ),
              const SizedBox(height: AppColors.s32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header card ───────────────────────────────────────────────────────────────
class _HeaderCard extends StatelessWidget {
  final SkinAnalysisResult result;
  const _HeaderCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppColors.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: const Icon(Icons.person,
                size: 36, color: AppColors.primary),
          ),
          const SizedBox(width: AppColors.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text('Phân tích Aura của bạn',
                          style: AppTextStyles.title(),
                          overflow: TextOverflow.ellipsis),
                    ),
                    if (result.isMock) ...[
                      const SizedBox(width: AppColors.s8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('DEMO',
                            style: AppTextStyles.caption(
                                color: AppColors.accentGold)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppColors.s4),
                Row(
                  children: [
                    const Icon(Icons.check_circle,
                        size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        result.detectedSkinType.isNotEmpty
                            ? 'Loại da: ${result.detectedSkinType}'
                            : 'Vừa phân tích xong',
                        style: AppTextStyles.caption(
                            color: AppColors.primary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppColors.s12, vertical: AppColors.s8),
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text('${result.overallScore}',
                    style: AppTextStyles.title(color: AppColors.primary)
                        .copyWith(fontWeight: FontWeight.w700)),
                Text('điểm', style: AppTextStyles.caption()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final AcneSummary summary;
  const _StatsRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.grid_view_rounded,
                iconColor: AppColors.primary,
                label: 'TỔNG SỐ MỤN',
                value: '${summary.totalAcne}',
              ),
            ),
            const SizedBox(width: AppColors.s12),
            Expanded(
              child: _StatCard(
                icon: Icons.circle,
                iconColor: AppColors.error,
                label: 'MỤN VIÊM',
                value: '${summary.pimples}',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppColors.s12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.circle_outlined,
                iconColor: AppColors.textSecondary,
                label: 'ĐẦU ĐEN',
                value: '${summary.blackheads}',
              ),
            ),
            const SizedBox(width: AppColors.s12),
            Expanded(
              child: _StatCard(
                icon: Icons.panorama_fish_eye,
                iconColor: AppColors.accentGold,
                label: 'ĐẦU TRẮNG',
                value: '${summary.whiteheads}',
              ),
            ),
          ],
        ),
        if (summary.severity.isNotEmpty && summary.severity != 'unknown') ...[
          const SizedBox(height: AppColors.s12),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppColors.s12, vertical: AppColors.s4),
              decoration: BoxDecoration(
                color: _severityColor(summary.severity).withValues(alpha: .12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Mức độ: ${summary.severity}',
                style: AppTextStyles.caption(
                    color: _severityColor(summary.severity)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Color _severityColor(String severity) {
    final s = severity.toLowerCase();
    if (s.contains('nặng') || s.contains('severe')) return AppColors.error;
    if (s.contains('trung bình') || s.contains('moderate')) {
      return AppColors.accentGold;
    }
    return AppColors.success;
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label, value;

  const _StatCard({
    required this.icon, required this.iconColor,
    required this.label, required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppColors.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: AppColors.s4),
              Expanded(
                child: Text(label,
                    style: AppTextStyles.label(),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: AppColors.s8),
          Text(value,
              style: AppTextStyles.display(
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

// ── Bản đồ mật độ: ảnh local vừa chụp + overlay bbox từng detection ───────────
class _FaceMapWithDetections extends StatefulWidget {
  final String imagePath;
  final List<AcneDetection> detections;
  final bool isFrontCamera;

  const _FaceMapWithDetections({
    required this.imagePath,
    required this.detections,
    this.isFrontCamera = true,
  });

  @override
  State<_FaceMapWithDetections> createState() =>
      _FaceMapWithDetectionsState();
}

class _FaceMapWithDetectionsState extends State<_FaceMapWithDetections> {
  Size? _naturalSize;
  int? _selectedId;
  ImageStream? _stream;
  ImageStreamListener? _listener;
  bool _loadFailed = false;

  bool get _hasImage => widget.imagePath.isNotEmpty;

  ImageProvider get _imageProvider => FileImage(File(widget.imagePath));

  @override
  void initState() {
    super.initState();
    if (_hasImage) _resolveNaturalSize();
  }

  void _resolveNaturalSize() {
    _stream = _imageProvider.resolve(const ImageConfiguration());
    _listener = ImageStreamListener(
      (info, _) {
        if (!mounted) return;
        setState(() {
          _naturalSize = Size(
            info.image.width.toDouble(),
            info.image.height.toDouble(),
          );
        });
      },
      onError: (_, __) {
        if (mounted) setState(() => _loadFailed = true);
      },
    );
    _stream!.addListener(_listener!);
  }

  @override
  void dispose() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
    super.dispose();
  }

  Color _colorForClass(String className) {
    final c = className.toLowerCase();
    if (c.contains('blackhead')) return AppColors.textSecondary;
    if (c.contains('whitehead')) return AppColors.accentGold;
    return AppColors.error; // pimple / mụn viêm mặc định
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasImage || _loadFailed) {
      return _placeholder(
        icon: Icons.image_not_supported_outlined,
        title: 'Chưa có ảnh',
        subtitle: 'Không tìm thấy ảnh để hiển thị bản đồ mật độ.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_naturalSize == null)
          const SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator()),
          )
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final scale = constraints.maxWidth / _naturalSize!.width;
                final displayHeight = _naturalSize!.height * scale;
                return SizedBox(
                  width: constraints.maxWidth,
                  height: displayHeight,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image(image: _imageProvider, fit: BoxFit.fill),
                      ),
                      for (final d in widget.detections)
                        Positioned(
                          left: _flippedBBox(d.bbox).x1 * scale,
                          top: _flippedBBox(d.bbox).y1 * scale,
                          width: d.bbox.width * scale,
                          height: d.bbox.height * scale,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(() {
                              _selectedId =
                                  _selectedId == d.id ? null : d.id;
                            }),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _colorForClass(d.className),
                                  width: _selectedId == d.id ? 2.5 : 1.5,
                                ),
                                borderRadius: BorderRadius.circular(4),
                                color: _selectedId == d.id
                                    ? _colorForClass(d.className)
                                        .withValues(alpha: 0.15)
                                    : Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        if (_selectedId != null) ...[
          const SizedBox(height: AppColors.s8),
          _buildSelectedDetail(),
        ],
        const SizedBox(height: AppColors.s12),
        _buildLegend(),
      ],
    );
  }

  // Camera trước (selfie) thường lưu ảnh đã bị lật ngang để giống
  // như soi gương, nhưng model AI lại tính bbox trên ảnh gốc chưa lật.
  AcneBoundingBox _flippedBBox(AcneBoundingBox bbox) {
    if (!widget.isFrontCamera || _naturalSize == null) return bbox;
    final w = _naturalSize!.width;
    return AcneBoundingBox(
      x1: w - bbox.x2,
      y1: bbox.y1,
      x2: w - bbox.x1,
      y2: bbox.y2,
    );
  }

  Widget _buildSelectedDetail() {
    final d = widget.detections.firstWhere(
      (e) => e.id == _selectedId,
      orElse: () => widget.detections.first,
    );
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppColors.s12, vertical: AppColors.s8),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: _colorForClass(d.className)),
          const SizedBox(width: AppColors.s8),
          Expanded(
            child: Text(
              d.labelVi.isNotEmpty ? d.labelVi : d.className,
              style: AppTextStyles.body(color: AppColors.textPrimary),
            ),
          ),
          Text('${(d.confidence * 100).toStringAsFixed(0)}%',
              style: AppTextStyles.caption(color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    if (widget.detections.isEmpty) {
      return Text(
        'Không phát hiện mụn hoặc đốm nào trên ảnh.',
        style: AppTextStyles.caption(),
      );
    }
    return Wrap(
      spacing: AppColors.s12,
      runSpacing: AppColors.s8,
      children: [
        _legendItem(AppColors.error, 'Mụn viêm'),
        _legendItem(AppColors.textSecondary, 'Đầu đen'),
        _legendItem(AppColors.accentGold, 'Đầu trắng'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppColors.s4),
        Text(label, style: AppTextStyles.caption()),
      ],
    );
  }

  Widget _placeholder({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryTint, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56, height: 56,
            decoration: const BoxDecoration(
              color: AppColors.primaryTint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: AppColors.s12),
          Text(title,
              style: AppTextStyles.title(color: AppColors.primary)),
          const SizedBox(height: AppColors.s4),
          Text(subtitle,
              style: AppTextStyles.caption(), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Khuyến nghị chăm sóc (recommendations, data thật từ RAG) ──────────────────
class _RecommendationList extends StatelessWidget {
  final List<String> items;
  const _RecommendationList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppColors.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < items.length; i++)
            Padding(
              padding: EdgeInsets.only(
                  bottom: i == items.length - 1 ? 0 : AppColors.s8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: AppColors.s8),
                  Expanded(
                    child: Text(items[i],
                        style: AppTextStyles.body(color: AppColors.textPrimary)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Cảnh báo cần lưu ý (redFlags, data thật từ RAG) ────────────────────────────
class _RedFlagsCard extends StatelessWidget {
  final List<String> items;
  const _RedFlagsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppColors.s16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 18, color: AppColors.error),
              const SizedBox(width: AppColors.s8),
              Text('Lưu ý cần theo dõi',
                  style: AppTextStyles.title(color: AppColors.error)),
            ],
          ),
          const SizedBox(height: AppColors.s8),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(top: AppColors.s4),
              child: Text('• $item',
                  style: AppTextStyles.body(color: AppColors.textPrimary)),
            ),
        ],
      ),
    );
  }
}

// ── Sản phẩm gợi ý từ RAG ───────────────────────────────────────────────────
class _RecommendedProductsList extends StatelessWidget {
  final List<RecommendedProduct> products;
  const _RecommendedProductsList({required this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < products.length; i++)
          Padding(
            padding: EdgeInsets.only(
                bottom: i == products.length - 1 ? 0 : AppColors.s12),
            child: _ProductCard(product: products[i]),
          ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final RecommendedProduct product;

  const _ProductCard({
    required this.product,
  });

  Widget _buildImage() {
    if (product.imageUrl.isEmpty) {
      return Container(
        width: 64,
        height: 64,
        color: AppColors.primaryTint,
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.textSecondary,
        ),
      );
    }

    if (product.isBase64) {
      try {
        final base64Part = product.imageUrl.split(',').last;
        final bytes = base64Decode(base64Part);

        return Image.memory(
          bytes,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 64,
            height: 64,
            color: AppColors.primaryTint,
            child: const Icon(
              Icons.broken_image_outlined,
              color: AppColors.textSecondary,
            ),
          ),
        );
      } catch (_) {
        return Container(
          width: 64,
          height: 64,
          color: AppColors.primaryTint,
          child: const Icon(
            Icons.broken_image_outlined,
            color: AppColors.textSecondary,
          ),
        );
      }
    }

    final imageUrl = product.imageUrl.startsWith('http')
    ? product.imageUrl
    : '${ApiEndpoints.baseUrl}${product.imageUrl}';

  return Image.network(
    imageUrl,
    width: 64,
    height: 64,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => Container(
      width: 64,
      height: 64,
      color: AppColors.primaryTint,
      child: const Icon(
        Icons.broken_image_outlined,
        color: AppColors.textSecondary,
      ),
    ),
  );
}

  String _formatPrice(int price) {
    final s = price.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < s.length; i++) {
      final posFromEnd = s.length - i;
      buffer.write(s[i]);

      if (posFromEnd > 1 && posFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    return '${buffer}đ';
  }

 @override
Widget build(BuildContext context) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        context.push('/product-detail/${product.id}');
      },
      child: Container(
        padding: const EdgeInsets.all(AppColors.s12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildImage(),
            ),
            const SizedBox(width: AppColors.s12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand,
                    style: AppTextStyles.caption(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    product.name,
                    style: AppTextStyles.body(
                      color: AppColors.textPrimary,
                    ).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppColors.s4),
                  Text(
                    _formatPrice(product.price),
                    style: AppTextStyles.body(
                      color: AppColors.primary,
                    ).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (product.matchReason.isNotEmpty) ...[
                    const SizedBox(height: AppColors.s4),
                    Text(
                      product.matchReason,
                      style: AppTextStyles.caption(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    ),
  );
  }
}

// ── Expert tip / disclaimer ─────────────────────────────────────────────────
// Nếu advice rỗng (RAG lỗi/timeout), hiển thị đúng disclaimer thật từ BE
class _ExpertTipCard extends StatelessWidget {
  final String advice;
  final String disclaimer;
  const _ExpertTipCard({required this.advice, required this.disclaimer});

  @override
  Widget build(BuildContext context) {
    final hasAdvice = advice.trim().isNotEmpty;
    final bgColor = hasAdvice ? AppColors.primary : AppColors.textSecondary;
    final icon = hasAdvice ? Icons.lightbulb_outline : Icons.info_outline;
    final title = hasAdvice ? 'LỜI KHUYÊN CHUYÊN GIA' : 'THÔNG BÁO';
    final text = hasAdvice
        ? advice
        : (disclaimer.isNotEmpty
            ? disclaimer
            : 'Hệ thống chưa thể đưa ra tư vấn cho lần phân tích này.');

    return Container(
      padding: const EdgeInsets.all(AppColors.s16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: AppColors.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.label(color: Colors.white70)),
                const SizedBox(height: AppColors.s4),
                Text(text, style: AppTextStyles.body(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}