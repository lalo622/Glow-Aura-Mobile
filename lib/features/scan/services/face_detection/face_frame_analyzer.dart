import 'dart:math' show Point;
import 'dart:ui' show Rect, Offset;

import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../face_geometry.dart';
import 'face_detection_models.dart';
import 'sharpness_analyzer.dart';

class FaceFrameAnalyzer {
  const FaceFrameAnalyzer();

  // ── Khoảng cách ──────────────────────────────────────────────────────
  static const double _minFaceSizeRatio = 0.28;
  static const double _maxFaceSizeRatio = 0.55;

  // ── Vị trí ───────────────────────────────────────────────────────────
  static const double _centerTolerance = 0.30;
  static const double _directionDeadzone = 0.10;
  static const double _cropMarginRatio = 0.04;

  // ── Hướng mặt ────────────────────────────────────────────────────────
  static const double _yawThresholdDeg = 15.0;
  static const double _pitchThresholdDeg = 12.0;
  static const double _rollThresholdDeg = 10.0;

  // ── Ánh sáng ─────────────────────────────────────────────────────────
  static const double _tooDarkThreshold = 60.0;
  static const double _tooBrightThreshold = 220.0;
  static const double _unevenLightDiffThreshold = 35.0;

  // Bán kính lấy mẫu da quanh landmark má.
  static const double _skinSampleRadiusRatio = 0.06;

  // Lấy mẫu luminance thưa để giảm chi phí.
  static const int _lumaSampleStride = 4;

  FaceDetectionResult buildRawResult({
    required List<Face> faces,
    required CameraImage image,
    required InputImageRotation rotation,
  }) {
    final imageWidth = image.width.toDouble();
    final imageHeight = image.height.toDouble();

    // Camera preview đang hiển thị theo chiều xoay.
    final visualWidth = imageHeight;
    final visualHeight = imageWidth;

    // 0. KHÔNG CÓ MẶT
    if (faces.isEmpty) {
      return const FaceDetectionResult(
        isFaceDetected: false,
        isFaceCentered: false,
        isFaceLargeEnough: false,
        isLightingGood: false,
        isEyesOpen: true,
        isSharpEnough: false,
        sharpnessScore: 0.0,
        luminance: null,
        isFullyInFrame: false,
        isHeadPoseOk: false,
      );
    }

    // Nếu có nhiều mặt, chọn mặt lớn nhất.
    final face = faces.reduce(
      (a, b) =>
          a.boundingBox.width > b.boundingBox.width ? a : b,
    );

    final geometry = FaceGeometry.fromFace(face);

    final faceCenterX = geometry.faceAnchor.dx;
    final faceCenterY = geometry.faceAnchor.dy;

    // 1. FACE ROI
    final rawRoi = SharpnessAnalyzer.mapRotatedRectToRawRect(
      face.boundingBox,
      image.width,
      image.height,
      rotation,
    );

    // 2. SHARPNESS - FULL IMAGE

    final fullImageRoi = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );

    final sharpness =
        SharpnessAnalyzer.calculateSharpnessInRegion(
      image,
      fullImageRoi,
    );

    final isSharpEnough =
        sharpness >= SharpnessAnalyzer.sharpnessThreshold;

    // 3. VỊ TRÍ TRONG KHUNG
    final horizontalOffset =
        (faceCenterX - visualWidth / 2) / visualWidth;

    final verticalOffset =
        (faceCenterY - visualHeight / 2) / visualHeight;

    final isCentered =
        horizontalOffset.abs() < _centerTolerance &&
        verticalOffset.abs() < _centerTolerance;

    var horizontalGuide = HorizontalGuide.ok;

    if (horizontalOffset.abs() >= _directionDeadzone) {
      horizontalGuide = horizontalOffset > 0
          ? HorizontalGuide.moveLeft
          : HorizontalGuide.moveRight;
    }

    var verticalGuide = VerticalGuide.ok;

    if (verticalOffset.abs() >= _directionDeadzone) {
      verticalGuide = verticalOffset > 0
          ? VerticalGuide.moveUp
          : VerticalGuide.moveDown;
    }

    final marginPx =
        visualHeight * _cropMarginRatio;

    final isFullyInFrame =
        face.boundingBox.top >= marginPx &&
        face.boundingBox.bottom <=
            (visualHeight - marginPx);

    // 4. KHOẢNG CÁCH
    final faceWidthRatio =
        geometry.faceWidth / imageWidth;

    DistanceGuide distanceGuide;

    if (faceWidthRatio < _minFaceSizeRatio) {
      distanceGuide = DistanceGuide.tooFar;
    } else if (faceWidthRatio > _maxFaceSizeRatio) {
      distanceGuide = DistanceGuide.tooClose;
    } else {
      distanceGuide = DistanceGuide.ok;
    }

    final isFaceLargeEnough =
        distanceGuide == DistanceGuide.ok;

    // 5. HƯỚNG MẶT
    final yaw =
        geometry.headEulerAngleY ?? 0.0;

    final pitch =
        geometry.headEulerAngleX ?? 0.0;

    final roll =
        geometry.headEulerAngleZ ?? 0.0;

    var headPoseGuide = HeadPoseGuide.ok;

