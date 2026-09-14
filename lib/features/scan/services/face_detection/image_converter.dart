import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class ImageConverter {
  const ImageConverter._();

  static InputImageRotation sensorOrientationToInputRotation(
    int sensorOrientation,
  ) {
    switch (sensorOrientation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation90deg;
    }
  }

  /// Convert [CameraImage] (YUV420) -> [InputImage] (NV21) cho ML Kit.
  static InputImage? toInputImage(
    CameraImage image,
    InputImageRotation rotation,
  ) {
    try {
      return InputImage.fromBytes(
        bytes: yuv420ToNv21(image),
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.nv21,
          bytesPerRow: image.width,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  static Uint8List yuv420ToNv21(CameraImage image) {
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final width = image.width;
    final height = image.height;
    final uvWidth = width ~/ 2;
    final uvHeight = height ~/ 2;

    final nv21 = Uint8List(width * height + uvWidth * uvHeight * 2);

    int idx = 0;
    for (int row = 0; row < height; row++) {
      final rowStart = row * yPlane.bytesPerRow;
      nv21.setRange(idx, idx + width, yPlane.bytes, rowStart);
      idx += width;
    }

    final pixelStride = uPlane.bytesPerPixel ?? 2;
    final rowStride = uPlane.bytesPerRow;
    for (int row = 0; row < uvHeight; row++) {
      for (int col = 0; col < uvWidth; col++) {
        final uvIdx = row * rowStride + col * pixelStride;
        if (uvIdx < vPlane.bytes.length && uvIdx < uPlane.bytes.length) {
          nv21[idx++] = vPlane.bytes[uvIdx];
          nv21[idx++] = uPlane.bytes[uvIdx];
        }
      }
    }

    return nv21;
  }

  /// Lấy mẫu độ sáng trung bình từ Y-plane .
  static double calculateLuminance(CameraImage image) {
    final yPlane = image.planes.first.bytes;
    if (yPlane.isEmpty) return 0;
    int sum = 0;
    for (int i = 0; i < yPlane.length; i += 50) {
      sum += yPlane[i];
    }
    return sum / (yPlane.length / 50);
  }
}