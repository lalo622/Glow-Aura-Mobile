import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
part 'scan_database.g.dart';


enum ScanSyncStatus {
  pending,   // chưa gửi BE (mới lưu local)
  uploading, // đang gửi
  synced,    // BE đã nhận và trả kết quả
  failed,    // gửi thất bại → có thể retry
}



/// Table lưu lịch sử mỗi lần scan
class ScanRecords extends Table {
  // Primary key — auto increment
  IntColumn get id => integer().autoIncrement()();

  // Đường dẫn ảnh local (app documents dir)
  TextColumn get imagePath => text()();

  // Đường dẫn ảnh trong Gallery (null nếu lưu gallery thất bại)
  TextColumn get galleryPath => text().nullable()();

  // Thời điểm chụp
  DateTimeColumn get capturedAt => dateTime()();

  // Sync status — lưu dạng string để Drift không cần converter phức tạp
  // Giá trị: "pending" | "uploading" | "synced" | "failed"
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  // ── Kết quả từ BE (nullable — chưa có khi pending) ────────────────────────

  // Tổng điểm Glow Aura (0–100)
  IntColumn get glowScore => integer().nullable()();

  // Điểm từng metric 
  // Format: {"brightness": 82, "evenness": 78, "texture": 90}
  TextColumn get metricsJson => text().nullable()();

  // Lời khuyên từ AI
  TextColumn get adviceText => text().nullable()();

  TextColumn get syncError => text().nullable()();
}


@DriftDatabase(tables: [ScanRecords])
class ScanDatabase extends _$ScanDatabase {
  ScanDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ── Insert ─────────────────────────────────────────────────────────────────

  Future<int> insertScan({
    required String imagePath,
    String? galleryPath,
  }) {
    return into(scanRecords).insert(
      ScanRecordsCompanion.insert(
        imagePath:   imagePath,
        galleryPath: Value(galleryPath),
        capturedAt:  DateTime.now(),
        syncStatus:  const Value('pending'),
      ),
    );
  }

  // ── Query ──────────────────────────────────────────────────────────────────

  /// Lấy 1 record theo id
  Future<ScanRecord?> getScanById(int id) {
    return (select(scanRecords)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Lấy toàn bộ lịch sử, mới nhất trước
  Future<List<ScanRecord>> getAllScans() {
    return (select(scanRecords)
          ..orderBy([(t) => OrderingTerm.desc(t.capturedAt)]))
        .get();
  }

  /// Watch lịch sử — dùng cho History screen (reactive)
  Stream<List<ScanRecord>> watchAllScans() {
    return (select(scanRecords)
          ..orderBy([(t) => OrderingTerm.desc(t.capturedAt)]))
        .watch();
  }

  /// Lấy các record chưa sync (để retry sau)
  Future<List<ScanRecord>> getPendingScans() {
    return (select(scanRecords)
          ..where((t) => t.syncStatus.equals('pending') |
              t.syncStatus.equals('failed')))
        .get();
  }

  // ── Update ─────────────────────────────────────────────────────────────────

  /// Update sau khi BE trả kết quả thành công
  Future<void> updateScanResult({
    required int id,
    required int glowScore,
    required String metricsJson,
    required String adviceText,
  }) {
    return (update(scanRecords)..where((t) => t.id.equals(id))).write(
      ScanRecordsCompanion(
        glowScore:   Value(glowScore),
        metricsJson: Value(metricsJson),
        adviceText:  Value(adviceText),
        syncStatus:  const Value('synced'),
        syncError:   const Value(null),
      ),
    );
  }

  /// Update sync status (uploading / failed)
  Future<void> updateSyncStatus(int id, ScanSyncStatus status,
      {String? error}) {
    return (update(scanRecords)..where((t) => t.id.equals(id))).write(
      ScanRecordsCompanion(
        syncStatus: Value(status.name),
        syncError:  Value(error),
      ),
    );
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<void> deleteScan(int id) {
    return (delete(scanRecords)..where((t) => t.id.equals(id))).go();
  }
}

// DB connection helper
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir  = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'glow_aura_scan.db'));
    return NativeDatabase.createInBackground(file);
  });
}