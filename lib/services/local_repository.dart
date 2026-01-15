import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:new_inventory/models/product.dart';
import 'package:new_inventory/services/product_repository.dart';

/// Hive-based local repository for storing products offline with fast read/write.
class LocalRepository implements ProductRepository {
  // Use a new box name so old on-disk data is not read
  static final String _boxName = 'products_v2';

  /// Opens or returns the existing Hive box for product storage.
  Future<Box<Product>> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<Product>(_boxName);
    }
    return Hive.box<Product>(_boxName);
  }

  /// Retrieves all products stored in the local Hive box.
  @override
  Future<List<Product>> getAllProducts() async {
    final box = await _openBox();
    return box.values.toList();
  }

  Future<Product?> getProduct(String id) async {
    final box = await _openBox();
    return box.get(id);
  }

  /// Saves a product to local storage using its ID as the Hive key.
  @override
  Future<void> addProduct(Product product) async {
    final box = await _openBox();
    return box.put(product.id, product);
    
  }

  /// Updates an existing product in local storage (overwrites by ID).
  @override
  Future<void> updateProduct(Product product) async {
    final box = await _openBox();
    // flag it for later cloud push
    await box.put(product.id, product.copyWith(pendingSync: true));
    final check = await getAllProducts(); // re-read box
    final saved = check.firstWhere((p) => p.id == product.id);
    print('LOCAL SAVED: ${saved.name} pending=${saved.pendingSync}');
  }

  /// Deletes a product from local storage by its ID.
  @override
  Future<void> deleteProduct(String id) async {
    final box = await _openBox();
    return box.delete(id);
  }

  /// Searches locally stored products by name (case‑insensitive substring match).
  @override
  Future<List<Product>> searchProduct(String query) async {
    final box = await _openBox();
    return box.values
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
