

import 'package:new_inventory/models/product.dart';

/// Abstract repository defining CRUD and search operations for product data.
abstract class ProductRepository {

  /// Retrieves all products from the data source.
  Future<List<Product>> getAllProducts();

  /// Adds a new product to the data source.
  Future<void> addProduct(Product product);

  /// Updates an existing product in the data source.
  Future<void> updateProduct(Product product);
  
  /// Deletes a product from the data source by its ID.
  Future<void> deleteProduct(String id);

  /// Searches for products by name or category using the provided query.
  Future<List<Product>> searchProduct(String query);
}
