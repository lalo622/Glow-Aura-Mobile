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
  IntColumn get id => integer().autoIncrement()();

  // Có default để migration từ DB cũ không bị lỗi.
  TextColumn get userId =>
      text().withDefault(const Constant('unknown'))();

  TextColumn get imagePath => text()();

  TextColumn get galleryPath => text().nullable()();

  DateTimeColumn get capturedAt => dateTime()();

  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();

  IntColumn get glowScore => integer().nullable()();

  TextColumn get metricsJson => text().nullable()();

  TextColumn get adviceText => text().nullable()();

  TextColumn get syncError => text().nullable()();

  TextColumn get sessionId => text().nullable()();
}

@DriftDatabase(tables: [ScanRecords])
class ScanDatabase extends _$ScanDatabase {
  ScanDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),

        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // ignore: experimental_member_use
            await m.alterTable(TableMigration(scanRecords));
          }

          if (from < 3) {
            await m.addColumn(
              scanRecords,
              scanRecords.userId,
            );
          }
        },
      );

  // ── Insert ────────────────────────────────────────────────────────────────

  Future<int> insertScan({
    required String userId,
    required String imagePath,
    String? galleryPath,
  }) {
    return into(scanRecords).insert(
      ScanRecordsCompanion.insert(
        userId: Value(userId),
        imagePath: imagePath,
        galleryPath: Value(galleryPath),
        capturedAt: DateTime.now(),
        syncStatus: const Value('pending'),
      ),
    );
  }

  // ── Query ─────────────────────────────────────────────────────────────────

  Future<ScanRecord?> getScanById(
    int id,
    String userId,
  ) {
    return (select(scanRecords)
          ..where(
            (t) =>
                t.id.equals(id) &
                t.userId.equals(userId),
          ))
        .getSingleOrNull();
  }

  Future<List<ScanRecord>> getAllScans(String userId) {
    return (select(scanRecords)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.capturedAt),
          ]))
        .get();
  }

  Stream<List<ScanRecord>> watchAllScans(String userId) {
    return (select(scanRecords)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.capturedAt),
          ]))
        .watch();
  }

  Future<List<ScanRecord>> getPendingScans(String userId) {
    return (select(scanRecords)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                (t.syncStatus.equals('pending') |
                    t.syncStatus.equals('failed')),
          ))
        .get();
  }

  /// Lấy imagePath theo sessionId để hiển thị ảnh trong history grid.
  Future<String?> getImagePathBySessionId(
    String sessionId,
    String userId,
  ) async {
    final row = await (select(scanRecords)
          ..where(
            (t) =>
                t.sessionId.equals(sessionId) &
                t.userId.equals(userId),
          )
          ..limit(1))
        .getSingleOrNull();

    return row?.imagePath;
  }

  // ── Update ────────────────────────────────────────────────────────────────

  Future<void> updateScanResult({
    required int id,
    required int glowScore,
    required String metricsJson,
    required String adviceText,
    required String sessionId,
  }) {
    return (update(scanRecords)
          ..where((t) => t.id.equals(id)))
        .write(
      ScanRecordsCompanion(
        glowScore: Value(glowScore),
        metricsJson: Value(metricsJson),
        adviceText: Value(adviceText),
        syncStatus: const Value('synced'),
        syncError: const Value(null),
        sessionId: Value(sessionId),
      ),
    );
  }

  Future<void> updateSyncStatus(
    int id,
    ScanSyncStatus status, {
    String? error,
  }) {
    return (update(scanRecords)
          ..where((t) => t.id.equals(id)))
        .write(
      ScanRecordsCompanion(
        syncStatus: Value(status.name),
        syncError: Value(error),
      ),
    );
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteScan(int id) {
    return (delete(scanRecords)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  // ── Cleanup ───────────────────────────────────────────────────────────────

  Future<void> cleanOldScans({
    int keepDays = 30,
  }) async {
    final cutoff =
        DateTime.now().subtract(Duration(days: keepDays));

    final old = await (select(scanRecords)
          ..where(
            (t) => t.capturedAt.isSmallerThanValue(cutoff),
          ))
        .get();

    for (final scan in old) {
      try {
        final f = File(scan.imagePath);

        if (await f.exists()) {
          await f.delete();
        }
      } catch (_) {}

      await deleteScan(scan.id);
    }
  }

  Future<int> calculateStorageUsed(String userId) async {
    final scans = await getAllScans(userId);

    int total = 0;

    for (final scan in scans) {
      try {
        final f = File(scan.imagePath);

        if (await f.exists()) {
          total += await f.length();
        }
      } catch (_) {}
    }

    return total;
  }

  Future<String?> getImagePathNearTime(
    DateTime capturedAt,
    String userId,
  ) async {
    final from =
        capturedAt.subtract(const Duration(minutes: 5));

    final to =
        capturedAt.add(const Duration(minutes: 5));

    final row = await (select(scanRecords)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.capturedAt.isBetweenValues(from, to) &
                t.imagePath.isNotValue(''),
          )
          ..limit(1))
        .getSingleOrNull();

    return row?.imagePath;
  }
}

// ── Singleton connection ─────────────────────────────────────────────────────

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();

    final file = File(
      p.join(dir.path, 'glow_aura_scan.db'),
    );

    return NativeDatabase.createInBackground(file);
  });
}

final scanDatabaseProvider = Provider<ScanDatabase>((ref) {
  final db = ScanDatabase();

  ref.onDispose(db.close);

  return db;
});