import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_inventory/providers/product_provider.dart';
import 'package:new_inventory/services/firestore_repository.dart';
import 'package:new_inventory/services/local_repository.dart';

/* ------------------------------------------------------------------ */
/* 1.  AsyncNotifier → heavy work runs in background                  */
/* ------------------------------------------------------------------ */
class SyncNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    // read persisted flag
    return Hive.box('settings').get('useCloud', defaultValue: false);
  }

  /* ---------------  UI calls this instead of toggleSync  ------------- */
  Future<void> toggle() async {
    final old = state.value ?? false;

    /* mark “loading” → UI shows progress                                */
    state = const AsyncValue.loading();

    /* do the expensive sync in background                               */
    state = await AsyncValue.guard(() async {
      if (old) {
        await _pushAllFirebaseToHive();
      } else {
        await _pushAllHiveToFirebase();
      }

      /* finally flip the flag                                           */
      final now = !old;
      await Hive.box('settings').put('useCloud', now);
      ref.invalidate(productProvider); // reload products
      return now;
    });
  }

  Future<void> _pushAllHiveToFirebase() async {
    final local = LocalRepository();
    final cloud = FirestoreRepository();
    final rows = await local.getAllProducts();

    for (final p in rows) {
      String? imagePath = p.imagePath;
      if (imagePath != null && imagePath.startsWith('/')) {
        imagePath = await cloud.uploadImage(File(imagePath), p.id);
      }
      final c = await cloud.getProduct(p.id);
      if (c == null || p.updatedAt > c.updatedAt) {
        await cloud.updateProduct(p.copyWith(imagePath: imagePath));
      }
    }
  }

  Future<void> _pushAllFirebaseToHive() async {
    final local = LocalRepository();
    final cloud = FirestoreRepository();
    final rows = await cloud.getAllProducts();
    for (final p in rows) {
      final l = await local.getProduct(p.id);
      if (l == null || p.updatedAt > l.updatedAt) {
        await local.updateProduct(p);
      }
    }
  }
}

/* ------------------------------------------------------------------ */
/* 2.  public provider                                                */
/* ------------------------------------------------------------------ */
final syncNotifierProvider =
    AsyncNotifierProvider<SyncNotifier, bool>(SyncNotifier.new);

/* ------------------------------------------------------------------ */
/* 3.  old providers kept for backward compatibility – you can delete  */
/*     them later when no widget imports them any more.                */
/* ------------------------------------------------------------------ */
final syncBoxProvider = Provider<Box>((ref) => Hive.box('settings'));

final useCloudProvider = FutureProvider<bool>(
    (ref) async => ref.watch(syncNotifierProvider.selectAsync((data) => data)));
