// lib/utils/hive_migration.dart
import 'package:hive/hive.dart';
import '../models/product.dart';

/// One-time migration: ensure existing Product entries have sensible values.
Future<void> migrateProductsBox() async {
  final Box<Product> box = await Hive.openBox<Product>('products_v2');

  for (final key in box.keys) {
    final product = box.get(key);
    if (product == null) continue;

    var changed = false;
    var newProduct = product;

    // Fix missing/empty updatedBy (real problem to fix)
    if (newProduct.updatedBy.isEmpty) {
      newProduct = newProduct.copyWith(updatedBy: 'unknown');
      changed = true;
    }

    // NOTE: don't check `pendingSync == null` — it's non-nullable with defaults,
    // so that check is dead code and should be removed.

    if (changed) {
      await box.put(key, newProduct);
    }
  }
}