    if (yaw.abs() >= _yawThresholdDeg) {
      headPoseGuide = yaw > 0
          ? HeadPoseGuide.turnRight
          : HeadPoseGuide.turnLeft;
    } else if (pitch.abs() >= _pitchThresholdDeg) {
      headPoseGuide = pitch > 0
          ? HeadPoseGuide.lookDown
          : HeadPoseGuide.lookUp;
    } else if (roll.abs() >= _rollThresholdDeg) {
      headPoseGuide = HeadPoseGuide.tiltHead;
    }

    final isHeadPoseOk =
        headPoseGuide == HeadPoseGuide.ok;

    // 6. ÁNH SÁNG - FACE ROI
    final faceLuminance =
        _averageLuminance(image, rawRoi);

    LightingGuide lightingGuide;
    bool isLightingGoodFinal;

    if (faceLuminance <= _tooDarkThreshold) {
      lightingGuide = LightingGuide.tooDark;
      isLightingGoodFinal = false;
    } else if (faceLuminance >= _tooBrightThreshold) {
      lightingGuide = LightingGuide.tooBright;
      isLightingGoodFinal = false;
    } else {
      final leftCheek =
          face.landmarks[
            FaceLandmarkType.leftCheek
          ]?.position;

      final rightCheek =
          face.landmarks[
            FaceLandmarkType.rightCheek
          ]?.position;

      final leftSkinLuminance =
          _luminanceAroundPoint(
        image,
        leftCheek,
        geometry.faceWidth,
        rotation,
      );

      final rightSkinLuminance =
          _luminanceAroundPoint(
        image,
        rightCheek,
        geometry.faceWidth,
        rotation,
      );

      if (leftSkinLuminance != null &&
          rightSkinLuminance != null) {
        final isUneven =
            (leftSkinLuminance - rightSkinLuminance)
                    .abs() >
                _unevenLightDiffThreshold;

        lightingGuide = isUneven
            ? LightingGuide.uneven
            : LightingGuide.ok;

        isLightingGoodFinal = !isUneven;
      } else {
        lightingGuide = LightingGuide.ok;
        isLightingGoodFinal = true;
      }
    }

    // 7. MẮT
    final leftEye =
        face.leftEyeOpenProbability ?? 1.0;

    final rightEye =
        face.rightEyeOpenProbability ?? 1.0;

    final isEyesOpen =
        leftEye > 0.5 &&
        rightEye > 0.5;

    // RESULT
    return FaceDetectionResult(
      isFaceDetected: true,
      isFaceCentered: isCentered,
      isFaceLargeEnough: isFaceLargeEnough,
      isLightingGood: isLightingGoodFinal,
      isEyesOpen: isEyesOpen,
      isSharpEnough: isSharpEnough,
      sharpnessScore: sharpness,
      luminance: faceLuminance,
      isFullyInFrame: isFullyInFrame,
      isHeadPoseOk: isHeadPoseOk,
      faceCenterXNorm:
          0.5 + horizontalOffset,
      faceCenterYNorm:
          0.5 + verticalOffset,
      horizontalGuide: horizontalGuide,
      verticalGuide: verticalGuide,
      distanceGuide: distanceGuide,
      headPoseGuide: headPoseGuide,
      lightingGuide: lightingGuide,
    );
  }

  /// Lấy độ sáng trung bình quanh một landmark má.
  double? _luminanceAroundPoint(
    CameraImage image,
    Point<int>? point,
    double faceWidthPx,
    InputImageRotation rotation,
  ) {
    if (point == null) return null;

    final radius =
        faceWidthPx * _skinSampleRadiusRatio;

    if (radius <= 0) return null;

    final pointRect = Rect.fromCenter(
      center: Offset(
        point.x.toDouble(),
        point.y.toDouble(),
      ),
      width: radius * 2,
      height: radius * 2,
    );

    final rawRect =
        SharpnessAnalyzer.mapRotatedRectToRawRect(
      pointRect,
      image.width,
      image.height,
      rotation,
    );

    if (rawRect.width <= 0 ||
        rawRect.height <= 0) {
      return null;
    }

    return _averageLuminance(
      image,
      rawRect,
    );
  }

  /// Tính luminance trung bình trên một vùng.
  double _averageLuminance(
    CameraImage image,
    Rect region,
  ) {
    final plane = image.planes[0];

    final bytes = plane.bytes;
    final bytesPerRow = plane.bytesPerRow;

    final left =
        region.left
            .clamp(0, image.width - 1)
            .toInt();

    final top =
        region.top
            .clamp(0, image.height - 1)
            .toInt();

    final right =
        region.right
            .clamp(0, image.width - 1)
            .toInt();

    final bottom =
        region.bottom
            .clamp(0, image.height - 1)
            .toInt();

    if (right <= left || bottom <= top) {
      return 0.0;
    }

    int sum = 0;
    int count = 0;

    for (
      int y = top;
      y < bottom;
      y += _lumaSampleStride
    ) {
      final rowOffset =
          y * bytesPerRow;

      for (
        int x = left;
        x < right;
        x += _lumaSampleStride
      ) {
        final idx =
            rowOffset + x;

        if (idx >= 0 &&
            idx < bytes.length) {
          sum += bytes[idx];
          count++;
        }
      }
    }

    return count == 0
        ? 0.0
        : sum / count;
  }
}