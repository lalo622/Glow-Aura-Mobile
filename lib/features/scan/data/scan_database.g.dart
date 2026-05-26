// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_database.dart';

// ignore_for_file: type=lint
class $ScanRecordsTable extends ScanRecords
    with TableInfo<$ScanRecordsTable, ScanRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _galleryPathMeta =
      const VerificationMeta('galleryPath');
  @override
  late final GeneratedColumn<String> galleryPath = GeneratedColumn<String>(
      'gallery_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _capturedAtMeta =
      const VerificationMeta('capturedAt');
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
      'captured_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _glowScoreMeta =
      const VerificationMeta('glowScore');
  @override
  late final GeneratedColumn<int> glowScore = GeneratedColumn<int>(
      'glow_score', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _metricsJsonMeta =
      const VerificationMeta('metricsJson');
  @override
  late final GeneratedColumn<String> metricsJson = GeneratedColumn<String>(
      'metrics_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _adviceTextMeta =
      const VerificationMeta('adviceText');
  @override
  late final GeneratedColumn<String> adviceText = GeneratedColumn<String>(
      'advice_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncErrorMeta =
      const VerificationMeta('syncError');
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
      'sync_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        imagePath,
        galleryPath,
        capturedAt,
        syncStatus,
        glowScore,
        metricsJson,
        adviceText,
        syncError
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_records';
  @override
  VerificationContext validateIntegrity(Insertable<ScanRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    } else if (isInserting) {
      context.missing(_imagePathMeta);
    }
    if (data.containsKey('gallery_path')) {
      context.handle(
          _galleryPathMeta,
          galleryPath.isAcceptableOrUnknown(
              data['gallery_path']!, _galleryPathMeta));
    }
    if (data.containsKey('captured_at')) {
      context.handle(
          _capturedAtMeta,
          capturedAt.isAcceptableOrUnknown(
              data['captured_at']!, _capturedAtMeta));
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('glow_score')) {
      context.handle(_glowScoreMeta,
          glowScore.isAcceptableOrUnknown(data['glow_score']!, _glowScoreMeta));
    }
    if (data.containsKey('metrics_json')) {
      context.handle(
          _metricsJsonMeta,
          metricsJson.isAcceptableOrUnknown(
              data['metrics_json']!, _metricsJsonMeta));
    }
    if (data.containsKey('advice_text')) {
      context.handle(
          _adviceTextMeta,
          adviceText.isAcceptableOrUnknown(
              data['advice_text']!, _adviceTextMeta));
    }
    if (data.containsKey('sync_error')) {
      context.handle(_syncErrorMeta,
          syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScanRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path'])!,
      galleryPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gallery_path']),
      capturedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}captured_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      glowScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}glow_score']),
      metricsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metrics_json']),
      adviceText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}advice_text']),
      syncError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_error']),
    );
  }

  @override
  $ScanRecordsTable createAlias(String alias) {
    return $ScanRecordsTable(attachedDatabase, alias);
  }
}

