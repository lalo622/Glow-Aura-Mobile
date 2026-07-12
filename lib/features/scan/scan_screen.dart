import 'dart:async';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:glow_aura/core/theme/app_theme.dart';

import 'services/camera_service.dart';
import 'data/scan_database.dart';
import 'services/image_save_service.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen>
    with TickerProviderStateMixin {
  final _cameraService = CameraService();
  StreamSubscription<SmoothedFaceState>? _detectionSub;
  SmoothedFaceState _smoothedState = SmoothedFaceState.empty();
  bool _hasTriggeredCapture = false;
  bool _isCapturing         = false;
  bool    _isInitializing = true;
  String? _errorMessage;
  DateTime? _stableStartTime;
  static const _requiredHoldMs = 1500;
  late final AnimationController _progressController;
  double _progressTarget = 0.0;
  late final AnimationController _shutterController;
  late final Animation<double>   _shutterOpacity;


  late final AnimationController _pulseController;
  late final Animation<double>   _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Progress Ring 
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120), 
    );

    // Shutter Flash — 0 → 0.6 → 0 trong 180ms
    _shutterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _shutterOpacity = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 0.65), weight: 30),
      TweenSequenceItem(
          tween: Tween(begin: 0.65, end: 0.0), weight: 70),
    ]).animate(CurvedAnimation(
      parent: _shutterController,
      curve: Curves.easeOut,
    ));

    ref.read(scanDatabaseProvider).cleanOldScans();
    ref.read(imageSaveServiceProvider).retryPendingUploads();

    _initCamera();
  }

  Future<void> _initCamera() async {
    setState(() {
      _isInitializing = true;
      _errorMessage   = null;
    });

    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() {
        _isInitializing = false;
        _errorMessage   = 'Cần cấp quyền camera để sử dụng tính năng này.';
      });
      return;
    }

    try {
      await _cameraService.initialize();

       _detectionSub = _cameraService.smoothedStream.listen((state) {
      if (!mounted) return;
      setState(() => _smoothedState = state);

      final isReady = state.isFaceStable
          && state.isCenteredStable
          && state.isFaceLargeEnough
          && state.isLightingStable;

      if (isReady) {
        _stableStartTime ??= DateTime.now();

        final heldMs = DateTime.now()
            .difference(_stableStartTime!)
            .inMilliseconds;
        final holdProgress = (heldMs / _requiredHoldMs).clamp(0.0, 1.0);

        final combinedProgress = (state.captureProgress * 0.5 + holdProgress * 0.5);

        if (combinedProgress != _progressTarget) {
          _progressController.animateTo(
            combinedProgress,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
          );
          _progressTarget = combinedProgress;
        }

        if (!_hasTriggeredCapture && holdProgress >= 1.0 && state.captureProgress >= 0.8) {
          _hasTriggeredCapture = true;
          _onCapture();
        }
      } else {
        _stableStartTime = null;

        if (_progressTarget > 0) {
          _progressController.animateTo(0.0,
              duration: const Duration(milliseconds: 200));
          _progressTarget = 0.0;
        }
      }
    });

      setState(() => _isInitializing = false);
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _errorMessage   = 'Không thể khởi tạo camera: $e';
      });
    }
  }

    Future<void> _onCapture({int retryCount = 0}) async {
  if (_isCapturing) return;
  HapticFeedback.mediumImpact();
  setState(() => _isCapturing = true);

  try {
    debugPrint('[Capture] Bắt đầu takePicture (retry=$retryCount)');
    final file = await _cameraService.takeBurstPicture(count: 3);
    debugPrint('[Capture] takePicture xong: ${file?.path}');

    if (!mounted) return; 

    if (file == null) {
      if (retryCount < 2) {
        debugPrint('[Capture] Bị reject, thử lại lần #${retryCount + 1}');
        await _cameraService.restartStream();
        if (!mounted) return;
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;

        setState(() => _isCapturing = false);
        _hasTriggeredCapture = false;
        return;
      } else {
        debugPrint('[Capture] Hết lượt retry, báo lỗi cho user');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ảnh bị mờ hoặc lệch, vui lòng thử lại')),
        );
        setState(() => _isCapturing = false);
        await _resetCaptureState();
        return;
      }
    }

    _shutterController.forward(from: 0.0);

    debugPrint('[Capture] Bắt đầu saveScan');
    final imageSaveService = ref.read(imageSaveServiceProvider);
    final result = await imageSaveService.saveScan(file.path);
    debugPrint('[Capture] saveScan xong: scanId=${result.scanId}');

    if (!mounted) return;
    setState(() => _isCapturing = false);

    debugPrint('[Capture] Chuẩn bị push /scan-result');
    await context.push('/scan-result', extra: {
      'imagePath': result.localPath,
      'scanId':    result.scanId,
    });
    debugPrint('[Capture] Đã push xong, quay lại từ scan-result');

    if (mounted) await _resetCaptureState();
  } catch (e, st) {
    debugPrint('[Capture]  LỖI KHÔNG BẮT ĐƯỢC: $e');
    debugPrint('$st');
    if (mounted) {
      setState(() => _isCapturing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra khi xử lý ảnh: $e')),
      );
    }
  }
}

    Future<void> _resetCaptureState() async {
    setState(() {
      _hasTriggeredCapture = false;
      _isCapturing         = false;
      _progressTarget      = 0.0;
      _stableStartTime     = null; 
    });
    _progressController.animateTo(0.0,
        duration: const Duration(milliseconds: 80));
    await _cameraService.restartStream();
  }

  @override
  Future<void> dispose() async {
    _pulseController.dispose();
    _progressController.dispose();
    _shutterController.dispose();
    await _detectionSub?.cancel();
    await _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
        title: Text('Quét da mặt',
            style: AppTextStyles.title().copyWith(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white70),
            onPressed: () => context.go('/scan-guide'),
          ),
        ],
      ),
      body: SafeArea(
        child: _isInitializing
            ? const _LoadingView()
            : _errorMessage != null
                ? _ErrorView(message: _errorMessage!, onRetry: _initCamera)
                : Stack(
                    children: [
                      _CameraBody(
                        cameraService:      _cameraService,
                        smoothedState:      _smoothedState,
                        pulseAnimation:     _pulseAnimation,
                        progressController: _progressController,
                        isCapturing:        _isCapturing,
                        onCapture:          _onCapture,
                      ),

                      // ── [MỚI] Shutter Flash overlay ──────────────────────
                      AnimatedBuilder(
                        animation: _shutterOpacity,
                        builder: (_, __) {
                          if (_shutterOpacity.value == 0.0) {
                            return const SizedBox.shrink();
                          }
                          return Positioned.fill(
                            child: IgnorePointer(
                              child: Container(
                                color: Colors.white
                                    .withValues(alpha:_shutterOpacity.value),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CameraBody extends StatelessWidget {
  final CameraService      cameraService;
  final SmoothedFaceState  smoothedState;
  final Animation<double>  pulseAnimation;
  final AnimationController progressController; 
  final bool               isCapturing;
  final VoidCallback       onCapture;

  const _CameraBody({
    required this.cameraService,
    required this.smoothedState,
    required this.pulseAnimation,
    required this.progressController,
    required this.isCapturing,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppColors.s16),
            child: _CameraPreviewArea(
              controller:         cameraService.controller!,
              smoothedState:      smoothedState,
              pulseAnimation:     pulseAnimation,
              progressController: progressController,
            ),
          ),
        ),

        _ScanStatusBar(smoothedState: smoothedState),
        const SizedBox(height: AppColors.s16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppColors.s16),
          child: Row(
            children: [
              Expanded(
                child: _StatusChip(
                  icon:       Icons.wb_sunny_outlined,
                  label:      'Ánh sáng',
                  value:      smoothedState.isLightingStable ? 'TỐT ƯU' : 'THIẾU SÁNG',
                  valueColor: smoothedState.isLightingStable
                      ? AppColors.success
                      : Colors.orange,
                ),
              ),
              const SizedBox(width: AppColors.s12),
              Expanded(
                child: _StatusChip(
                  icon:  Icons.face_outlined,
                  label: 'Khuôn mặt',
                  value: !smoothedState.isFaceStable
                      ? 'KHÔNG THẤY'
                      : !smoothedState.isCenteredStable
                          ? 'CĂN CHỈNH LẠI'
                          : !smoothedState.isFaceLargeEnough
                              ? 'LẠI GẦN HƠN'
                              : 'CHÍNH XÁC',
                  valueColor: smoothedState.isFaceStable &&
                              smoothedState.isCenteredStable &&
                              smoothedState.isFaceLargeEnough
                      ? AppColors.primary
                      : Colors.orange,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppColors.s24),

        _CameraControls(
          isCapturing:      isCapturing,
          isReadyToCapture: smoothedState.isFaceStable && 
                            smoothedState.isCenteredStable&&
                            smoothedState.isFaceLargeEnough &&
                            smoothedState.isLightingStable,
          onCapture:        onCapture,
        ),
        const SizedBox(height: AppColors.s12),

        Text(
          'Căn chỉnh khuôn mặt vào giữa khung hình để có kết quả tốt nhất',
          style: AppTextStyles.caption().copyWith(color: Colors.white60),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppColors.s24),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CameraPreviewArea extends StatelessWidget {
  final CameraController    controller;
  final SmoothedFaceState   smoothedState;
  final Animation<double>   pulseAnimation;
  final AnimationController progressController; // [MỚI]

  const _CameraPreviewArea({
    required this.controller,
    required this.smoothedState,
    required this.pulseAnimation,
    required this.progressController,
  });

  @override
  Widget build(BuildContext context) {
    final ovalColor = smoothedState.isFaceStable
        ? (smoothedState.isCenteredStable ? AppColors.primary : Colors.orange)
        : Colors.white54;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width:  controller.value.previewSize!.height,
              height: controller.value.previewSize!.width,
              child: CameraPreview(controller),
            ),
          ),

          // Radial vignette
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.85,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha:0.45),
                ],
              ),
            ),
          ),

          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([pulseAnimation, progressController]),
              builder: (_, __) {
                final progress = progressController.value;
                final scale = smoothedState.isFaceStable ? 1.0 : pulseAnimation.value;

                final ringColor = Color.lerp(
                  const Color(0xFFFFB300), 
                  const Color(0xFF4CAF50), 
                  progress,
                )!;

                return Transform.scale(
                  scale: scale,
                  child: CustomPaint(
                    size: const Size(260, 340),
                    painter: _ProgressRingPainter(
                      progress:  progress,
                      ringColor: ringColor,
                      baseColor: ovalColor,
                    ),
                  ),
                );
              },
            ),
          ),

          ..._buildScanCorners(ovalColor),

          if (smoothedState.isFaceStable)
            const Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(child: _DetectedBadge()),
            ),
        ],
      ),
    );
  }

  static List<Widget> _buildScanCorners(Color color) {
    return [
      Positioned(top: 40,    left: 60,
          child: _ScanCorner(top: true,  left: true,  color: color)),
      Positioned(top: 40,    right: 60,
          child: _ScanCorner(top: true,  left: false, color: color)),
      Positioned(bottom: 40, left: 60,
          child: _ScanCorner(top: false, left: true,  color: color)),
      Positioned(bottom: 40, right: 60,
          child: _ScanCorner(top: false, left: false, color: color)),
    ];
  }
}


