import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'face_detection/face_detection_models.dart';
import 'face_detection/face_frame_analyzer.dart';
import 'face_detection/face_window_smoother.dart';
import 'face_detection/image_converter.dart';
import 'face_detection/sharpness_analyzer.dart';
import 'dart:math' as math;

export 'face_detection/face_detection_models.dart';

enum FaceCaptureFailureReason {
  noFace,
  multipleFaces,
  eyesClosed,
  headPoseOff,
  faceOccluded,
  lowQuality,
}

class BurstCaptureResult {
  final XFile? file;
  final FaceCaptureFailureReason? failureReason;

  const BurstCaptureResult({
    this.file,
    this.failureReason,
  });

  bool get isSuccess => file != null;
}

class CameraService {
  CameraController? _controller;
  FaceDetector? _faceDetector;

  final _frameAnalyzer = const FaceFrameAnalyzer();
  final _windowSmoother = FaceWindowSmoother();

  bool _isProcessing = false;
  bool _isDisposed = false;

  // ── Adaptive throttle ──────────────────────────────────────────────────
  static const _minThrottleMs = 80;
  static const _maxThrottleMs = 400;

  int _adaptiveThrottleMs = 150;
  DateTime _lastProcessed =
      DateTime.fromMillisecondsSinceEpoch(0);

  // Dùng để tránh spam log realtime.
  int _processedFrameCount = 0;
  DateTime _lastFrameLog =
      DateTime.fromMillisecondsSinceEpoch(0);

  // ── Streams ────────────────────────────────────────────────────────────
  final _rawController =
      StreamController<FaceDetectionResult>.broadcast();

  Stream<FaceDetectionResult> get rawStream =>
      _rawController.stream;

  final _smoothedController =
      StreamController<SmoothedFaceState>.broadcast();

  Stream<SmoothedFaceState> get smoothedStream =>
      _smoothedController.stream;

  CameraController? get controller => _controller;

  bool get isInitialized =>
      _controller != null &&
      _controller!.value.isInitialized;

  // ──────────────────────────────────────────────────────────────────────
  // LOG HELPERS
  // ──────────────────────────────────────────────────────────────────────

  void _log(String tag, String message) {
    debugPrint(
      '[SCAN][$tag] ${DateTime.now().toIso8601String()} | $message',
    );
  }

  void _logError(
    String tag,
    String message,
    Object error,
    StackTrace stackTrace,
  ) {
    debugPrint(
      '[SCAN][$tag][ERROR] ${DateTime.now().toIso8601String()} | '
      '$message | error=$error',
    );
    debugPrint(stackTrace.toString());
  }

  String _failureReasonText(
    FaceCaptureFailureReason? reason,
  ) {
    switch (reason) {
      case FaceCaptureFailureReason.noFace:
        return 'noFace';
      case FaceCaptureFailureReason.multipleFaces:
        return 'multipleFaces';
      case FaceCaptureFailureReason.eyesClosed:
        return 'eyesClosed';
      case FaceCaptureFailureReason.headPoseOff:
        return 'headPoseOff';
      case FaceCaptureFailureReason.faceOccluded:
        return 'faceOccluded';
      case FaceCaptureFailureReason.lowQuality:
        return 'lowQuality';
      case null:
        return 'null';
    }
  }

  // ──────────────────────────────────────────────────────────────────────
  // INIT
  // ──────────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    _log('INIT', '========== CAMERA INITIALIZE START ==========');

    _isDisposed = false;

