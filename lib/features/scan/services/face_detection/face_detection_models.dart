class FaceDetectionResult {
  final bool isFaceDetected;
  final bool isFaceCentered;
  final bool isFaceLargeEnough;
  final bool isLightingGood;
  final bool isEyesOpen;
  final bool isSharpEnough;
  final double sharpnessScore;
  final double? luminance;

  const FaceDetectionResult({
    required this.isFaceDetected,
    required this.isFaceCentered,
    required this.isFaceLargeEnough,
    required this.isLightingGood,
    required this.isEyesOpen,
    required this.isSharpEnough,
    required this.sharpnessScore,
    this.luminance,
  });

  factory FaceDetectionResult.empty() => const FaceDetectionResult(
        isFaceDetected: false,
        isFaceCentered: false,
        isFaceLargeEnough: false,
        isLightingGood: false,
        isEyesOpen: true,
        isSharpEnough: false,
        sharpnessScore: 0.0,
      );

  /// Tất cả điều kiện đều đạt 
  bool get isAllGood =>
      isFaceDetected &&
      isFaceCentered &&
      isFaceLargeEnough &&
      isLightingGood &&
      isSharpEnough &&
      isEyesOpen;
}

/// Kết quả sau khi làm mượt qua nhiều frame 
class SmoothedFaceState {
  final bool isFaceStable;
  final bool isCenteredStable;
  final bool isFaceLargeEnough;
  final bool isLightingStable;
  final bool isSharpStable;
  final double? luminance;
  final bool readyToCapture;
  final double captureProgress;

  const SmoothedFaceState({
    required this.isFaceStable,
    required this.isCenteredStable,
    required this.isFaceLargeEnough,
    required this.isLightingStable,
    required this.isSharpStable,
    this.luminance,
    required this.readyToCapture,
    required this.captureProgress,
  });

  factory SmoothedFaceState.empty() => const SmoothedFaceState(
        isFaceStable: false,
        isCenteredStable: false,
        isFaceLargeEnough: false,
        isLightingStable: false,
        isSharpStable: false,
        readyToCapture: false,
        captureProgress: 0.0,
      );
}