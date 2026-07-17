import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'cart_database.g.dart';

class CartItems extends Table {
  TextColumn   get productId      => text()();
  TextColumn   get brand          => text()();
  TextColumn   get name           => text()();
  TextColumn   get volume         => text().nullable()();
  TextColumn   get imageUrl       => text().nullable()();
  RealColumn   get price          => real()();
  RealColumn   get originalPrice  => real().nullable()();
  IntColumn    get stockQuantity  => integer()();
  IntColumn    get quantity       => integer()();
  DateTimeColumn get addedAt      => dateTime()();

  @override
  Set<Column> get primaryKey => {productId};
}

@DriftDatabase(tables: [CartItems])
class CartDatabase extends _$CartDatabase {
  CartDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
      );

  // ── Query ──────────────────────────────────────────────────────────────

  Future<List<CartItem>> getAllItems() =>
      (select(cartItems)
        ..orderBy([(t) => OrderingTerm.desc(t.addedAt)])).get();

  Stream<List<CartItem>> watchAllItems() =>
      (select(cartItems)
        ..orderBy([(t) => OrderingTerm.desc(t.addedAt)])).watch();

  Future<CartItem?> getItemById(String productId) =>
      (select(cartItems)..where((t) => t.productId.equals(productId)))
          .getSingleOrNull();


  Future<void> addOrUpdateItem({
    required String productId,
    required String brand,
    required String name,
    String? volume,
    String? imageUrl,
    required double price,
    double? originalPrice,
    required int stockQuantity,
    required int quantity,
  }) async {
    final existing = await getItemById(productId);

    if (existing != null) {
      final newQty = (existing.quantity + quantity).clamp(1, stockQuantity);
      await (update(cartItems)..where((t) => t.productId.equals(productId)))
          .write(CartItemsCompanion(
        quantity: Value(newQty),
        price: Value(price),
        originalPrice: Value(originalPrice),
        stockQuantity: Value(stockQuantity),
      ));
    } else {
      await into(cartItems).insert(
        CartItemsCompanion.insert(
          productId: productId,
          brand: brand,
          name: name,
          volume: Value(volume),
          imageUrl: Value(imageUrl),
          price: price,
          originalPrice: Value(originalPrice),
          stockQuantity: stockQuantity,
          quantity: quantity,
          addedAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> updateQuantity(String productId, int quantity) =>
      (update(cartItems)..where((t) => t.productId.equals(productId)))
          .write(CartItemsCompanion(quantity: Value(quantity)));

  // ── Delete ─────────────────────────────────────────────────────────────

  Future<void> removeItem(String productId) =>
      (delete(cartItems)..where((t) => t.productId.equals(productId))).go();

  Future<void> clearCart() => delete(cartItems).go();
}


LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir  = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'glowaura_cart.db'));
    return NativeDatabase.createInBackground(file);
  });
}

final cartDatabaseProvider = Provider<CartDatabase>((ref) {
  final db = CartDatabase();
  ref.onDispose(db.close);
  return db;
});