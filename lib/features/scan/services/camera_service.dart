import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'face_detection/face_detection_models.dart';
import 'face_detection/face_frame_analyzer.dart';
import 'face_detection/face_window_smoother.dart';
import 'face_detection/image_converter.dart';
import 'face_detection/sharpness_analyzer.dart';

export 'face_detection/face_detection_models.dart';


class CameraService {
  CameraController? _controller;
  FaceDetector? _faceDetector;

  final _frameAnalyzer = const FaceFrameAnalyzer();
  final _windowSmoother = FaceWindowSmoother();

  bool _isProcessing = false;
  bool _isDisposed = false;

  // ── Adaptive throttle
  static const _minThrottleMs = 80;
  static const _maxThrottleMs = 400;
  int _adaptiveThrottleMs = 150;
  DateTime _lastProcessed = DateTime.fromMillisecondsSinceEpoch(0);

  // ── Streams ────────────────────────────────────────────────────────────
  final _rawController = StreamController<FaceDetectionResult>.broadcast();
  Stream<FaceDetectionResult> get rawStream => _rawController.stream;

  final _smoothedController =
      StreamController<SmoothedFaceState>.broadcast();
  Stream<SmoothedFaceState> get smoothedStream => _smoothedController.stream;

  CameraController? get controller => _controller;
  bool get isInitialized =>
      _controller != null && _controller!.value.isInitialized;

  // ── Init ───────────────────────────────────────────────────────────────
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
        enableLandmarks: true,
        minFaceSize: 0.1,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );

    await _controller!.startImageStream(_processFrame);
  }

  // ── Frame processing ──────────────────────────────────────────────────
  Future<void> _processFrame(CameraImage image) async {
    final now = DateTime.now();
    if (now.difference(_lastProcessed).inMilliseconds < _adaptiveThrottleMs) {
      return;
    }
    if (_isProcessing || _isDisposed) return;

    _isProcessing = true;
    _lastProcessed = now;
    final processingStart = DateTime.now();

    try {
      final rotation = ImageConverter.sensorOrientationToInputRotation(
        _controller!.description.sensorOrientation,
      );

      final inputImage = ImageConverter.toInputImage(image, rotation);
      if (inputImage == null) return;

      final faces = await _faceDetector!.processImage(inputImage);
      final luminance = ImageConverter.calculateLuminance(image);

      if (_isDisposed) return;

      final raw = _frameAnalyzer.buildRawResult(
        faces: faces,
        image: image,
        rotation: rotation,
        luminance: luminance,
      );

      _rawController.add(raw);
      _windowSmoother.push(raw);
      _smoothedController.add(_windowSmoother.computeSmoothed(luminance));
    } catch (e) {
      debugPrint('_processFrame error: $e');
    } finally {
      _isProcessing = false;
      final elapsed =
          DateTime.now().difference(processingStart).inMilliseconds;
      _adaptiveThrottleMs = elapsed.clamp(_minThrottleMs, _maxThrottleMs);
    }
  }

  // ── Capture ───────────────────────────────────────────────────────────
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

  Future<XFile?> takeBurstPicture({int count = 3}) async {
    if (!isInitialized) return null;

    try {
      await _controller!.stopImageStream();

      final candidates = <XFile>[];
      for (int i = 0; i < count; i++) {
        final file = await _controller!.takePicture();
        candidates.add(file);
        if (i < count - 1) {
          await Future.delayed(const Duration(milliseconds: 120));
        }
      }

      XFile? bestFile;
      double bestScore = -1;

      for (final file in candidates) {
        final bytes = await file.readAsBytes();
        final score = await compute(computeJpegSharpness, bytes);
        debugPrint(
            '[CameraService] Burst frame ${file.path} sharpness=$score');
        if (score > bestScore) {
          bestScore = score;
          bestFile = file;
        }
      }

      // Dọn các frame không được chọn.
      for (final file in candidates) {
        if (file.path != bestFile?.path) {
          try {
            await File(file.path).delete();
          } catch (_) {}
        }
      }

      if (bestFile == null) return null;

      final isValid = await _validateCapturedImage(bestFile);
      if (!isValid) return null;

      debugPrint(
          '[CameraService] Chọn frame nét nhất: ${bestFile.path} (score=$bestScore)');
      return bestFile;
    } catch (e) {
      debugPrint('takeBurstPicture error: $e');
      return null;
    }
  }

  Future<bool> _validateCapturedImage(XFile file) async {
    try {
      final inputImage = InputImage.fromFilePath(file.path);

      final quickDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableClassification: true,
          performanceMode: FaceDetectorMode.accurate,
          minFaceSize: 0.2,
        ),
      );

      final faces = await quickDetector.processImage(inputImage);
      await quickDetector.close();

      if (faces.isEmpty) {
        debugPrint('_validateCapturedImage: no face detected, rejected');
        return false;
      }

      final face = faces
          .reduce((a, b) => a.boundingBox.width > b.boundingBox.width ? a : b);

      final left = face.leftEyeOpenProbability ?? 1.0;
      final right = face.rightEyeOpenProbability ?? 1.0;

      debugPrint('_validateCapturedImage: left=$left right=$right');
      return left > 0.5 && right > 0.5;
    } catch (e) {
      debugPrint('_validateCapturedImage error: $e');
      return false;
    }
  }

  Future<void> restartStream() async {
    if (!isInitialized) return;
    _windowSmoother.clear();
    try {
      try {
        await _controller!.stopImageStream();
      } catch (_) {}
      await _controller!.startImageStream(_processFrame);
    } catch (e) {
      debugPrint('restartStream error: $e');
    }
  }

  // ── Dispose ───────────────────────────────────────────────────────────
  Future<void> dispose() async {
    _isDisposed = true;
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
    await _faceDetector?.close();
    _faceDetector = null;
    if (!_rawController.isClosed) _rawController.close();
    if (!_smoothedController.isClosed) _smoothedController.close();
  }
}