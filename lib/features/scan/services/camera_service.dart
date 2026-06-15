import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionResult {
  final bool isFaceDetected;
  final bool isFaceCentered;
  final bool isFaceLargeEnough;
  final bool isLightingGood;
  final bool isEyesOpen;
  final double? luminance;

  const FaceDetectionResult({
    required this.isFaceDetected,
    required this.isFaceCentered,
    required this.isFaceLargeEnough,
    required this.isLightingGood,
    required this.isEyesOpen,
    this.luminance,
  });

  factory FaceDetectionResult.empty() => const FaceDetectionResult(
        isFaceDetected: false,
        isFaceCentered: false,
        isFaceLargeEnough: false,
        isLightingGood: false,
        isEyesOpen: true,
      );
}

class SmoothedFaceState {
  final bool isFaceStable;
  final bool isCenteredStable;
  final bool isFaceLargeEnough;
  final bool isLightingStable;
  final double? luminance;
  final bool readyToCapture;

  final double captureProgress;

  const SmoothedFaceState({
    required this.isFaceStable,
    required this.isCenteredStable,
    required this.isFaceLargeEnough,
    required this.isLightingStable,
    this.luminance,
    required this.readyToCapture,
    required this.captureProgress,
  });

  factory SmoothedFaceState.empty() => const SmoothedFaceState(
        isFaceStable: false,
        isCenteredStable: false,
        isFaceLargeEnough: false,
        isLightingStable: false,
        readyToCapture: false,
        captureProgress: 0.0,
      );
}

class CameraService {
  CameraController? _controller;
  FaceDetector? _faceDetector;

  bool _isProcessing = false;
  bool _isDisposed = false;

  // ── Adaptive throttle ──────────────────────────────────────────────────────
  static const _minThrottleMs = 80;
  static const _maxThrottleMs = 400;
  int _adaptiveThrottleMs = 150;
  DateTime _lastProcessed = DateTime.fromMillisecondsSinceEpoch(0);

  // ── Window & hysteresis config ─────────────────────────────────────────────
  static const _windowSize        = 12;
  static const _faceRiseThreshold = 8;
  static const _faceFallThreshold = 4;
  static const _captureThreshold  = 9;

  // ── Face size validation ───────────────────────────────────────────────────
  static const _minFaceSizeRatio = 0.28;

  final List<bool> _faceWindow      = [];
  final List<bool> _centeredWindow  = [];
  final List<bool> _sizeWindow      = [];
  final List<bool> _lightingWindow  = [];
  final List<bool> _allGoodWindow   = [];

  // Hysteresis state
  bool _hysteresisFace     = false;
  bool _hysteresisCentered = false;
  bool _hysteresisSize     = false;
  bool _hysteresisLighting = false;

  // ── Streams ────────────────────────────────────────────────────────────────
  final _rawController =
      StreamController<FaceDetectionResult>.broadcast();
  Stream<FaceDetectionResult> get rawStream => _rawController.stream;

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
        enableClassification: true,
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
    if (now.difference(_lastProcessed).inMilliseconds < _adaptiveThrottleMs) return;
    if (_isProcessing || _isDisposed) return;

    _isProcessing = true;
    _lastProcessed = now;

