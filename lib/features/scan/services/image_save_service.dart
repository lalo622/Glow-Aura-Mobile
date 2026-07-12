import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/scan_database.dart';

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

    bool savedToGallery = false;
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

    // Tên file = timestamp → không bao giờ trùng
    final fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final destPath = p.join(scansDir.path, fileName);

    await File(tempPath).copy(destPath);
    return destPath;
  }

  // ── Retry pending (chỉ dọn dẹp record hỏng, upload thật do SkinAnalysisService đảm nhiệm) ──

  Future<void> retryPendingUploads() async {
    final pending = await _db.getPendingScans();
    if (pending.isEmpty) return;

    debugPrint('[ImageSaveService] Checking ${pending.length} pending scans');
    for (final scan in pending) {
      final fileExists = await File(scan.imagePath).exists();
      if (!fileExists) {
        await _db.updateSyncStatus(scan.id, ScanSyncStatus.failed,
            error: 'File ảnh không còn tồn tại');
      }
    }
  }
}

final imageSaveServiceProvider = Provider<ImageSaveService>((ref) {
  return ImageSaveService(ref.watch(scanDatabaseProvider));
});