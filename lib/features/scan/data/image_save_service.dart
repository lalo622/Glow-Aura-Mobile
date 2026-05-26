import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'scan_database.dart';

class SaveScanResult {
  final int    scanId;       
  final String localPath;   // path trong app documents
  final bool   savedToGallery;
  final String? galleryPath;

  const SaveScanResult({
    required this.scanId,
    required this.localPath,
    required this.savedToGallery,
    this.galleryPath,
  });
}

class ImageSaveService {
  final ScanDatabase _db;

  ImageSaveService(this._db);

  Future<SaveScanResult> saveScan(String tempImagePath) async {
    final localPath = await _copyToDocuments(tempImagePath);
    debugPrint('[ImageSaveService] Copied to: $localPath');

    // ──  Lưu Gallery ─────────────────────────────────────────────────
    String? galleryPath;
    bool savedToGallery = false;
    try {
      await Gal.putImage(localPath, album: 'Glow Aura');
      savedToGallery = true;
      galleryPath    = localPath; 
      debugPrint('[ImageSaveService] Saved to gallery ✓');
    } catch (e) {
      debugPrint('[ImageSaveService] Gallery save failed: $e');
    }

    // ── Insert Drift ─────────────────────────────────────────────────
    final scanId = await _db.insertScan(
      imagePath:   localPath,
      galleryPath: galleryPath,
    );
    debugPrint('[ImageSaveService] Drift insert id=$scanId ✓');

    // ──  Background upload (placeholder) ──────────────────────────────
    // TODO: uncomment khi BE sẵn sàng
    // _uploadToBackend(scanId, localPath);

    return SaveScanResult(
      scanId:         scanId,
      localPath:      localPath,
      savedToGallery: savedToGallery,
      galleryPath:    galleryPath,
    );
  }

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


  // ignore: unused_element
  Future<void> _uploadToBackend(int scanId, String imagePath) async {
    try {
      await _db.updateSyncStatus(scanId, ScanSyncStatus.uploading);

      // TODO: thay bằng API call 
      // final request = http.MultipartRequest(
      //   'POST',
      //   Uri.parse('https://hehehe/api/scan/heheh'),
      // );
      // request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      // request.headers['Authorization'] = 'Bearer $token';
      // final response = await request.send();
      // final body = await http.Response.fromStream(response);
      //
      // if (response.statusCode == 200) {
      //   final json = jsonDecode(body.body);
      //   await _db.updateScanResult(
      //     id:          scanId,
      //     glowScore:   json['glowScore'],
      //     metricsJson: jsonEncode(json['metrics']),
      //     adviceText:  json['advice'],
      //   );
      // } else {
      //   throw Exception('BE returned ${response.statusCode}');
      // }

      debugPrint('[ImageSaveService] Upload placeholder — BE not connected yet');
    } catch (e) {
      debugPrint('[ImageSaveService] Upload failed: $e');
      await _db.updateSyncStatus(scanId, ScanSyncStatus.failed, error: e.toString());
    }
  }

  Future<void> retryPendingUploads() async {
    final pending = await _db.getPendingScans();
    debugPrint('[ImageSaveService] Retrying ${pending.length} pending scans');
    for (final scan in pending) {
      // TODO: uncomment cho BE 
      // await _uploadToBackend(scan.id, scan.imagePath);
    }
  }
}