    final processingStart = DateTime.now();

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
      debugPrint('_processFrame error: $e');
    } finally {
      _isProcessing = false;

      final elapsed = DateTime.now()
          .difference(processingStart)
          .inMilliseconds;
      _adaptiveThrottleMs = elapsed.clamp(_minThrottleMs, _maxThrottleMs);
    }
  }

  // ── Window + Hysteresis ────────────────────────────────────────────────────
  void _pushToWindows(FaceDetectionResult raw) {
    _addToWindow(_faceWindow,     raw.isFaceDetected);
    _addToWindow(_centeredWindow, raw.isFaceCentered);
    _addToWindow(_sizeWindow,     raw.isFaceLargeEnough);
    _addToWindow(_lightingWindow, raw.isLightingGood);
    _addToWindow(
      _allGoodWindow,
      raw.isFaceDetected &&
          raw.isFaceCentered &&
          raw.isFaceLargeEnough &&
          raw.isLightingGood &&
          raw.isEyesOpen,
    );

    _hysteresisFace     = _applyHysteresis(_faceWindow,     _hysteresisFace);
    _hysteresisCentered = _applyHysteresis(_centeredWindow, _hysteresisCentered);
    _hysteresisSize     = _applyHysteresis(_sizeWindow,     _hysteresisSize);
    _hysteresisLighting = _applyHysteresis(_lightingWindow, _hysteresisLighting);
  }

  void _addToWindow(List<bool> window, bool value) {
    window.add(value);
    if (window.length > _windowSize) window.removeAt(0);
  }

  bool _applyHysteresis(List<bool> window, bool currentState) {
    if (window.length < _windowSize) return currentState;
    final count = window.where((v) => v).length;
    if (!currentState && count >= _faceRiseThreshold) return true;
    if (currentState  && count <  _faceFallThreshold) return false;
    return currentState;
  }

  SmoothedFaceState _computeSmoothed(double luminance) {
    final allGoodCount = _allGoodWindow.where((v) => v).length;
    final readyToCapture =
        _allGoodWindow.length >= _windowSize &&
        allGoodCount >= _captureThreshold;

    final double captureProgress = _allGoodWindow.isEmpty
        ? 0.0
        : (allGoodCount / _windowSize).clamp(0.0, 1.0);

    return SmoothedFaceState(
      isFaceStable:      _hysteresisFace,
      isCenteredStable:  _hysteresisCentered,
      isFaceLargeEnough: _hysteresisSize,
      isLightingStable:  _hysteresisLighting,
      luminance:         luminance,
      readyToCapture:    readyToCapture,
      captureProgress:   captureProgress,
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
    final visualWidth  = imageHeight; 
    final visualHeight = imageWidth;
    if (faces.isEmpty) {
      return FaceDetectionResult(
        isFaceDetected: false,
        isFaceCentered: false,
        isFaceLargeEnough: false,
        isLightingGood: isLightGood,
        isEyesOpen: true,
        luminance: luminance,
      );
    }

    final face = faces.reduce(
        (a, b) => a.boundingBox.width > b.boundingBox.width ? a : b);

    final faceCenterX = face.boundingBox.center.dx;
    final faceCenterY = face.boundingBox.center.dy;

    final isCentered =
      (faceCenterX - visualWidth  / 2).abs() < visualWidth  * 0.30 &&
      (faceCenterY - visualHeight / 2).abs() < visualHeight * 0.30;

    final faceWidthRatio = face.boundingBox.width / imageWidth;
    final isFaceLargeEnough = faceWidthRatio >= _minFaceSizeRatio;

    final leftEye  = face.leftEyeOpenProbability  ?? 1.0;
    final rightEye = face.rightEyeOpenProbability ?? 1.0;
    final isEyesOpen = leftEye > 0.5 && rightEye > 0.5;

    return FaceDetectionResult(
      isFaceDetected: true,
      isFaceCentered: isCentered,
      isFaceLargeEnough: isFaceLargeEnough,
      isLightingGood: isLightGood,
      isEyesOpen: isEyesOpen,
      luminance: luminance,
    );
  }

  // ── Image conversion ───────────────────────────────────────────────────────
  InputImage? _convertToInputImage(CameraImage image) {
  if (_controller == null) return null;
  try {
    final sensorOrientation =
        _controller!.description.sensorOrientation; 

    final rotation = _sensorOrientationToInputRotation(sensorOrientation);

    return InputImage.fromBytes(
      bytes: _yuv420ToNv21(image),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,              
        format: InputImageFormat.nv21,
        bytesPerRow: image.width,
      ),
    );
  } catch (e) {
    debugPrint('_convertToInputImage error: $e');
    return null;
  }
}

InputImageRotation _sensorOrientationToInputRotation(int sensorOrientation) {
  switch (sensorOrientation) {
    case 0:   return InputImageRotation.rotation0deg;
    case 90:  return InputImageRotation.rotation90deg;
    case 180: return InputImageRotation.rotation180deg;
    case 270: return InputImageRotation.rotation270deg;
    default:  return InputImageRotation.rotation90deg;
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
    final isValid = await _validateCapturedImage(file);
    if (!isValid) return null;
    return file;
  } catch (e) {
    debugPrint('takePicture error: $e');
    return null;
  }
}
  Future<bool> _validateCapturedImage(XFile file) async {
  try {
    final inputImage = InputImage.fromFilePath(file.path);

    final quickDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        performanceMode: FaceDetectorMode.fast,
        minFaceSize: 0.2,
      ),
    );

    final faces = await quickDetector.processImage(inputImage);
    await quickDetector.close();

    if (faces.isEmpty) {
      debugPrint('_validateCapturedImage: no face detected, allowing');
      return true; 
    }

    final face = faces.reduce(
        (a, b) => a.boundingBox.width > b.boundingBox.width ? a : b);

    final left  = face.leftEyeOpenProbability  ?? 1.0;
    final right = face.rightEyeOpenProbability ?? 1.0;

    debugPrint(
        '_validateCapturedImage: left=$left right=$right');
    return left > 0.5 && right > 0.5;
  } catch (e) {
    debugPrint('_validateCapturedImage error: $e');
    return true; 
  }
}

 

  Future<void> restartStream() async {
  if (!isInitialized) return;
  _clearWindows();
  try {
    try {
      await _controller!.stopImageStream();
    } catch (_) {
      
    }
    await _controller!.startImageStream(_processFrame);
  } catch (e) {
    debugPrint('restartStream error: $e');
  }
}

  void _clearWindows() {
    _faceWindow.clear();
    _centeredWindow.clear();
    _sizeWindow.clear();
    _lightingWindow.clear();
    _allGoodWindow.clear();
    _hysteresisFace     = false;
    _hysteresisCentered = false;
    _hysteresisSize     = false;
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