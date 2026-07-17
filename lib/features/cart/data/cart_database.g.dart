// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_database.dart';

// ignore_for_file: type=lint
class $CartItemsTable extends CartItems
    with TableInfo<$CartItemsTable, CartItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CartItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
      'brand', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _volumeMeta = const VerificationMeta('volume');
  @override
  late final GeneratedColumn<String> volume = GeneratedColumn<String>(
      'volume', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
      'price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _originalPriceMeta =
      const VerificationMeta('originalPrice');
  @override
  late final GeneratedColumn<double> originalPrice = GeneratedColumn<double>(
      'original_price', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _stockQuantityMeta =
      const VerificationMeta('stockQuantity');
  @override
  late final GeneratedColumn<int> stockQuantity = GeneratedColumn<int>(
      'stock_quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _addedAtMeta =
      const VerificationMeta('addedAt');
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
      'added_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        productId,
        brand,
        name,
        volume,
        imageUrl,
        price,
        originalPrice,
        stockQuantity,
        quantity,
        addedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cart_items';
  @override
  VerificationContext validateIntegrity(Insertable<CartItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
          _brandMeta, brand.isAcceptableOrUnknown(data['brand']!, _brandMeta));
    } else if (isInserting) {
      context.missing(_brandMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('volume')) {
      context.handle(_volumeMeta,
          volume.isAcceptableOrUnknown(data['volume']!, _volumeMeta));
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('original_price')) {
      context.handle(
          _originalPriceMeta,
          originalPrice.isAcceptableOrUnknown(
              data['original_price']!, _originalPriceMeta));
    }
    if (data.containsKey('stock_quantity')) {
      context.handle(
          _stockQuantityMeta,
          stockQuantity.isAcceptableOrUnknown(
              data['stock_quantity']!, _stockQuantityMeta));
    } else if (isInserting) {
      context.missing(_stockQuantityMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(_addedAtMeta,
          addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta));
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {productId};
  @override
  CartItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CartItem(
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      brand: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}brand'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      volume: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}volume']),
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url']),
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price'])!,
      originalPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}original_price']),
      stockQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stock_quantity'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      addedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}added_at'])!,
    );
  }

  @override
  $CartItemsTable createAlias(String alias) {
    return $CartItemsTable(attachedDatabase, alias);
  }
}