class ScanRecord extends DataClass implements Insertable<ScanRecord> {
  final int id;
  final String imagePath;
  final String? galleryPath;
  final DateTime capturedAt;
  final String syncStatus;
  final int? glowScore;
  final String? metricsJson;
  final String? adviceText;
  final String? syncError;
  const ScanRecord(
      {required this.id,
      required this.imagePath,
      this.galleryPath,
      required this.capturedAt,
      required this.syncStatus,
      this.glowScore,
      this.metricsJson,
      this.adviceText,
      this.syncError});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['image_path'] = Variable<String>(imagePath);
    if (!nullToAbsent || galleryPath != null) {
      map['gallery_path'] = Variable<String>(galleryPath);
    }
    map['captured_at'] = Variable<DateTime>(capturedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || glowScore != null) {
      map['glow_score'] = Variable<int>(glowScore);
    }
    if (!nullToAbsent || metricsJson != null) {
      map['metrics_json'] = Variable<String>(metricsJson);
    }
    if (!nullToAbsent || adviceText != null) {
      map['advice_text'] = Variable<String>(adviceText);
    }
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    return map;
  }

  ScanRecordsCompanion toCompanion(bool nullToAbsent) {
    return ScanRecordsCompanion(
      id: Value(id),
      imagePath: Value(imagePath),
      galleryPath: galleryPath == null && nullToAbsent
          ? const Value.absent()
          : Value(galleryPath),
      capturedAt: Value(capturedAt),
      syncStatus: Value(syncStatus),
      glowScore: glowScore == null && nullToAbsent
          ? const Value.absent()
          : Value(glowScore),
      metricsJson: metricsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(metricsJson),
      adviceText: adviceText == null && nullToAbsent
          ? const Value.absent()
          : Value(adviceText),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
    );
  }

  factory ScanRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanRecord(
      id: serializer.fromJson<int>(json['id']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      galleryPath: serializer.fromJson<String?>(json['galleryPath']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      glowScore: serializer.fromJson<int?>(json['glowScore']),
      metricsJson: serializer.fromJson<String?>(json['metricsJson']),
      adviceText: serializer.fromJson<String?>(json['adviceText']),
      syncError: serializer.fromJson<String?>(json['syncError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'imagePath': serializer.toJson<String>(imagePath),
      'galleryPath': serializer.toJson<String?>(galleryPath),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'glowScore': serializer.toJson<int?>(glowScore),
      'metricsJson': serializer.toJson<String?>(metricsJson),
      'adviceText': serializer.toJson<String?>(adviceText),
      'syncError': serializer.toJson<String?>(syncError),
    };
  }

  ScanRecord copyWith(
          {int? id,
          String? imagePath,
          Value<String?> galleryPath = const Value.absent(),
          DateTime? capturedAt,
          String? syncStatus,
          Value<int?> glowScore = const Value.absent(),
          Value<String?> metricsJson = const Value.absent(),
          Value<String?> adviceText = const Value.absent(),
          Value<String?> syncError = const Value.absent()}) =>
      ScanRecord(
        id: id ?? this.id,
        imagePath: imagePath ?? this.imagePath,
        galleryPath: galleryPath.present ? galleryPath.value : this.galleryPath,
        capturedAt: capturedAt ?? this.capturedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        glowScore: glowScore.present ? glowScore.value : this.glowScore,
        metricsJson: metricsJson.present ? metricsJson.value : this.metricsJson,
        adviceText: adviceText.present ? adviceText.value : this.adviceText,
        syncError: syncError.present ? syncError.value : this.syncError,
      );
  ScanRecord copyWithCompanion(ScanRecordsCompanion data) {
    return ScanRecord(
      id: data.id.present ? data.id.value : this.id,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      galleryPath:
          data.galleryPath.present ? data.galleryPath.value : this.galleryPath,
      capturedAt:
          data.capturedAt.present ? data.capturedAt.value : this.capturedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      glowScore: data.glowScore.present ? data.glowScore.value : this.glowScore,
      metricsJson:
          data.metricsJson.present ? data.metricsJson.value : this.metricsJson,
      adviceText:
          data.adviceText.present ? data.adviceText.value : this.adviceText,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanRecord(')
          ..write('id: $id, ')
          ..write('imagePath: $imagePath, ')
          ..write('galleryPath: $galleryPath, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('glowScore: $glowScore, ')
          ..write('metricsJson: $metricsJson, ')
          ..write('adviceText: $adviceText, ')
          ..write('syncError: $syncError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, imagePath, galleryPath, capturedAt,
      syncStatus, glowScore, metricsJson, adviceText, syncError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanRecord &&
          other.id == this.id &&
          other.imagePath == this.imagePath &&
          other.galleryPath == this.galleryPath &&
          other.capturedAt == this.capturedAt &&
          other.syncStatus == this.syncStatus &&
          other.glowScore == this.glowScore &&
          other.metricsJson == this.metricsJson &&
          other.adviceText == this.adviceText &&
          other.syncError == this.syncError);
}

class ScanRecordsCompanion extends UpdateCompanion<ScanRecord> {
  final Value<int> id;
  final Value<String> imagePath;
  final Value<String?> galleryPath;
  final Value<DateTime> capturedAt;
  final Value<String> syncStatus;
  final Value<int?> glowScore;
  final Value<String?> metricsJson;
  final Value<String?> adviceText;
  final Value<String?> syncError;
  const ScanRecordsCompanion({
    this.id = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.galleryPath = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.glowScore = const Value.absent(),
    this.metricsJson = const Value.absent(),
    this.adviceText = const Value.absent(),
    this.syncError = const Value.absent(),
  });
  ScanRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String imagePath,
    this.galleryPath = const Value.absent(),
    required DateTime capturedAt,
    this.syncStatus = const Value.absent(),
    this.glowScore = const Value.absent(),
    this.metricsJson = const Value.absent(),
    this.adviceText = const Value.absent(),
    this.syncError = const Value.absent(),
  })  : imagePath = Value(imagePath),
        capturedAt = Value(capturedAt);
  static Insertable<ScanRecord> custom({
    Expression<int>? id,
    Expression<String>? imagePath,
    Expression<String>? galleryPath,
    Expression<DateTime>? capturedAt,
    Expression<String>? syncStatus,
    Expression<int>? glowScore,
    Expression<String>? metricsJson,
    Expression<String>? adviceText,
    Expression<String>? syncError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (imagePath != null) 'image_path': imagePath,
      if (galleryPath != null) 'gallery_path': galleryPath,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (glowScore != null) 'glow_score': glowScore,
      if (metricsJson != null) 'metrics_json': metricsJson,
      if (adviceText != null) 'advice_text': adviceText,
      if (syncError != null) 'sync_error': syncError,
    });
  }

  ScanRecordsCompanion copyWith(
      {Value<int>? id,
      Value<String>? imagePath,
      Value<String?>? galleryPath,
      Value<DateTime>? capturedAt,
      Value<String>? syncStatus,
      Value<int?>? glowScore,
      Value<String?>? metricsJson,
      Value<String?>? adviceText,
      Value<String?>? syncError}) {
    return ScanRecordsCompanion(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      galleryPath: galleryPath ?? this.galleryPath,
      capturedAt: capturedAt ?? this.capturedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      glowScore: glowScore ?? this.glowScore,
      metricsJson: metricsJson ?? this.metricsJson,
      adviceText: adviceText ?? this.adviceText,
      syncError: syncError ?? this.syncError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (galleryPath.present) {
      map['gallery_path'] = Variable<String>(galleryPath.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (glowScore.present) {
      map['glow_score'] = Variable<int>(glowScore.value);
    }
    if (metricsJson.present) {
      map['metrics_json'] = Variable<String>(metricsJson.value);
    }
    if (adviceText.present) {
      map['advice_text'] = Variable<String>(adviceText.value);
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanRecordsCompanion(')
          ..write('id: $id, ')
          ..write('imagePath: $imagePath, ')
          ..write('galleryPath: $galleryPath, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('glowScore: $glowScore, ')
          ..write('metricsJson: $metricsJson, ')
          ..write('adviceText: $adviceText, ')
          ..write('syncError: $syncError')
          ..write(')'))
        .toString();
  }
}

abstract class _$ScanDatabase extends GeneratedDatabase {
  _$ScanDatabase(QueryExecutor e) : super(e);
  $ScanDatabaseManager get managers => $ScanDatabaseManager(this);
  late final $ScanRecordsTable scanRecords = $ScanRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [scanRecords];
}

typedef $$ScanRecordsTableCreateCompanionBuilder = ScanRecordsCompanion
    Function({
  Value<int> id,
  required String imagePath,
  Value<String?> galleryPath,
  required DateTime capturedAt,
  Value<String> syncStatus,
  Value<int?> glowScore,
  Value<String?> metricsJson,
  Value<String?> adviceText,
  Value<String?> syncError,
});
typedef $$ScanRecordsTableUpdateCompanionBuilder = ScanRecordsCompanion
    Function({
  Value<int> id,
  Value<String> imagePath,
  Value<String?> galleryPath,
  Value<DateTime> capturedAt,
  Value<String> syncStatus,
  Value<int?> glowScore,
  Value<String?> metricsJson,
  Value<String?> adviceText,
  Value<String?> syncError,
});

class $$ScanRecordsTableFilterComposer
    extends Composer<_$ScanDatabase, $ScanRecordsTable> {
  $$ScanRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get galleryPath => $composableBuilder(
      column: $table.galleryPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get glowScore => $composableBuilder(
      column: $table.glowScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metricsJson => $composableBuilder(
      column: $table.metricsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get adviceText => $composableBuilder(
      column: $table.adviceText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncError => $composableBuilder(
      column: $table.syncError, builder: (column) => ColumnFilters(column));
}

class $$ScanRecordsTableOrderingComposer
    extends Composer<_$ScanDatabase, $ScanRecordsTable> {
  $$ScanRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get galleryPath => $composableBuilder(
      column: $table.galleryPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get glowScore => $composableBuilder(
      column: $table.glowScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metricsJson => $composableBuilder(
      column: $table.metricsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get adviceText => $composableBuilder(
      column: $table.adviceText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncError => $composableBuilder(
      column: $table.syncError, builder: (column) => ColumnOrderings(column));
}

class $$ScanRecordsTableAnnotationComposer
    extends Composer<_$ScanDatabase, $ScanRecordsTable> {
  $$ScanRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get galleryPath => $composableBuilder(
      column: $table.galleryPath, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<int> get glowScore =>
      $composableBuilder(column: $table.glowScore, builder: (column) => column);

  GeneratedColumn<String> get metricsJson => $composableBuilder(
      column: $table.metricsJson, builder: (column) => column);

  GeneratedColumn<String> get adviceText => $composableBuilder(
      column: $table.adviceText, builder: (column) => column);

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);
}

class $$ScanRecordsTableTableManager extends RootTableManager<
    _$ScanDatabase,
    $ScanRecordsTable,
    ScanRecord,
    $$ScanRecordsTableFilterComposer,
    $$ScanRecordsTableOrderingComposer,
    $$ScanRecordsTableAnnotationComposer,
    $$ScanRecordsTableCreateCompanionBuilder,
    $$ScanRecordsTableUpdateCompanionBuilder,
    (ScanRecord, BaseReferences<_$ScanDatabase, $ScanRecordsTable, ScanRecord>),
    ScanRecord,
    PrefetchHooks Function()> {
  $$ScanRecordsTableTableManager(_$ScanDatabase db, $ScanRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> imagePath = const Value.absent(),
            Value<String?> galleryPath = const Value.absent(),
            Value<DateTime> capturedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int?> glowScore = const Value.absent(),
            Value<String?> metricsJson = const Value.absent(),
            Value<String?> adviceText = const Value.absent(),
            Value<String?> syncError = const Value.absent(),
          }) =>
              ScanRecordsCompanion(
            id: id,
            imagePath: imagePath,
            galleryPath: galleryPath,
            capturedAt: capturedAt,
            syncStatus: syncStatus,
            glowScore: glowScore,
            metricsJson: metricsJson,
            adviceText: adviceText,
            syncError: syncError,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String imagePath,
            Value<String?> galleryPath = const Value.absent(),
            required DateTime capturedAt,
            Value<String> syncStatus = const Value.absent(),
            Value<int?> glowScore = const Value.absent(),
            Value<String?> metricsJson = const Value.absent(),
            Value<String?> adviceText = const Value.absent(),
            Value<String?> syncError = const Value.absent(),
          }) =>
              ScanRecordsCompanion.insert(
            id: id,
            imagePath: imagePath,
            galleryPath: galleryPath,
            capturedAt: capturedAt,
            syncStatus: syncStatus,
            glowScore: glowScore,
            metricsJson: metricsJson,
            adviceText: adviceText,
            syncError: syncError,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ScanRecordsTableProcessedTableManager = ProcessedTableManager<
    _$ScanDatabase,
    $ScanRecordsTable,
    ScanRecord,
    $$ScanRecordsTableFilterComposer,
    $$ScanRecordsTableOrderingComposer,
    $$ScanRecordsTableAnnotationComposer,
    $$ScanRecordsTableCreateCompanionBuilder,
    $$ScanRecordsTableUpdateCompanionBuilder,
    (ScanRecord, BaseReferences<_$ScanDatabase, $ScanRecordsTable, ScanRecord>),
    ScanRecord,
    PrefetchHooks Function()>;

class $ScanDatabaseManager {
  final _$ScanDatabase _db;
  $ScanDatabaseManager(this._db);
  $$ScanRecordsTableTableManager get scanRecords =>
      $$ScanRecordsTableTableManager(_db, _db.scanRecords);
}
