import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
part 'scan_database.g.dart';

enum ScanSyncStatus {
  pending,   
  uploading, 
  synced,    
  failed,    
}

class ScanRecords extends Table {
  IntColumn    get id          => integer().autoIncrement()();
  TextColumn   get imagePath   => text()();
  TextColumn   get galleryPath => text().nullable()();
  DateTimeColumn get capturedAt => dateTime()();
  TextColumn   get syncStatus  => text().withDefault(const Constant('pending'))();
  IntColumn    get glowScore   => integer().nullable()();
  TextColumn   get metricsJson => text().nullable()();
  TextColumn   get adviceText  => text().nullable()();
  TextColumn   get syncError   => text().nullable()();
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

  Future<ScanRecord?> getScanById(int id) =>
      (select(scanRecords)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<ScanRecord>> getAllScans() =>
      (select(scanRecords)..orderBy([(t) => OrderingTerm.desc(t.capturedAt)])).get();

  Stream<List<ScanRecord>> watchAllScans() =>
      (select(scanRecords)..orderBy([(t) => OrderingTerm.desc(t.capturedAt)])).watch();

  Future<List<ScanRecord>> getPendingScans() =>
      (select(scanRecords)
        ..where((t) => t.syncStatus.equals('pending') | t.syncStatus.equals('failed')))
          .get();

  // ── Update ─────────────────────────────────────────────────────────────────

  Future<void> updateScanResult({
    required int    id,
    required int    glowScore,
    required String metricsJson,
    required String adviceText,
  }) =>
      (update(scanRecords)..where((t) => t.id.equals(id))).write(
        ScanRecordsCompanion(
          glowScore:   Value(glowScore),
          metricsJson: Value(metricsJson),
          adviceText:  Value(adviceText),
          syncStatus:  const Value('synced'),
          syncError:   const Value(null),
        ),
      );

  Future<void> updateSyncStatus(
    int id,
    ScanSyncStatus status, {
    String? error,
  }) =>
      (update(scanRecords)..where((t) => t.id.equals(id))).write(
        ScanRecordsCompanion(
          syncStatus: Value(status.name),
          syncError:  Value(error),
        ),
      );

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<void> deleteScan(int id) =>
      (delete(scanRecords)..where((t) => t.id.equals(id))).go();

  // ── Cleanup ────────────────────────────────────────────────────────────────

  Future<void> cleanOldScans({int keepDays = 30}) async {
    final cutoff = DateTime.now().subtract(Duration(days: keepDays));

    final old = await (select(scanRecords)
          ..where((t) => t.capturedAt.isSmallerThanValue(cutoff)))
        .get();

    for (final scan in old) {
      // Xóa file ảnh local trước
      try {
        final f = File(scan.imagePath);
        if (await f.exists()) await f.delete();
      } catch (_) {}

      // Xóa record khỏi DB
      await deleteScan(scan.id);
    }
  }

  Future<int> calculateStorageUsed() async {
    final scans = await getAllScans();
    int total = 0;
    for (final scan in scans) {
      try {
        final f = File(scan.imagePath);
        if (await f.exists()) total += await f.length();
      } catch (_) {}
    }
    return total;
  }
}

// ── Singleton connection ───────────────────────────────────────────────────────

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir  = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'glow_aura_scan.db'));
    return NativeDatabase.createInBackground(file);
  });
}


final scanDatabaseProvider = Provider<ScanDatabase>((ref) {
  final db = ScanDatabase();
  ref.onDispose(db.close); 
  return db;
});