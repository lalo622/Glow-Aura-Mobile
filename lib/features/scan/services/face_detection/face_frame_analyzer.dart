import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../face_geometry.dart';
import 'face_detection_models.dart';
import 'sharpness_analyzer.dart';


class FaceFrameAnalyzer {
  const FaceFrameAnalyzer();

  static const double _minFaceSizeRatio = 0.28;

  FaceDetectionResult buildRawResult({
    required List<Face> faces,
    required CameraImage image,
    required InputImageRotation rotation,
    required double luminance,
  }) {
    final imageWidth = image.width.toDouble();
    final imageHeight = image.height.toDouble();
    final isLightGood = luminance > 60 && luminance < 220;

    final visualWidth = imageHeight;
    final visualHeight = imageWidth;

    if (faces.isEmpty) {
      return FaceDetectionResult(
        isFaceDetected: false,
        isFaceCentered: false,
        isFaceLargeEnough: false,
        isLightingGood: isLightGood,
        isEyesOpen: true,
        isSharpEnough: false,
        sharpnessScore: 0.0,
        luminance: luminance,
      );
    }

    final face = faces.reduce(
      (a, b) => a.boundingBox.width > b.boundingBox.width ? a : b,
    );
    final geometry = FaceGeometry.fromFace(face);
    final faceCenterX = geometry.faceAnchor.dx;
    final faceCenterY = geometry.faceAnchor.dy;

    final rawRoi = SharpnessAnalyzer.mapRotatedRectToRawRect(
      face.boundingBox,
      image.width,
      image.height,
      rotation,
    );
    final expandedRoi = SharpnessAnalyzer.expandRoi(
      rawRoi,
      SharpnessAnalyzer.faceRoiMarginRatio,
      image.width,
      image.height,
    );
    final sharpness =
        SharpnessAnalyzer.calculateSharpnessInRegion(image, expandedRoi);
    final isSharpEnough = sharpness >= SharpnessAnalyzer.sharpnessThreshold;

    final isCentered =
        (faceCenterX - visualWidth / 2).abs() < visualWidth * 0.30 &&
            (faceCenterY - visualHeight / 2).abs() < visualHeight * 0.30;

    final faceWidthRatio = geometry.faceWidth / imageWidth;
    final isFaceLargeEnough = faceWidthRatio >= _minFaceSizeRatio;

    final leftEye = face.leftEyeOpenProbability ?? 1.0;
    final rightEye = face.rightEyeOpenProbability ?? 1.0;
    final isEyesOpen = leftEye > 0.5 && rightEye > 0.5;

    return FaceDetectionResult(
      isFaceDetected: true,
      isFaceCentered: isCentered,
      isFaceLargeEnough: isFaceLargeEnough,
      isLightingGood: isLightGood,
      isEyesOpen: isEyesOpen,
      isSharpEnough: isSharpEnough,
      sharpnessScore: sharpness,
      luminance: luminance,
    );
  }
}