class _ProgressRingPainter extends CustomPainter {
  final double progress;   
  final Color  ringColor;  
  final Color  baseColor;  

  const _ProgressRingPainter({
    required this.progress,
    required this.ringColor,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final basePaint = Paint()
      ..color       = baseColor.withValues(alpha:0.35)
      ..strokeWidth = 2.0
      ..style       = PaintingStyle.stroke;

    const dashWidth = 12.0;
    const dashSpace =  6.0;
    final basePath = Path()..addOval(rect);
    for (final metric in basePath.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), basePaint);
        distance += dashWidth + dashSpace;
      }
    }

    if (progress <= 0.0) return;

    final progressPaint = Paint()
      ..color       = ringColor
      ..strokeWidth = 3.5
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.round;

    if (progress > 0.7) {
      final glowPaint = Paint()
        ..color       = ringColor.withValues(alpha:0.3 * ((progress - 0.7) / 0.3))
        ..strokeWidth = 8.0
        ..style       = PaintingStyle.stroke
        ..maskFilter  = const MaskFilter.blur(BlurStyle.normal, 4);
      _drawProgressArc(canvas, rect, glowPaint, progress);
    }

    _drawProgressArc(canvas, rect, progressPaint, progress);

    if (progress > 0.02) {
      final angle = -math.pi / 2 + 2 * math.pi * progress;
      final cx = rect.center.dx + rect.width  / 2 * math.cos(angle);
      final cy = rect.center.dy + rect.height / 2 * math.sin(angle);
      canvas.drawCircle(
        Offset(cx, cy),
        4.5,
        Paint()..color = ringColor,
      );
    }
  }

  void _drawProgressArc(
      Canvas canvas, Rect rect, Paint paint, double progress) {

    final fullPath = Path()..addOval(rect);
    for (final metric in fullPath.computeMetrics()) {
      final end = metric.length * progress;
      const startFraction = 0.25; 
      final startDistance = metric.length * startFraction;
      final endDistance   = startDistance + end;

      if (endDistance <= metric.length) {
        canvas.drawPath(
            metric.extractPath(startDistance, endDistance), paint);
      } else {
        canvas.drawPath(
            metric.extractPath(startDistance, metric.length), paint);
        canvas.drawPath(
            metric.extractPath(0, endDistance - metric.length), paint);
      }
    } 
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter old) =>
      old.progress != progress ||
      old.ringColor != ringColor ||
      old.baseColor != baseColor;
}

