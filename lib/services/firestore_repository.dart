import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/product.dart';
import 'product_repository.dart';

/// Firestore-based implementation of product repository with offline caching.
class FirestoreRepository implements ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'items';

  /// Retrieves all products from the Firestore collection.
  @override
  Future<List<Product>> getAllProducts() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs.map((doc) => Product.fromJson(doc.data())).toList();
  }

  Future<String> uploadImage(File imageFile, String ProductId) async {
    final ref = FirebaseStorage.instance.ref('product_images/$ProductId.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  Future<Product?> getProduct(String id) async {
    final snap = await _firestore.collection(_collection).doc(id).get();
    return snap.exists ? Product.fromJson(snap.data()!) : null;
  }

  /// Adds a new product document to Firestore using the product ID as document key.
  @override
  Future<void> addProduct(Product product) async {
    await _firestore
        .collection(_collection)
        .doc(product.id)
        .set(product.toJson());
  }

  /// Updates an existing product document in Firestore.
  @override
  Future<void> updateProduct(Product product) async {
    final doc = _firestore.collection(_collection).doc(product.id);
    final snap = await doc.get();

    if (!snap.exists) {
      await doc.set(product.toJson());
      return;
    }

    final remote = Product.fromJson(snap.data()!);
    if (product.updatedAt >= remote.updatedAt) {
      await doc.set(product.toJson()); // local is newer
    } else {
      print('Sync conflict - kept remote version');
    }
  }

  /// Deletes a product document from Firestore by its ID.
  @override
  Future<void> deleteProduct(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  /// Searches for products whose names start with the given query string.
  @override
  Future<List<Product>> searchProduct(String query) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();
    return snapshot.docs.map((doc) => Product.fromJson(doc.data())).toList();
  }
}
