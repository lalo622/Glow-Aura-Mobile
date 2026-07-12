import 'package:flutter/material.dart' show Offset;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

enum FaceAnchorSource { noseBase, eyeMidpoint, boundingBoxCenter }

enum FaceSizeSource { faceContour, boundingBox }


class FaceGeometry {
  final Offset faceAnchor;      
  final Offset eyeCenter;       // Trung điểm 2 mắt 
  final double faceWidth;
  final double faceHeight;
  final double? headEulerAngleX; // pitch 
  final double? headEulerAngleY; // yaw   
  final double? headEulerAngleZ; // roll  
  final FaceAnchorSource anchorSource;
  final FaceSizeSource sizeSource;

  const FaceGeometry({
    required this.faceAnchor,
    required this.eyeCenter,
    required this.faceWidth,
    required this.faceHeight,
    required this.anchorSource,
    required this.sizeSource,
    this.headEulerAngleX,
    this.headEulerAngleY,
    this.headEulerAngleZ,
  });

  factory FaceGeometry.fromFace(Face face, {bool useContourForSize = false}) {
    final noseAnchor = _pointOf(face, FaceLandmarkType.noseBase);
    final eyeMid = _eyeMidpoint(face);
    final boxCenter = Offset(
      face.boundingBox.center.dx,
      face.boundingBox.center.dy,
    );

    late final Offset anchor;
    late final FaceAnchorSource anchorSource;
    if (noseAnchor != null) {
      anchor = noseAnchor;
      anchorSource = FaceAnchorSource.noseBase;
    } else if (eyeMid != null) {
      anchor = eyeMid;
      anchorSource = FaceAnchorSource.eyeMidpoint;
    } else {
      anchor = boxCenter;
      anchorSource = FaceAnchorSource.boundingBoxCenter;
    }

    double width = face.boundingBox.width;
    double height = face.boundingBox.height;
    FaceSizeSource sizeSource = FaceSizeSource.boundingBox;

    if (useContourForSize) {
      final faceContour = face.contours[FaceContourType.face];
      final points = faceContour?.points;
      if (points != null && points.length >= 4) {
        double minX = points.first.x.toDouble();
        double maxX = minX;
        double minY = points.first.y.toDouble();
        double maxY = minY;
        for (final p in points) {
          final x = p.x.toDouble();
          final y = p.y.toDouble();
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }
        final w = maxX - minX;
        final h = maxY - minY;
        if (w > 0 && h > 0) {
          width = w;
          height = h;
          sizeSource = FaceSizeSource.faceContour;
        }
      }
    }

    return FaceGeometry(
      faceAnchor: anchor,
      eyeCenter: eyeMid ?? boxCenter,
      faceWidth: width,
      faceHeight: height,
      anchorSource: anchorSource,
      sizeSource: sizeSource,
      headEulerAngleX: face.headEulerAngleX,
      headEulerAngleY: face.headEulerAngleY,
      headEulerAngleZ: face.headEulerAngleZ,
    );
  }

  static Offset? _pointOf(Face face, FaceLandmarkType type) {
    final lm = face.landmarks[type];
    if (lm == null) return null;
    return Offset(lm.position.x.toDouble(), lm.position.y.toDouble());
  }

  static Offset? _eyeMidpoint(Face face) {
    final l = _pointOf(face, FaceLandmarkType.leftEye);
    final r = _pointOf(face, FaceLandmarkType.rightEye);
    if (l == null || r == null) return null;
    return Offset((l.dx + r.dx) / 2.0, (l.dy + r.dy) / 2.0);
  }
}