class CartItem extends DataClass implements Insertable<CartItem> {
  final String productId;
  final String brand;
  final String name;
  final String? volume;
  final String? imageUrl;
  final double price;
  final double? originalPrice;
  final int stockQuantity;
  final int quantity;
  final DateTime addedAt;
  const CartItem(
      {required this.productId,
      required this.brand,
      required this.name,
      this.volume,
      this.imageUrl,
      required this.price,
      this.originalPrice,
      required this.stockQuantity,
      required this.quantity,
      required this.addedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['product_id'] = Variable<String>(productId);
    map['brand'] = Variable<String>(brand);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || volume != null) {
      map['volume'] = Variable<String>(volume);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['price'] = Variable<double>(price);
    if (!nullToAbsent || originalPrice != null) {
      map['original_price'] = Variable<double>(originalPrice);
    }
    map['stock_quantity'] = Variable<int>(stockQuantity);
    map['quantity'] = Variable<int>(quantity);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  CartItemsCompanion toCompanion(bool nullToAbsent) {
    return CartItemsCompanion(
      productId: Value(productId),
      brand: Value(brand),
      name: Value(name),
      volume:
          volume == null && nullToAbsent ? const Value.absent() : Value(volume),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      price: Value(price),
      originalPrice: originalPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(originalPrice),
      stockQuantity: Value(stockQuantity),
      quantity: Value(quantity),
      addedAt: Value(addedAt),
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CartItem(
      productId: serializer.fromJson<String>(json['productId']),
      brand: serializer.fromJson<String>(json['brand']),
      name: serializer.fromJson<String>(json['name']),
      volume: serializer.fromJson<String?>(json['volume']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      price: serializer.fromJson<double>(json['price']),
      originalPrice: serializer.fromJson<double?>(json['originalPrice']),
      stockQuantity: serializer.fromJson<int>(json['stockQuantity']),
      quantity: serializer.fromJson<int>(json['quantity']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'productId': serializer.toJson<String>(productId),
      'brand': serializer.toJson<String>(brand),
      'name': serializer.toJson<String>(name),
      'volume': serializer.toJson<String?>(volume),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'price': serializer.toJson<double>(price),
      'originalPrice': serializer.toJson<double?>(originalPrice),
      'stockQuantity': serializer.toJson<int>(stockQuantity),
      'quantity': serializer.toJson<int>(quantity),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  CartItem copyWith(
          {String? productId,
          String? brand,
          String? name,
          Value<String?> volume = const Value.absent(),
          Value<String?> imageUrl = const Value.absent(),
          double? price,
          Value<double?> originalPrice = const Value.absent(),
          int? stockQuantity,
          int? quantity,
          DateTime? addedAt}) =>
      CartItem(
        productId: productId ?? this.productId,
        brand: brand ?? this.brand,
        name: name ?? this.name,
        volume: volume.present ? volume.value : this.volume,
        imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
        price: price ?? this.price,
        originalPrice:
            originalPrice.present ? originalPrice.value : this.originalPrice,
        stockQuantity: stockQuantity ?? this.stockQuantity,
        quantity: quantity ?? this.quantity,
        addedAt: addedAt ?? this.addedAt,
      );
  CartItem copyWithCompanion(CartItemsCompanion data) {
    return CartItem(
      productId: data.productId.present ? data.productId.value : this.productId,
      brand: data.brand.present ? data.brand.value : this.brand,
      name: data.name.present ? data.name.value : this.name,
      volume: data.volume.present ? data.volume.value : this.volume,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      price: data.price.present ? data.price.value : this.price,
      originalPrice: data.originalPrice.present
          ? data.originalPrice.value
          : this.originalPrice,
      stockQuantity: data.stockQuantity.present
          ? data.stockQuantity.value
          : this.stockQuantity,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CartItem(')
          ..write('productId: $productId, ')
          ..write('brand: $brand, ')
          ..write('name: $name, ')
          ..write('volume: $volume, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('price: $price, ')
          ..write('originalPrice: $originalPrice, ')
          ..write('stockQuantity: $stockQuantity, ')
          ..write('quantity: $quantity, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(productId, brand, name, volume, imageUrl,
      price, originalPrice, stockQuantity, quantity, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CartItem &&
          other.productId == this.productId &&
          other.brand == this.brand &&
          other.name == this.name &&
          other.volume == this.volume &&
          other.imageUrl == this.imageUrl &&
          other.price == this.price &&
          other.originalPrice == this.originalPrice &&
          other.stockQuantity == this.stockQuantity &&
          other.quantity == this.quantity &&
          other.addedAt == this.addedAt);
}

class CartItemsCompanion extends UpdateCompanion<CartItem> {
  final Value<String> productId;
  final Value<String> brand;
  final Value<String> name;
  final Value<String?> volume;
  final Value<String?> imageUrl;
  final Value<double> price;
  final Value<double?> originalPrice;
  final Value<int> stockQuantity;
  final Value<int> quantity;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const CartItemsCompanion({
    this.productId = const Value.absent(),
    this.brand = const Value.absent(),
    this.name = const Value.absent(),
    this.volume = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.price = const Value.absent(),
    this.originalPrice = const Value.absent(),
    this.stockQuantity = const Value.absent(),
    this.quantity = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CartItemsCompanion.insert({
    required String productId,
    required String brand,
    required String name,
    this.volume = const Value.absent(),
    this.imageUrl = const Value.absent(),
    required double price,
    this.originalPrice = const Value.absent(),
    required int stockQuantity,
    required int quantity,
    required DateTime addedAt,
    this.rowid = const Value.absent(),
  })  : productId = Value(productId),
        brand = Value(brand),
        name = Value(name),
        price = Value(price),
        stockQuantity = Value(stockQuantity),
        quantity = Value(quantity),
        addedAt = Value(addedAt);
  static Insertable<CartItem> custom({
    Expression<String>? productId,
    Expression<String>? brand,
    Expression<String>? name,
    Expression<String>? volume,
    Expression<String>? imageUrl,
    Expression<double>? price,
    Expression<double>? originalPrice,
    Expression<int>? stockQuantity,
    Expression<int>? quantity,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (productId != null) 'product_id': productId,
      if (brand != null) 'brand': brand,
      if (name != null) 'name': name,
      if (volume != null) 'volume': volume,
      if (imageUrl != null) 'image_url': imageUrl,
      if (price != null) 'price': price,
      if (originalPrice != null) 'original_price': originalPrice,
      if (stockQuantity != null) 'stock_quantity': stockQuantity,
      if (quantity != null) 'quantity': quantity,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CartItemsCompanion copyWith(
      {Value<String>? productId,
      Value<String>? brand,
      Value<String>? name,
      Value<String?>? volume,
      Value<String?>? imageUrl,
      Value<double>? price,
      Value<double?>? originalPrice,
      Value<int>? stockQuantity,
      Value<int>? quantity,
      Value<DateTime>? addedAt,
      Value<int>? rowid}) {
    return CartItemsCompanion(
      productId: productId ?? this.productId,
      brand: brand ?? this.brand,
      name: name ?? this.name,
      volume: volume ?? this.volume,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (volume.present) {
      map['volume'] = Variable<String>(volume.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (originalPrice.present) {
      map['original_price'] = Variable<double>(originalPrice.value);
    }
    if (stockQuantity.present) {
      map['stock_quantity'] = Variable<int>(stockQuantity.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CartItemsCompanion(')
          ..write('productId: $productId, ')
          ..write('brand: $brand, ')
          ..write('name: $name, ')
          ..write('volume: $volume, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('price: $price, ')
          ..write('originalPrice: $originalPrice, ')
          ..write('stockQuantity: $stockQuantity, ')
          ..write('quantity: $quantity, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$CartDatabase extends GeneratedDatabase {
  _$CartDatabase(QueryExecutor e) : super(e);
  $CartDatabaseManager get managers => $CartDatabaseManager(this);
  late final $CartItemsTable cartItems = $CartItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [cartItems];
}

typedef $$CartItemsTableCreateCompanionBuilder = CartItemsCompanion Function({
  required String productId,
  required String brand,
  required String name,
  Value<String?> volume,
  Value<String?> imageUrl,
  required double price,
  Value<double?> originalPrice,
  required int stockQuantity,
  required int quantity,
  required DateTime addedAt,
  Value<int> rowid,
});
typedef $$CartItemsTableUpdateCompanionBuilder = CartItemsCompanion Function({
  Value<String> productId,
  Value<String> brand,
  Value<String> name,
  Value<String?> volume,
  Value<String?> imageUrl,
  Value<double> price,
  Value<double?> originalPrice,
  Value<int> stockQuantity,
  Value<int> quantity,
  Value<DateTime> addedAt,
  Value<int> rowid,
});

class $$CartItemsTableFilterComposer
    extends Composer<_$CartDatabase, $CartItemsTable> {
  $$CartItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get brand => $composableBuilder(
      column: $table.brand, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get volume => $composableBuilder(
      column: $table.volume, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get originalPrice => $composableBuilder(
      column: $table.originalPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stockQuantity => $composableBuilder(
      column: $table.stockQuantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnFilters(column));
}

class $$CartItemsTableOrderingComposer
    extends Composer<_$CartDatabase, $CartItemsTable> {
  $$CartItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get brand => $composableBuilder(
      column: $table.brand, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get volume => $composableBuilder(
      column: $table.volume, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get originalPrice => $composableBuilder(
      column: $table.originalPrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stockQuantity => $composableBuilder(
      column: $table.stockQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnOrderings(column));
}

class $$CartItemsTableAnnotationComposer
    extends Composer<_$CartDatabase, $CartItemsTable> {
  $$CartItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get volume =>
      $composableBuilder(column: $table.volume, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get originalPrice => $composableBuilder(
      column: $table.originalPrice, builder: (column) => column);

  GeneratedColumn<int> get stockQuantity => $composableBuilder(
      column: $table.stockQuantity, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$CartItemsTableTableManager extends RootTableManager<
    _$CartDatabase,
    $CartItemsTable,
    CartItem,
    $$CartItemsTableFilterComposer,
    $$CartItemsTableOrderingComposer,
    $$CartItemsTableAnnotationComposer,
    $$CartItemsTableCreateCompanionBuilder,
    $$CartItemsTableUpdateCompanionBuilder,
    (CartItem, BaseReferences<_$CartDatabase, $CartItemsTable, CartItem>),
    CartItem,
    PrefetchHooks Function()> {
  $$CartItemsTableTableManager(_$CartDatabase db, $CartItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CartItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CartItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CartItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> productId = const Value.absent(),
            Value<String> brand = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> volume = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<double> price = const Value.absent(),
            Value<double?> originalPrice = const Value.absent(),
            Value<int> stockQuantity = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<DateTime> addedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CartItemsCompanion(
            productId: productId,
            brand: brand,
            name: name,
            volume: volume,
            imageUrl: imageUrl,
            price: price,
            originalPrice: originalPrice,
            stockQuantity: stockQuantity,
            quantity: quantity,
            addedAt: addedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String productId,
            required String brand,
            required String name,
            Value<String?> volume = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            required double price,
            Value<double?> originalPrice = const Value.absent(),
            required int stockQuantity,
            required int quantity,
            required DateTime addedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CartItemsCompanion.insert(
            productId: productId,
            brand: brand,
            name: name,
            volume: volume,
            imageUrl: imageUrl,
            price: price,
            originalPrice: originalPrice,
            stockQuantity: stockQuantity,
            quantity: quantity,
            addedAt: addedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CartItemsTableProcessedTableManager = ProcessedTableManager<
    _$CartDatabase,
    $CartItemsTable,
    CartItem,
    $$CartItemsTableFilterComposer,
    $$CartItemsTableOrderingComposer,
    $$CartItemsTableAnnotationComposer,
    $$CartItemsTableCreateCompanionBuilder,
    $$CartItemsTableUpdateCompanionBuilder,
    (CartItem, BaseReferences<_$CartDatabase, $CartItemsTable, CartItem>),
    CartItem,
    PrefetchHooks Function()>;

class $CartDatabaseManager {
  final _$CartDatabase _db;
  $CartDatabaseManager(this._db);
  $$CartItemsTableTableManager get cartItems =>
      $$CartItemsTableTableManager(_db, _db.cartItems);
}
