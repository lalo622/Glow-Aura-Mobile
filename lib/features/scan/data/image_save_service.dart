import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'scan_database.dart';

class SaveScanResult {
  final int     scanId;
  final String  localPath;
  final bool    savedToGallery;

  const SaveScanResult({
    required this.scanId,
    required this.localPath,
    required this.savedToGallery,
  });
}

class ImageSaveService {
  final ScanDatabase _db;

  ImageSaveService(this._db);

  // ── Save ───────────────────────────────────────────────────────────────────

  Future<SaveScanResult> saveScan(String tempImagePath) async {
  
    final localPath = await _copyToDocuments(tempImagePath);
    debugPrint('[ImageSaveService] Copied to: $localPath');

    
    try {
      await File(tempImagePath).delete();
      debugPrint('[ImageSaveService] Temp file deleted ✓');
    } catch (e) {
      debugPrint('[ImageSaveService] Could not delete temp file: $e');
    }

    try {
      await Gal.putImage(localPath, album: 'Glow Aura');
      savedToGallery = true;
      debugPrint('[ImageSaveService] Saved to gallery ✓');
    } catch (e) {
      debugPrint('[ImageSaveService] Gallery save failed (non-fatal): $e');
    }

    final scanId = await _db.insertScan(
      imagePath:   localPath,
      galleryPath: null,
    );
    debugPrint('[ImageSaveService] Drift insert id=$scanId ✓');


    return SaveScanResult(
      scanId:         scanId,
      localPath:      localPath,
      savedToGallery: savedToGallery,
    );
  }

  // ── Copy to documents ──────────────────────────────────────────────────────

  Future<String> _copyToDocuments(String tempPath) async {
    final dir      = await getApplicationDocumentsDirectory();
    final scansDir = Directory(p.join(dir.path, 'scans'));
    if (!await scansDir.exists()) await scansDir.create(recursive: true);

    final fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final destPath = p.join(scansDir.path, fileName);

    await File(tempPath).copy(destPath);
    return destPath;
  }

  // ── Upload to backend ──────────────────────────────────────────────────────

  // ignore: unused_element
  Future<void> _uploadToBackend(int scanId, String imagePath) async {
    try {
      await _db.updateSyncStatus(scanId, ScanSyncStatus.uploading);

      // TODO: thay bằng Dio multipart khi BE sẵn sàng
      //
      // final token = await TokenStorage.getAccessToken();
      // final formData = FormData.fromMap({
      //   'image': await MultipartFile.fromFile(imagePath, filename: 'scan.jpg'),
      // });
      // final response = await ApiClient.instance.post(
      //   '/scan/upload',
      //   data: formData,
      //   options: Options(
      //     headers: {'Authorization': 'Bearer $token'},
      //     sendTimeout: const Duration(seconds: 30),  // ← timeout upload
      //     receiveTimeout: const Duration(seconds: 30),
      //   ),
      // );
      // final body = response.data as Map<String, dynamic>;
      // await _db.updateScanResult(
      //   id:          scanId,
      //   glowScore:   body['glowScore'] as int,
      //   metricsJson: jsonEncode(body['metrics']),
      //   adviceText:  body['advice'] as String,
      // );

      debugPrint('[ImageSaveService] Upload placeholder — BE not connected yet');
    } on TimeoutException {
      debugPrint('[ImageSaveService] Upload timeout');
      await _db.updateSyncStatus(scanId, ScanSyncStatus.failed,
          error: 'Upload timeout sau 30 giây');
    } catch (e) {
      debugPrint('[ImageSaveService] Upload failed: $e');
      await _db.updateSyncStatus(scanId, ScanSyncStatus.failed,
          error: e.toString());
    }
  }

  Future<void> retryPendingUploads() async {
    final pending = await _db.getPendingScans();
    if (pending.isEmpty) return;

    debugPrint('[ImageSaveService] Retrying ${pending.length} pending scans');
    for (final scan in pending) {
      // Kiểm tra file còn tồn tại không trước khi retry
      final fileExists = await File(scan.imagePath).exists();
      if (!fileExists) {
        // File đã bị xóa — đánh dấu failed để không retry mãi
        await _db.updateSyncStatus(scan.id, ScanSyncStatus.failed,
            error: 'File ảnh không còn tồn tại');
        continue;
      }
      // TODO: bỏ comment khi BE sẵn sàng
      // await _uploadToBackend(scan.id, scan.imagePath);
    }
  }
}

// ── Riverpod provider ─────────────────────────────────────────────────────────

final imageSaveServiceProvider = Provider<ImageSaveService>((ref) {
  return ImageSaveService(ref.watch(scanDatabaseProvider));
});