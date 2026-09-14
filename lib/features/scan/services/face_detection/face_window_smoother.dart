import 'face_detection_models.dart';

class FaceWindowSmoother {
  static const _windowSize = 12;
  static const _riseThreshold = 8;
  static const _fallThreshold = 4;
  static const _captureThreshold = 9;

  // Ngưỡng di chuyển giữa 2 frame liên tiếp (theo tỉ lệ khung hình, 0..1)
  static const double _motionThreshold = 0.035;

  final _faceWindow = <bool>[];
  final _centeredWindow = <bool>[];
  final _sizeWindow = <bool>[];
  final _lightingWindow = <bool>[];
  final _sharpWindow = <bool>[];
  final _headPoseWindow = <bool>[];
  final _motionWindow = <bool>[];
  final _allGoodWindow = <bool>[];

  bool _hysteresisFace = false;
  bool _hysteresisCentered = false;
  bool _hysteresisSize = false;
  bool _hysteresisLighting = false;
  bool _hysteresisSharp = false;
  bool _hysteresisHeadPose = false;
  bool _hysteresisMotion = false;

  double? _prevCenterX;
  double? _prevCenterY;

  // Frame gần nhất — dùng để lấy guidance chi tiết (không qua hysteresis)
  FaceDetectionResult _lastRaw = FaceDetectionResult.empty();

  void push(FaceDetectionResult raw) {
    _lastRaw = raw;

    _addToWindow(_faceWindow, raw.isFaceDetected);
    _addToWindow(_centeredWindow, raw.isFaceCentered);
    _addToWindow(_sizeWindow, raw.isFaceLargeEnough);
    _addToWindow(_lightingWindow, raw.isLightingGood);
    _addToWindow(_sharpWindow, raw.isSharpEnough);
    _addToWindow(_headPoseWindow, raw.isHeadPoseOk);
    _addToWindow(_allGoodWindow, raw.isAllGood);

    _hysteresisFace = _applyHysteresis(_faceWindow, _hysteresisFace);
    _hysteresisCentered =
        _applyHysteresis(_centeredWindow, _hysteresisCentered);
    _hysteresisSize = _applyHysteresis(_sizeWindow, _hysteresisSize);
    _hysteresisLighting =
        _applyHysteresis(_lightingWindow, _hysteresisLighting);
    _hysteresisSharp = _applyHysteresis(_sharpWindow, _hysteresisSharp);
    _hysteresisHeadPose =
        _applyHysteresis(_headPoseWindow, _hysteresisHeadPose);

    // ── Motion stability  ─────────────────────────────────
    bool motionOk = false;
    if (raw.isFaceDetected &&
        raw.faceCenterXNorm != null &&
        raw.faceCenterYNorm != null) {
      if (_prevCenterX != null && _prevCenterY != null) {
        final dx = (raw.faceCenterXNorm! - _prevCenterX!).abs();
        final dy = (raw.faceCenterYNorm! - _prevCenterY!).abs();
        motionOk = dx < _motionThreshold && dy < _motionThreshold;
      }
      _prevCenterX = raw.faceCenterXNorm;
      _prevCenterY = raw.faceCenterYNorm;
    } else {
      _prevCenterX = null;
      _prevCenterY = null;
    }
    _addToWindow(_motionWindow, motionOk);
    _hysteresisMotion = _applyHysteresis(_motionWindow, _hysteresisMotion);
  }

  SmoothedFaceState computeSmoothed(double luminance) {
    final allGoodCount = _allGoodWindow.where((v) => v).length;
    final readyToCapture = _allGoodWindow.length >= _windowSize &&
        allGoodCount >= _captureThreshold;

    final captureProgress = _allGoodWindow.isEmpty
        ? 0.0
        : (allGoodCount / _windowSize).clamp(0.0, 1.0);

    return SmoothedFaceState(
      isFaceStable: _hysteresisFace,
      isCenteredStable: _hysteresisCentered,
      isFaceLargeEnough: _hysteresisSize,
      isLightingStable: _hysteresisLighting,
      isSharpStable: _hysteresisSharp,
      isHeadPoseStable: _hysteresisHeadPose,
      isMotionStable: _hysteresisMotion,
      luminance: luminance,
      readyToCapture: readyToCapture,
      captureProgress: captureProgress,
      horizontalGuide: _lastRaw.horizontalGuide,
      verticalGuide: _lastRaw.verticalGuide,
      distanceGuide: _lastRaw.distanceGuide,
      headPoseGuide: _lastRaw.headPoseGuide,
      lightingGuide: _lastRaw.lightingGuide,
      isFullyInFrame: _lastRaw.isFullyInFrame,
    );
  }

  void clear() {
    _faceWindow.clear();
    _centeredWindow.clear();
    _sizeWindow.clear();
    _lightingWindow.clear();
    _sharpWindow.clear();
    _headPoseWindow.clear();
    _motionWindow.clear();
    _allGoodWindow.clear();
    _hysteresisFace = false;
    _hysteresisCentered = false;
    _hysteresisSize = false;
    _hysteresisLighting = false;
    _hysteresisSharp = false;
    _hysteresisHeadPose = false;
    _hysteresisMotion = false;
    _prevCenterX = null;
    _prevCenterY = null;
    _lastRaw = FaceDetectionResult.empty();
  }

  void _addToWindow(List<bool> window, bool value) {
    window.add(value);
    if (window.length > _windowSize) window.removeAt(0);
  }

  bool _applyHysteresis(List<bool> window, bool currentState) {
    if (window.length < _windowSize) return currentState;
    final count = window.where((v) => v).length;
    if (!currentState && count >= _riseThreshold) return true;
    if (currentState && count < _fallThreshold) return false;
    return currentState;
  }
}