// ─────────────────────────────────────────────────────────────────────────────

class _ScanStatusBar extends StatelessWidget {
  final SmoothedFaceState smoothedState;

  const _ScanStatusBar({required this.smoothedState});

  String get _statusText {
  if (!smoothedState.isFaceStable)      return 'Hướng camera về phía khuôn mặt';
  if (!smoothedState.isCenteredStable)  return 'Di chuyển để căn giữa khuôn mặt';
  if (!smoothedState.isFaceLargeEnough) return 'Đưa khuôn mặt lại gần hơn';
  if (!smoothedState.isLightingStable)  return 'Cần thêm ánh sáng';
  if (smoothedState.captureProgress < 0.83) return 'Giữ yên, đang chuẩn bị chụp...';
  return 'Đang chụp...';
}

  @override
  Widget build(BuildContext context) {
    final isReady = smoothedState.isFaceStable &&
        smoothedState.isCenteredStable &&
        smoothedState.isFaceLargeEnough && 
        smoothedState.isLightingStable;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppColors.s16),
      padding: const EdgeInsets.all(AppColors.s16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha:0.12)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _statusText,
                  style: AppTextStyles.body(color: Colors.white)
                      .copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isReady
                    ? const Icon(Icons.check_circle,
                        color: AppColors.success, size: 20)
                    : const SizedBox(
                        width:  20,
                        height: 20,
                        child:  CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
              ),
            ],
          ),

          if (isReady && smoothedState.captureProgress > 0) ...[
            const SizedBox(height: AppColors.s8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: smoothedState.captureProgress,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.lerp(
                    const Color(0xFFFFB300),
                    const Color(0xFF4CAF50),
                    smoothedState.captureProgress,
                  )!,
                ),
                minHeight: 3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}


