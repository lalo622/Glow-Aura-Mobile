/// Hướng dẫn căn chỉnh vị trí khuôn mặt theo trục ngang.
enum HorizontalGuide { ok, moveLeft, moveRight }

/// Hướng dẫn căn chỉnh vị trí khuôn mặt theo trục dọc.
enum VerticalGuide { ok, moveUp, moveDown }

/// Hướng dẫn khoảng cách giữa mặt và camera.
enum DistanceGuide { ok, tooClose, tooFar }

/// Hướng dẫn xoay/nghiêng đầu để nhìn thẳng vào camera.
enum HeadPoseGuide { ok, turnLeft, turnRight, lookUp, lookDown, tiltHead }

/// Hướng dẫn về ánh sáng — không chỉ thiếu/thừa sáng mà cả lệch sáng và ngược sáng (backlit).
enum LightingGuide { ok, tooDark, tooBright, uneven, backlit }

class FaceDetectionResult {
  final bool isFaceDetected;
  final bool isFaceCentered;
  final bool isFaceLargeEnough;
  final bool isFullyInFrame;
  final bool isLightingGood;
  final bool isEyesOpen;
  final bool isSharpEnough;
  final bool isHeadPoseOk;
  final double sharpnessScore;
  final double? luminance;

  final double? faceCenterXNorm;
  final double? faceCenterYNorm;

  // Chi tiết hướng dẫn (dùng để hiển thị UI, không dùng để quyết định chụp)
  final HorizontalGuide horizontalGuide;
  final VerticalGuide verticalGuide;
  final DistanceGuide distanceGuide;
  final HeadPoseGuide headPoseGuide;
  final LightingGuide lightingGuide;

  const FaceDetectionResult({
    required this.isFaceDetected,
    required this.isFaceCentered,
    required this.isFaceLargeEnough,
    required this.isLightingGood,
    required this.isEyesOpen,
    required this.isSharpEnough,
    required this.sharpnessScore,
    this.luminance,
    this.isFullyInFrame = true,
    this.isHeadPoseOk = true,
    this.faceCenterXNorm,
    this.faceCenterYNorm,
    this.horizontalGuide = HorizontalGuide.ok,
    this.verticalGuide = VerticalGuide.ok,
    this.distanceGuide = DistanceGuide.ok,
    this.headPoseGuide = HeadPoseGuide.ok,
    this.lightingGuide = LightingGuide.ok,
  });

  factory FaceDetectionResult.empty() => const FaceDetectionResult(
        isFaceDetected: false,
        isFaceCentered: false,
        isFaceLargeEnough: false,
        isLightingGood: false,
        isEyesOpen: true,
        isSharpEnough: false,
        sharpnessScore: 0.0,
        isFullyInFrame: false,
        isHeadPoseOk: false,
      );

  /// Tất cả điều kiện đều đạt — bao gồm vị trí, khoảng cách, hướng mặt.
  bool get isAllGood =>
      isFaceDetected &&
      isFaceCentered &&
      isFaceLargeEnough &&
      isFullyInFrame &&
      isHeadPoseOk &&
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
  final bool isHeadPoseStable;
  /// Mặt (và tay cầm máy) không bị rung/di chuyển giữa các frame gần đây —
  final bool isMotionStable;
  final double? luminance;
  final bool readyToCapture;
  final double captureProgress;

  
  final HorizontalGuide horizontalGuide;
  final VerticalGuide verticalGuide;
  final DistanceGuide distanceGuide;
  final HeadPoseGuide headPoseGuide;
  final LightingGuide lightingGuide;
  final bool isFullyInFrame;

  const SmoothedFaceState({
    required this.isFaceStable,
    required this.isCenteredStable,
    required this.isFaceLargeEnough,
    required this.isLightingStable,
    required this.isSharpStable,
    required this.isHeadPoseStable,
    required this.isMotionStable,
    this.luminance,
    required this.readyToCapture,
    required this.captureProgress,
    this.horizontalGuide = HorizontalGuide.ok,
    this.verticalGuide = VerticalGuide.ok,
    this.distanceGuide = DistanceGuide.ok,
    this.headPoseGuide = HeadPoseGuide.ok,
    this.lightingGuide = LightingGuide.ok,
    this.isFullyInFrame = true,
  });

  factory SmoothedFaceState.empty() => const SmoothedFaceState(
        isFaceStable: false,
        isCenteredStable: false,
        isFaceLargeEnough: false,
        isLightingStable: false,
        isSharpStable: false,
        isHeadPoseStable: false,
        isMotionStable: false,
        readyToCapture: false,
        captureProgress: 0.0,
        isFullyInFrame: false,
      );
}