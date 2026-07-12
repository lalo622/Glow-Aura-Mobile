import 'face_detection_models.dart';

class FaceWindowSmoother {
  static const _windowSize = 12;
  static const _riseThreshold = 8;
  static const _fallThreshold = 4;
  static const _captureThreshold = 9;

  final _faceWindow = <bool>[];
  final _centeredWindow = <bool>[];
  final _sizeWindow = <bool>[];
  final _lightingWindow = <bool>[];
  final _sharpWindow = <bool>[];
  final _allGoodWindow = <bool>[];

  bool _hysteresisFace = false;
  bool _hysteresisCentered = false;
  bool _hysteresisSize = false;
  bool _hysteresisLighting = false;
  bool _hysteresisSharp = false;

  void push(FaceDetectionResult raw) {
    _addToWindow(_faceWindow, raw.isFaceDetected);
    _addToWindow(_centeredWindow, raw.isFaceCentered);
    _addToWindow(_sizeWindow, raw.isFaceLargeEnough);
    _addToWindow(_lightingWindow, raw.isLightingGood);
    _addToWindow(_sharpWindow, raw.isSharpEnough);
    _addToWindow(_allGoodWindow, raw.isAllGood);

    _hysteresisFace = _applyHysteresis(_faceWindow, _hysteresisFace);
    _hysteresisCentered =
        _applyHysteresis(_centeredWindow, _hysteresisCentered);
    _hysteresisSize = _applyHysteresis(_sizeWindow, _hysteresisSize);
    _hysteresisLighting =
        _applyHysteresis(_lightingWindow, _hysteresisLighting);
    _hysteresisSharp = _applyHysteresis(_sharpWindow, _hysteresisSharp);
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
      luminance: luminance,
      readyToCapture: readyToCapture,
      captureProgress: captureProgress,
    );
  }

  void clear() {
    _faceWindow.clear();
    _centeredWindow.clear();
    _sizeWindow.clear();
    _lightingWindow.clear();
    _sharpWindow.clear();
    _allGoodWindow.clear();
    _hysteresisFace = false;
    _hysteresisCentered = false;
    _hysteresisSize = false;
    _hysteresisLighting = false;
    _hysteresisSharp = false;
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