    try {
      _log('INIT', 'Calling availableCameras()...');

      final cameras = await availableCameras();

      _log(
        'INIT',
        'Available cameras: ${cameras.length}',
      );

      for (final camera in cameras) {
        _log(
          'INIT',
          'Camera: '
          'name=${camera.name}, '
          'lens=${camera.lensDirection}, '
          'sensorOrientation=${camera.sensorOrientation}',
        );
      }

      final frontCamera = cameras.firstWhere(
        (c) =>
            c.lensDirection ==
            CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _log(
        'INIT',
        'Selected camera: '
        '${frontCamera.name}, '
        'lens=${frontCamera.lensDirection}, '
        'orientation=${frontCamera.sensorOrientation}',
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      _log(
        'INIT',
        'CameraController created. '
        'ResolutionPreset=medium, '
        'format=yuv420',
      );

      await _controller!.initialize();

      _log(
        'INIT',
        'Camera initialized successfully. '
        'previewSize=${_controller!.value.previewSize}, '
        'aspectRatio=${_controller!.value.aspectRatio}',
      );

      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableClassification: true,
          enableTracking: true,
          enableLandmarks: true,
          enableContours: true,
          minFaceSize: 0.1,
          performanceMode:
              FaceDetectorMode.accurate,
        ),
      );

      _log(
        'INIT',
        'Realtime FaceDetector created. '
        'classification=true, '
        'tracking=true, '
        'landmarks=true, '
        'contours=true, '
        'minFaceSize=0.1, '
        'mode=accurate',
      );

      await _controller!.startImageStream(
        _processFrame,
      );

      _log(
        'INIT',
        'Image stream started successfully.',
      );

      _log(
        'INIT',
        '========== CAMERA INITIALIZE SUCCESS ==========',
      );
    } catch (e, st) {
      _logError(
        'INIT',
        'Camera initialization failed.',
        e,
        st,
      );
      rethrow;
    }
  }

  // ──────────────────────────────────────────────────────────────────────
  // FRAME PROCESSING
  // ──────────────────────────────────────────────────────────────────────

  Future<void> _processFrame(
    CameraImage image,
  ) async {
    final now = DateTime.now();

    if (now
            .difference(_lastProcessed)
            .inMilliseconds <
        _adaptiveThrottleMs) {
      return;
    }

    if (_isProcessing || _isDisposed) {
      return;
    }

    _isProcessing = true;
    _lastProcessed = now;

    final processingStart = DateTime.now();

    try {
      final rotation =
          ImageConverter.sensorOrientationToInputRotation(
        _controller!.description.sensorOrientation,
      );

      final inputImage =
          ImageConverter.toInputImage(
        image,
        rotation,
      );

      if (inputImage == null) {
        _log(
          'FRAME',
          'InputImage conversion returned null.',
        );
        return;
      }

      final faces =
          await _faceDetector!.processImage(
        inputImage,
      );

      if (_isDisposed) {
        return;
      }

      final raw =
          _frameAnalyzer.buildRawResult(
        faces: faces,
        image: image,
        rotation: rotation,
      );

      _rawController.add(raw);

      _windowSmoother.push(raw);

      final smoothed =
          _windowSmoother.computeSmoothed(
        raw.luminance ?? 0.0,
      );

      _smoothedController.add(smoothed);

      _processedFrameCount++;

      // Chỉ log realtime khoảng 2 giây/lần.
      final shouldLogFrame =
          DateTime.now()
                  .difference(_lastFrameLog)
                  .inMilliseconds >=
              2000;

      if (shouldLogFrame) {
        _lastFrameLog = DateTime.now();

        _log(
          'FRAME',
          'frames=$_processedFrameCount | '
          'faces=${faces.length} | '
          'luminance=${raw.luminance?.toStringAsFixed(2) ?? "null"} | '
          'throttle=${_adaptiveThrottleMs}ms | '
          'faceStable=${smoothed.isFaceStable} | '
          'centered=${smoothed.isCenteredStable} | '
          'largeEnough=${smoothed.isFaceLargeEnough} | '
          'lighting=${smoothed.isLightingStable} | '
          'headPose=${smoothed.isHeadPoseStable} | '
          'motion=${smoothed.isMotionStable} | '
          'captureProgress=${smoothed.captureProgress.toStringAsFixed(2)}',
        );
      }
    } catch (e, st) {
      _logError(
        'FRAME',
        'Exception while processing camera frame.',
        e,
        st,
      );
    } finally {
      _isProcessing = false;

      final elapsed =
          DateTime.now()
              .difference(processingStart)
              .inMilliseconds;

      final oldThrottle = _adaptiveThrottleMs;

      _adaptiveThrottleMs =
          elapsed.clamp(
        _minThrottleMs,
        _maxThrottleMs,
      );

      if (oldThrottle != _adaptiveThrottleMs) {
        _log(
          'THROTTLE',
          'Processing=${elapsed}ms | '
          'throttle changed '
          '$oldThrottle -> $_adaptiveThrottleMs ms',
        );
      }
    }
  }

  // ──────────────────────────────────────────────────────────────────────
  // SINGLE CAPTURE
  // ──────────────────────────────────────────────────────────────────────

  Future<XFile?> takePicture() async {
    _log(
      'CAPTURE',
      'takePicture() called. '
      'initialized=$isInitialized',
    );

    if (!isInitialized) {
      _log(
        'CAPTURE',
        'ABORT: camera is not initialized.',
      );
      return null;
    }

    try {
      _log(
        'CAPTURE',
        'Stopping image stream...',
      );

      await _controller!.stopImageStream();

      _log(
        'CAPTURE',
        'Taking single picture...',
      );

      final file =
          await _controller!.takePicture();

      _log(
        'CAPTURE',
        'Picture taken: ${file.path}',
      );

      final failureReason =
          await _validateCapturedImage(file);

      if (failureReason != null) {
        _log(
          'CAPTURE',
          'Single capture REJECTED. '
          'reason=${_failureReasonText(failureReason)}',
        );
        return null;
      }

      _log(
        'CAPTURE',
        'Single capture ACCEPTED.',
      );

      return file;
    } catch (e, st) {
      _logError(
        'CAPTURE',
        'Single capture exception.',
        e,
        st,
      );
      return null;
    }
  }

  // ──────────────────────────────────────────────────────────────────────
  // BURST CAPTURE
  // ──────────────────────────────────────────────────────────────────────

  Future<BurstCaptureResult> takeBurstPicture({
    int count = 3,
  }) async {
    _log(
      'BURST',
      '========== BURST CAPTURE START =========='
      ' count=$count',
    );

    if (!isInitialized) {
      _log(
        'BURST',
        'ABORT: camera is not initialized.',
      );

      return const BurstCaptureResult();
    }

    try {
      _log(
        'BURST',
        'Stopping image stream before burst...',
      );

      await _controller!.stopImageStream();

      _log(
        'BURST',
        'Image stream stopped.',
      );

      final candidates = <XFile>[];

      // ── 1. BURST ──────────────────────────────────────────────────────

      for (int i = 0; i < count; i++) {
        _log(
          'BURST',
          'Taking frame ${i + 1}/$count...',
        );

        final start = DateTime.now();

        final file =
            await _controller!.takePicture();

        final elapsed =
            DateTime.now()
                .difference(start)
                .inMilliseconds;

        candidates.add(file);

        _log(
          'BURST',
          'Frame ${i + 1}/$count captured. '
          'time=${elapsed}ms | '
          'path=${file.path}',
        );

        if (i < count - 1) {
          await Future.delayed(
            const Duration(milliseconds: 120),
          );
        }
      }

      _log(
        'BURST',
        'Burst complete. '
        'Total candidates=${candidates.length}',
      );

      // ── 2. SHARPNESS ──────────────────────────────────────────────────

      XFile? bestFile;
      double bestScore = -1;

      _log(
        'SHARPNESS',
        'Calculating JPEG sharpness for '
        '${candidates.length} candidates...',
      );

      for (int i = 0; i < candidates.length; i++) {
        final file = candidates[i];

        try {
          final bytes =
              await file.readAsBytes();

          _log(
            'SHARPNESS',
            'Frame ${i + 1}: '
            'bytes=${bytes.length}',
          );

          final score = await compute(
            computeJpegSharpness,
            bytes,
          );

          _log(
            'SHARPNESS',
            'Frame ${i + 1}: '
            'score=${score.toStringAsFixed(2)}',
          );

          if (score > bestScore) {
            bestScore = score;
            bestFile = file;

            _log(
              'SHARPNESS',
              'Frame ${i + 1} is currently BEST. '
              'bestScore=${bestScore.toStringAsFixed(2)}',
            );
          }
        } catch (e, st) {
          _logError(
            'SHARPNESS',
            'Failed calculating sharpness '
            'for frame ${i + 1}.',
            e,
            st,
          );
        }
      }

      // ── 3. DELETE OTHER FRAMES ────────────────────────────────────────

      for (final file in candidates) {
        if (file.path != bestFile?.path) {
          try {
            await File(file.path).delete();

            _log(
              'BURST',
              'Deleted non-selected frame: '
              '${file.path}',
            );
          } catch (e) {
            _log(
              'BURST',
              'Could not delete non-selected frame: '
              '${file.path} | error=$e',
            );
          }
        }
      }

      if (bestFile == null) {
        _log(
          'BURST',
          'FAIL: no best frame selected. '
          'Returning lowQuality.',
        );

        return const BurstCaptureResult(
          failureReason:
              FaceCaptureFailureReason.lowQuality,
        );
      }

      _log(
        'BURST',
        'BEST FRAME SELECTED: '
        '${bestFile.path} | '
        'sharpness=${bestScore.toStringAsFixed(2)}',
      );

      // ── 4. VALIDATE BEST FRAME ────────────────────────────────────────

      _log(
        'VALIDATE',
        'Starting final face quality validation...',
      );

      final failureReason =
          await _validateCapturedImage(bestFile);

      if (failureReason != null) {
        _log(
          'VALIDATE',
          'FINAL VALIDATION FAILED. '
          'reason=${_failureReasonText(failureReason)}',
        );

        return BurstCaptureResult(
          failureReason: failureReason,
        );
      }

      _log(
        'VALIDATE',
        'FINAL VALIDATION PASSED.',
      );

      // ── 5. FLIP ───────────────────────────────────────────────────────

      _log(
        'FLIP',
        'Flipping final image horizontally...',
      );

      await _flipImageHorizontally(
        bestFile.path,
      );

      _log(
        'FLIP',
        'Image flip completed.',
      );

      _log(
        'BURST',
        '========== BURST CAPTURE SUCCESS =========='
        ' path=${bestFile.path}',
      );

      return BurstCaptureResult(
        file: bestFile,
      );
    } catch (e, st) {
      _logError(
        'BURST',
        'Burst capture exception.',
        e,
        st,
      );

      return const BurstCaptureResult(
        failureReason:
            FaceCaptureFailureReason.lowQuality,
      );
    }
  }

  // ──────────────────────────────────────────────────────────────────────
  // FINAL FACE QUALITY GATE
  // ──────────────────────────────────────────────────────────────────────

  Future<FaceCaptureFailureReason?>
      _validateCapturedImage(
    XFile file,
  ) async {
    _log(
      'VALIDATE',
      '========== VALIDATION START =========='
      ' file=${file.path}',
    );

    try {
      final inputImage =
          InputImage.fromFilePath(file.path);

      final quickDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableClassification: true,
          performanceMode:
              FaceDetectorMode.accurate,
          minFaceSize: 0.2,
          enableContours: true,
          enableLandmarks: true,
        ),
      );

      _log(
        'VALIDATE',
        'Quick FaceDetector created. '
        'minFaceSize=0.2, '
        'classification=true, '
        'landmarks=true, '
        'contours=true, '
        'mode=accurate',
      );

      final detectStart = DateTime.now();

      final faces =
          await quickDetector.processImage(
        inputImage,
      );

      final detectElapsed =
          DateTime.now()
              .difference(detectStart)
              .inMilliseconds;

      await quickDetector.close();

      _log(
        'VALIDATE',
        'Face detection completed. '
        'faces=${faces.length} | '
        'time=${detectElapsed}ms',
      );

      // ── FACE COUNT ────────────────────────────────────────────────────

      if (faces.isEmpty) {
        _log(
          'VALIDATE',
          'FAIL: no face detected.',
        );

        return FaceCaptureFailureReason.noFace;
      }

      if (faces.length > 1) {
        _log(
          'VALIDATE',
          'FAIL: multiple faces detected. '
          'count=${faces.length}',
        );

        return FaceCaptureFailureReason.multipleFaces;
      }

      final face = faces.first;

      _log(
        'VALIDATE',
        'Exactly one face detected. '
        'boundingBox=${face.boundingBox}',
      );

      // ── EYES ──────────────────────────────────────────────────────────

      final leftEyeOpen =
          face.leftEyeOpenProbability ?? 1.0;

      final rightEyeOpen =
          face.rightEyeOpenProbability ?? 1.0;

      _log(
        'VALIDATE',
        'Eyes: '
        'left=${leftEyeOpen.toStringAsFixed(3)} | '
        'right=${rightEyeOpen.toStringAsFixed(3)} | '
        'threshold=0.5',
      );

      if (!(leftEyeOpen > 0.5 &&
          rightEyeOpen > 0.5)) {
        _log(
          'VALIDATE',
          'FAIL: eyes closed/not sufficiently open.',
        );

        return FaceCaptureFailureReason.eyesClosed;
      }

      // ── HEAD POSE ─────────────────────────────────────────────────────

      final yaw =
          (face.headEulerAngleY ?? 0).abs();

      final roll =
          (face.headEulerAngleZ ?? 0).abs();

      const maxYawDeg = 25.0;
      const maxRollDeg = 20.0;

      _log(
        'VALIDATE',
        'Head pose: '
        'yaw=${yaw.toStringAsFixed(2)}° '
        '(max=$maxYawDeg°) | '
        'roll=${roll.toStringAsFixed(2)}° '
        '(max=$maxRollDeg°)',
      );

      if (yaw > maxYawDeg ||
          roll > maxRollDeg) {
        _log(
          'VALIDATE',
          'FAIL: head pose outside threshold.',
        );

        return FaceCaptureFailureReason
            .headPoseOff;
      }

      // ── LANDMARKS ─────────────────────────────────────────────────────

      final missingLandmarks = <String>[];

      if (face.landmarks[
              FaceLandmarkType.leftEye] ==
          null) {
        missingLandmarks.add('leftEye');
      }

      if (face.landmarks[
              FaceLandmarkType.rightEye] ==
          null) {
        missingLandmarks.add('rightEye');
      }

      if (face.landmarks[
              FaceLandmarkType.noseBase] ==
          null) {
        missingLandmarks.add('nose');
      }

      final mouthVisible =
          face.landmarks[
                  FaceLandmarkType.leftMouth] !=
              null &&
          face.landmarks[
                  FaceLandmarkType.rightMouth] !=
              null &&
          face.landmarks[
                  FaceLandmarkType.bottomMouth] !=
              null;

      if (!mouthVisible) {
        missingLandmarks.add('mouth');
      }

      _log(
        'OCCLUSION',
        'Missing landmarks: '
        '${missingLandmarks.isEmpty ? "none" : missingLandmarks.join(", ")}',
      );

      _log(
        'OCCLUSION',
        'Mouth landmarks visible=$mouthVisible',
      );

      // ── MOUTH CONTOUR ─────────────────────────────────────────────────

      final mouthContourPointCount =
          (face.contours[
                      FaceContourType.upperLipTop]
                  ?.points
                  .length ??
              0) +
          (face.contours[
                      FaceContourType.upperLipBottom]
                  ?.points
                  .length ??
              0) +
          (face.contours[
                      FaceContourType.lowerLipTop]
                  ?.points
                  .length ??
              0) +
          (face.contours[
                      FaceContourType.lowerLipBottom]
                  ?.points
                  .length ??
              0);

      const minMouthContourPoints = 8;

      final mouthContourLooksOk =
          mouthContourPointCount >=
              minMouthContourPoints;

      _log(
        'OCCLUSION',
        'Mouth contour points='
        '$mouthContourPointCount | '
        'minimum=$minMouthContourPoints | '
        'looksOk=$mouthContourLooksOk',
      );

      // ── FACE CONTOUR COVERAGE ─────────────────────────────────────────

      var contourLooksIncomplete = false;
      double? contourCoverage;

      final faceContourPoints =
          face.contours[
                  FaceContourType.face]
              ?.points ??
          const [];

      _log(
        'OCCLUSION',
        'Face contour points='
        '${faceContourPoints.length}',
      );

      if (faceContourPoints.isNotEmpty &&
          face.boundingBox.height > 0) {
        final ys = faceContourPoints.map(
          (p) => p.y.toDouble(),
        );

        final minY = ys.reduce(math.min);
        final maxY = ys.reduce(math.max);

        final contourHeight =
            maxY - minY;

        contourCoverage =
            contourHeight /
                face.boundingBox.height;

        _log(
          'OCCLUSION',
          'Contour coverage='
          '${contourCoverage.toStringAsFixed(3)} | '
          'threshold=0.55 | '
          'contourHeight='
          '${contourHeight.toStringAsFixed(1)} | '
          'bboxHeight='
          '${face.boundingBox.height.toStringAsFixed(1)}',
        );

        if (contourCoverage < 0.55) {
          contourLooksIncomplete = true;
        }
      } else {
        _log(
          'OCCLUSION',
          'Contour coverage unavailable. '
          'points=${faceContourPoints.length} | '
          'bboxHeight=${face.boundingBox.height}',
        );
      }

      // ── OCCLUSION DECISION ────────────────────────────────────────────

      final severelyOccluded =
          missingLandmarks.contains('mouth') ||
          missingLandmarks.length >= 2 ||
          (missingLandmarks.length == 1 &&
              contourLooksIncomplete);

      _log(
        'OCCLUSION',
        'Decision: '
        'severelyOccluded=$severelyOccluded | '
        'missingCount=${missingLandmarks.length} | '
        'contourIncomplete=$contourLooksIncomplete | '
        'coverage=${contourCoverage?.toStringAsFixed(3) ?? "null"}',
      );

      if (severelyOccluded) {
        _log(
          'VALIDATE',
          'FAIL: face occlusion detected.',
        );

        return FaceCaptureFailureReason
            .faceOccluded;
      }

      _log(
        'VALIDATE',
        'PASS: all final quality checks passed.',
      );

      _log(
        'VALIDATE',
        '========== VALIDATION SUCCESS ==========',
      );

      return null;
    } catch (e, st) {
      _logError(
        'VALIDATE',
        'Exception during final image validation.',
        e,
        st,
      );

      return FaceCaptureFailureReason.lowQuality;
    }
  }

  // ──────────────────────────────────────────────────────────────────────
  // RESTART STREAM
  // ──────────────────────────────────────────────────────────────────────

  Future<void> restartStream() async {
    _log(
      'STREAM',
      'restartStream() called. '
      'initialized=$isInitialized',
    );

    if (!isInitialized) {
      _log(
        'STREAM',
        'ABORT restart: camera not initialized.',
      );
      return;
    }

    _windowSmoother.clear();

    _log(
      'STREAM',
      'FaceWindowSmoother cleared.',
    );

    try {
      try {
        await _controller!.stopImageStream();

        _log(
          'STREAM',
          'Existing image stream stopped.',
        );
      } catch (e) {
        _log(
          'STREAM',
          'stopImageStream ignored error: $e',
        );
      }

      await _controller!.startImageStream(
        _processFrame,
      );

      _log(
        'STREAM',
        'Image stream restarted successfully.',
      );
    } catch (e, st) {
      _logError(
        'STREAM',
        'Failed to restart image stream.',
        e,
        st,
      );
    }
  }

  // ──────────────────────────────────────────────────────────────────────
  // DISPOSE
  // ──────────────────────────────────────────────────────────────────────

  Future<void> dispose() async {
    _log(
      'DISPOSE',
      '========== CAMERA DISPOSE START ==========',
    );

    _isDisposed = true;

    try {
      await _controller?.stopImageStream();

      _log(
        'DISPOSE',
        'Image stream stopped.',
      );
    } catch (e) {
      _log(
        'DISPOSE',
        'stopImageStream error ignored: $e',
      );
    }

    try {
      await _controller?.dispose();

      _log(
        'DISPOSE',
        'CameraController disposed.',
      );
    } catch (e, st) {
      _logError(
        'DISPOSE',
        'CameraController dispose failed.',
        e,
        st,
      );
    }

    _controller = null;

    try {
      await _faceDetector?.close();

      _log(
        'DISPOSE',
        'Realtime FaceDetector closed.',
      );
    } catch (e) {
      _log(
        'DISPOSE',
        'FaceDetector close error: $e',
      );
    }

    _faceDetector = null;

    if (!_rawController.isClosed) {
      await _rawController.close();
      _log(
        'DISPOSE',
        'Raw stream closed.',
      );
    }

    if (!_smoothedController.isClosed) {
      await _smoothedController.close();
      _log(
        'DISPOSE',
        'Smoothed stream closed.',
      );
    }

    _log(
      'DISPOSE',
      '========== CAMERA DISPOSE COMPLETE ==========',
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  // FLIP IMAGE
  // ──────────────────────────────────────────────────────────────────────

  Future<void> _flipImageHorizontally(
    String path,
  ) async {
    _log(
      'FLIP',
      'Reading image bytes: $path',
    );

    final file = File(path);

    final bytes =
        await file.readAsBytes();

    _log(
      'FLIP',
      'Image bytes=${bytes.length}',
    );

    final image =
        img.decodeImage(bytes);

    if (image == null) {
      _log(
        'FLIP',
        'WARNING: img.decodeImage returned null.',
      );
      return;
    }

    _log(
      'FLIP',
      'Decoded image: '
      'width=${image.width}, '
      'height=${image.height}',
    );

    img.flipHorizontal(image);

    final jpg =
        img.encodeJpg(
      image,
      quality: 95,
    );

    _log(
      'FLIP',
      'Encoded flipped JPEG: '
      'bytes=${jpg.length}',
      );

    await file.writeAsBytes(
      jpg,
      flush: true,
    );

    _log(
      'FLIP',
      'Image written successfully.',
    );
  }
}
