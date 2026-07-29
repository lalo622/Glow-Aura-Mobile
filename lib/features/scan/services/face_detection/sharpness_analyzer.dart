import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;


class SharpnessAnalyzer {
  const SharpnessAnalyzer._();

  static const double sharpnessThreshold = 80.0;
  static const double faceRoiMarginRatio = 0.15;
  static const int roiStride = 2;

  static Rect mapRotatedRectToRawRect(
    Rect rotatedRect,
    int rawWidth,
    int rawHeight,
    InputImageRotation rotation,
  ) {
    switch (rotation) {
      case InputImageRotation.rotation90deg:
        return Rect.fromLTRB(
          rotatedRect.top,
          rawWidth - rotatedRect.right,
          rotatedRect.bottom,
          rawWidth - rotatedRect.left,
        );
      case InputImageRotation.rotation270deg:
        return Rect.fromLTRB(
          rawHeight - rotatedRect.bottom,
          rotatedRect.left,
          rawHeight - rotatedRect.top,
          rotatedRect.right,
        );
      case InputImageRotation.rotation180deg:
        return Rect.fromLTRB(
          rawWidth - rotatedRect.right,
          rawHeight - rotatedRect.bottom,
          rawWidth - rotatedRect.left,
          rawHeight - rotatedRect.top,
        );
      case InputImageRotation.rotation0deg:
        return rotatedRect;
    }
  }

  static Rect expandRoi(
    Rect rect,
    double marginRatio,
    int maxWidth,
    int maxHeight,
  ) {
    final dx = rect.width * marginRatio;
    final dy = rect.height * marginRatio;
    return Rect.fromLTRB(
      (rect.left - dx).clamp(0, maxWidth.toDouble()),
      (rect.top - dy).clamp(0, maxHeight.toDouble()),
      (rect.right + dx).clamp(0, maxWidth.toDouble()),
      (rect.bottom + dy).clamp(0, maxHeight.toDouble()),
    );
  }

  /// Tính độ nét (phương sai Laplacian) trong vùng [roi] của Y-plane.
  static double calculateSharpnessInRegion(CameraImage image, Rect roi) {
    final bytes = image.planes[0].bytes; // Y plane
    final rowStride = image.planes[0].bytesPerRow;
    final width = image.width;
    final height = image.height;

    final left = roi.left.clamp(1, width - 2).toInt();
    final top = roi.top.clamp(1, height - 2).toInt();
    final right = roi.right.clamp(left + 1, width - 2).toInt();
    final bottom = roi.bottom.clamp(top + 1, height - 2).toInt();

  if (right <= left || bottom <= top) return 0.0;

    const step = roiStride;

    double sum = 0, sumSq = 0;
    int count = 0;

    for (int y = top; y < bottom; y += step) {
      final rowOffset = y * rowStride;
      final upOffset = (y - 1) * rowStride;
      final downOffset = (y + 1) * rowStride;

      for (int x = left; x < right; x += step) {
        final center = bytes[rowOffset + x];
        final up = bytes[upOffset + x];
        final down = bytes[downOffset + x];
        final l = bytes[rowOffset + x - 1];
        final r = bytes[rowOffset + x + 1];

        final lap = (4 * center - up - down - l - r).toDouble();
        sum += lap;
        sumSq += lap * lap;
        count++;
      }
    }

    if (count == 0) return 0.0;
    final mean = sum / count;
    return (sumSq / count) - (mean * mean);
  }
}

/// Tính độ nét của 1 ảnh JPEG đã chụp 
double computeJpegSharpness(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return 0.0;

  final resized = img.copyResize(decoded, width: 480);
  final gray = img.grayscale(resized);

  final width = gray.width;
  final height = gray.height;

  double sum = 0, sumSq = 0;
  int count = 0;

  for (int y = 1; y < height - 1; y++) {
    for (int x = 1; x < width - 1; x++) {
      final center = gray.getPixel(x, y).r.toDouble();
      final up = gray.getPixel(x, y - 1).r.toDouble();
      final down = gray.getPixel(x, y + 1).r.toDouble();
      final left = gray.getPixel(x - 1, y).r.toDouble();
      final right = gray.getPixel(x + 1, y).r.toDouble();

      final lap = 4 * center - up - down - left - right;
      sum += lap;
      sumSq += lap * lap;
      count++;
    }
  }

  if (count == 0) return 0.0;
  final mean = sum / count;
  return (sumSq / count) - (mean * mean);
}