class _CameraControls extends StatelessWidget {
  final bool         isCapturing;
  final bool         isReadyToCapture;
  final VoidCallback onCapture;

  const _CameraControls({
    required this.isCapturing,
    required this.isReadyToCapture,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CircleButton(icon: Icons.photo_outlined, onTap: () {}),
        const SizedBox(width: AppColors.s32),

        GestureDetector(
          onTap: isCapturing ? null : onCapture,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width:  72,
            height: 72,
            decoration: BoxDecoration(
              color:  isReadyToCapture ? AppColors.primary : Colors.white30,
              shape:  BoxShape.circle,
              boxShadow: isReadyToCapture
                  ? [BoxShadow(
                      color: AppColors.primary.withValues(alpha:0.5),
                      blurRadius: 20, spreadRadius: 4)]
                  : [],
            ),
            child: isCapturing
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child:   CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : const Icon(Icons.camera_alt, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(width: AppColors.s32),

        _CircleButton(icon: Icons.photo_outlined, onTap: () {}),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:  48,
        height: 48,
        decoration: BoxDecoration(
          color:  Colors.white.withValues(alpha:0.12),
          shape:  BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white70, size: 22),
      ),
    );
  }
}

class _DetectedBadge extends StatelessWidget {
  const _DetectedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha:0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.face, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text('Đã nhận diện khuôn mặt',
              style: AppTextStyles.caption()
                  .copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ScanCorner extends StatelessWidget {
  final bool  top, left;
  final Color color;
  const _ScanCorner(
      {required this.top, required this.left, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20, height: 20,
      child: CustomPaint(
          painter: _CornerPainter(color: color, top: top, left: left)),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final bool  top, left;
  const _CornerPainter(
      {required this.color, required this.top, required this.left});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color       = color
      ..strokeWidth = 3
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.round;
    final x = left ? 0.0 : size.width;
    final y = top  ? 0.0 : size.height;
    canvas.drawLine(Offset(x, y),
        Offset(x + (left ? size.width : -size.width), y), paint);
    canvas.drawLine(Offset(x, y),
        Offset(x, y + (top ? size.height : -size.height)), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String   label, value;
  final Color    valueColor;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppColors.s12, vertical: AppColors.s8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha:0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppColors.s8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.caption()
                      .copyWith(color: Colors.white60)),
              Text(value, style: AppTextStyles.label(color: valueColor)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text('Đang khởi động camera...',
              style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String       message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera_alt_outlined,
                size: 64, color: Colors.white30),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon:  const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            const TextButton(
              onPressed: openAppSettings,
              child: Text('Mở cài đặt quyền',
                  style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }
}