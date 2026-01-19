import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_inventory/providers/sync_provider.dart';
import 'package:new_inventory/services/firestore_repository.dart';
import 'package:new_inventory/services/local_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/product.dart';
import '../services/product_repository.dart';

// PART STATEMENT (tells build_runner to generate)
part 'product_provider.g.dart';

/// Manages product inventory state with CRUD operations and optimistic updates.
@Riverpod(keepAlive: true)
class ProductNotifier extends _$ProductNotifier {
  /// Initializes the provider by loading all products from the repository.
  @override
  Future<List<Product>> build() async {
    // 1.  don’t wait – draw empty list
    Future.microtask(() async {
      final repository = ref.read(repositoryProvider);
      final products = await repository.getAllProducts();
      state = AsyncValue.data(products); // 2.  push data when ready
    });
    return []; // first frame is free
  }

  /// Adds a new product to inventory and refreshes the product list.
  Future<void> addProduct(Product product) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(repositoryProvider);
      await repository.addProduct(product);
      state = await AsyncValue.guard(() => repository.getAllProducts());
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  /// Deletes a product by ID and refreshes the product list.
  Future<void> deleteProduct(String id) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(repositoryProvider);
      await repository.deleteProduct(id);
      state = await AsyncValue.guard(() => repository.getAllProducts());
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  /// Updates a product with optimistic UI updates and automatic rollback on failure.
  Future<void> updateProduct(Product product) async {
    // 1. remember current list in case we need to roll back
    final previous = state.valueOrNull ?? [];

    // 2. immediately show the changed list (UI stays free → scaling visible)
    state = AsyncValue.data(
      previous.map((p) => p.id == product.id ? product : p).toList(),
    );

    // 3. fire-and-forget the real call; handle errors silently
    try {
      final repository = ref.read(repositoryProvider);
      await repository.updateProduct(product);

      // optional: re-fetch to guarantee consistency
      // state = await AsyncValue.guard(() => repository.getAllProducts());
    } catch (err) {
      // 4. rollback on failure (optional: show a snack-bar)
      state = AsyncValue.data(previous);
      // log or report to crashlytics etc.
    }
  }
}

final repositoryProvider = Provider<ProductRepository>((ref) {
  final async = ref.watch(syncNotifierProvider);

  // while we are loading or on first frame we need *something* → fall back to Hive
  final useCloud = async.value ?? false;

  return useCloud ? FirestoreRepository() : LocalRepository();
});

// PRODUCT PROVIDER - global access point (UI calls this)
final productProvider = AsyncNotifierProvider<ProductNotifier, List<Product>>(
  () {
    return ProductNotifier();
  },
);
