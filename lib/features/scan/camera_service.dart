import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionResult {
  final bool isFaceDetected;
  final bool isFaceCentered;
  final bool isLightingGood;
  final double? luminance;

  const FaceDetectionResult({
    required this.isFaceDetected,
    required this.isFaceCentered,
    required this.isLightingGood,
    this.luminance,
  });

  factory FaceDetectionResult.empty() => const FaceDetectionResult(
        isFaceDetected: false,
        isFaceCentered: false,
        isLightingGood: false,
      );
}

class SmoothedFaceState {
  final bool isFaceStable;
  final bool isCenteredStable;
  final bool isLightingStable;
  final double? luminance;
  final bool readyToCapture;

  const SmoothedFaceState({
    required this.isFaceStable,
    required this.isCenteredStable,
    required this.isLightingStable,
    this.luminance,
    required this.readyToCapture,
  });

  factory SmoothedFaceState.empty() => const SmoothedFaceState(
        isFaceStable: false,
        isCenteredStable: false,
        isLightingStable: false,
        readyToCapture: false,
      );
}

class CameraService {
  CameraController? _controller;
  FaceDetector? _faceDetector;

  bool _isProcessing = false;
  bool _isDisposed = false;

  // Throttle: 150ms ≈ 6–7 FPS 
  DateTime _lastProcessed = DateTime.fromMillisecondsSinceEpoch(0);
  static const _throttleMs = 150;
  static const _windowSize = 8;
  static const _faceRiseThreshold = 5;  // cần 5/8 frame có face để "lên"
  static const _faceFallThreshold = 3;  // cần < 3/8 frame để "xuống"
  static const _captureThreshold  = 6;  // cần 6/8 "all good" để trigger capture

  final List<bool> _faceWindow      = [];
  final List<bool> _centeredWindow  = [];
  final List<bool> _lightingWindow  = [];
  final List<bool> _allGoodWindow   = [];

  // Hysteresis state
  bool _hysteresisFace     = false;
  bool _hysteresisCentered = false;
  bool _hysteresisLighting = false;

  // ── Streams ────────────────────────────────────────────────────────────────
  final _rawController =
      StreamController<FaceDetectionResult>.broadcast();
  Stream<FaceDetectionResult> get rawStream => _rawController.stream;

  // smoothedStream: UI lắng nghe stream này
  final _smoothedController =
      StreamController<SmoothedFaceState>.broadcast();
  Stream<SmoothedFaceState> get smoothedStream => _smoothedController.stream;

  CameraController? get controller => _controller;
  bool get isInitialized =>
      _controller != null && _controller!.value.isInitialized;

  // ── Init ───────────────────────────────────────────────────────────────────
  Future<void> initialize() async {
    _isDisposed = false;

    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _controller!.initialize();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: false,
        enableTracking: true,
        minFaceSize: 0.1,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );

    await _controller!.startImageStream(_processFrame);
  }

  // ── Frame processing ───────────────────────────────────────────────────────
  Future<void> _processFrame(CameraImage image) async {
    final now = DateTime.now();
    if (now.difference(_lastProcessed).inMilliseconds < _throttleMs) return;
    if (_isProcessing || _isDisposed) return;

    _isProcessing = true;
    _lastProcessed = now;

    try {
      final inputImage = _convertToInputImage(image);
      if (inputImage == null) return;

      final faces = await _faceDetector!.processImage(inputImage);
      final luminance = _calculateLuminance(image);

      if (_isDisposed) return;

      final raw = _buildRawResult(
        faces: faces,
        imageWidth: image.width.toDouble(),
        imageHeight: image.height.toDouble(),
        luminance: luminance,
      );

      _rawController.add(raw);
      _pushToWindows(raw);
      _smoothedController.add(_computeSmoothed(luminance));
    } catch (e) {
    } finally {
      _isProcessing = false;
    }
  }

  // ── Window + Hysteresis ────────────────────────────────────────────────────
  void _pushToWindows(FaceDetectionResult raw) {
    _addToWindow(_faceWindow,     raw.isFaceDetected);
    _addToWindow(_centeredWindow, raw.isFaceCentered);
    _addToWindow(_lightingWindow, raw.isLightingGood);
    _addToWindow(_allGoodWindow,
        raw.isFaceDetected && raw.isFaceCentered && raw.isLightingGood);

    // Hysteresis: tránh flicker UI
    _hysteresisFace     = _applyHysteresis(_faceWindow,     _hysteresisFace);
    _hysteresisCentered = _applyHysteresis(_centeredWindow, _hysteresisCentered);
    _hysteresisLighting = _applyHysteresis(_lightingWindow, _hysteresisLighting);
  }

  void _addToWindow(List<bool> window, bool value) {
    window.add(value);
    if (window.length > _windowSize) window.removeAt(0);
  }

  bool _applyHysteresis(List<bool> window, bool currentState) {
    if (window.length < _windowSize) return currentState;
    final count = window.where((v) => v).length;
    if (!currentState && count >= _faceRiseThreshold)  return true;
    if (currentState  && count <  _faceFallThreshold)  return false;
    return currentState; 
  }

  SmoothedFaceState _computeSmoothed(double luminance) {
    final allGoodCount = _allGoodWindow.where((v) => v).length;
    final readyToCapture =
        _allGoodWindow.length >= _windowSize &&
        allGoodCount >= _captureThreshold;

    

    return SmoothedFaceState(
      isFaceStable:     _hysteresisFace,
      isCenteredStable: _hysteresisCentered,
      isLightingStable: _hysteresisLighting,
      luminance:        luminance,
      readyToCapture:   readyToCapture,
    );
  }

  // ── Raw result builder ─────────────────────────────────────────────────────
  FaceDetectionResult _buildRawResult({
    required List<Face> faces,
    required double imageWidth,
    required double imageHeight,
    required double luminance,
  }) {
    final isLightGood = luminance > 60 && luminance < 220;

    if (faces.isEmpty) {
      return FaceDetectionResult(
        isFaceDetected: false,
        isFaceCentered: false,
        isLightingGood: isLightGood,
        luminance: luminance,
      );
    }

    final face = faces.reduce(
        (a, b) => a.boundingBox.width > b.boundingBox.width ? a : b);

    final faceCenterX = face.boundingBox.center.dx;
    final faceCenterY = face.boundingBox.center.dy;

    final isCentered =
        (faceCenterX - imageWidth / 2).abs()  < imageWidth  * 0.40 &&
        (faceCenterY - imageHeight / 2).abs() < imageHeight * 0.40;

    return FaceDetectionResult(
      isFaceDetected: true,
      isFaceCentered: isCentered,
      isLightingGood: isLightGood,
      luminance: luminance,
    );
  }

  // ── Image conversion ───────────────────────────────────────────────────────
  InputImage? _convertToInputImage(CameraImage image) {
    if (_controller == null) return null;
    try {
      return InputImage.fromBytes(
        bytes: _yuv420ToNv21(image),
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation90deg,
          format: InputImageFormat.nv21,
          bytesPerRow: image.width,
        ),
      );
    } catch (e) {
      debugPrint('_convertToInputImage error: $e');
      return null;
    }
  }

  Uint8List _yuv420ToNv21(CameraImage image) {
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final width    = image.width;
    final height   = image.height;
    final uvWidth  = width  ~/ 2;
    final uvHeight = height ~/ 2;

    final nv21 = Uint8List(width * height + uvWidth * uvHeight * 2);

    int idx = 0;
    for (int row = 0; row < height; row++) {
      final rowStart = row * yPlane.bytesPerRow;
      nv21.setRange(idx, idx + width, yPlane.bytes, rowStart);
      idx += width;
    }

    final pixelStride = uPlane.bytesPerPixel ?? 2;
    final rowStride   = uPlane.bytesPerRow;
    for (int row = 0; row < uvHeight; row++) {
      for (int col = 0; col < uvWidth; col++) {
        final uvIdx = row * rowStride + col * pixelStride;
        if (uvIdx < vPlane.bytes.length && uvIdx < uPlane.bytes.length) {
          nv21[idx++] = vPlane.bytes[uvIdx];
          nv21[idx++] = uPlane.bytes[uvIdx];
        }
      }
    }

    return nv21;
  }

  double _calculateLuminance(CameraImage image) {
    final yPlane = image.planes.first.bytes;
    if (yPlane.isEmpty) return 0;
    int sum = 0;
    for (int i = 0; i < yPlane.length; i += 50) {
      sum += yPlane[i];
    }
    return sum / (yPlane.length / 50);
  }

  // ── Capture ────────────────────────────────────────────────────────────────
  Future<XFile?> takePicture() async {
    if (!isInitialized) return null;
    try {
      await _controller!.stopImageStream();
      final file = await _controller!.takePicture();
      return file;
    } catch (e) {
      debugPrint('takePicture error: $e');
      return null;
    }
  }

  /// Restart stream sau khi chụp xong 
  Future<void> restartStream() async {
    if (!isInitialized) return;
    _clearWindows();
    try {
      await _controller!.startImageStream(_processFrame);
    } catch (e) {
      debugPrint('restartStream error: $e');
    }
  }

  void _clearWindows() {
    _faceWindow.clear();
    _centeredWindow.clear();
    _lightingWindow.clear();
    _allGoodWindow.clear();
    _hysteresisFace     = false;
    _hysteresisCentered = false;
    _hysteresisLighting = false;
  }

  // ── Dispose ────────────────────────────────────────────────────────────────
  Future<void> dispose() async {
    _isDisposed = true;
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
    await _faceDetector?.close();
    _faceDetector = null;
    if (!_rawController.isClosed)      _rawController.close();
    if (!_smoothedController.isClosed) _smoothedController.close();
  }
}