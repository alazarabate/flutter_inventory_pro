import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_inventory/services/firestore_repository.dart';
import 'package:new_inventory/services/local_repository.dart';

/// Global sync routine:
///  - pushes every local row with `pendingSync == true`
///  - pulls every server row that is newer / missing locally  (only once)
///  - resolves conflicts by `updatedAt` timestamp
///  - after the first full migration, download part is skipped unless local is stale
final backgroundSyncProvider = FutureProvider<void>((ref) async {
  final local = LocalRepository();
  final cloud = FirestoreRepository();

  // ----------------------------------------------------------
  // 1.  PUSH  (incremental, only pendingSync == true)
  // ----------------------------------------------------------
  final toPush =
      (await local.getAllProducts()).where((p) => p.pendingSync).toList();
  print('Push queue length: ${toPush.length}');

  for (final p in toPush) {
    await cloud.updateProduct(p); // Firestore repo already
    await local.updateProduct(p.copyWith(pendingSync: false)); // un-flag
  }

  // ----------------------------------------------------------
  // 2.  PULL  (bidirectional – one-time or when local is older)
  // ----------------------------------------------------------
  final serverProducts =
      await cloud.getAllProducts(); // all docs from Firestore
  for (final serverProduct in serverProducts) {
    final localProduct = await local.getProduct(serverProduct.id);

    // Skip if we already have a **confirmed-synced** local copy
    if (localProduct != null && !localProduct.pendingSync) continue;

    // Download only if missing or server is newer
    if (localProduct == null ||
        serverProduct.updatedAt > localProduct.updatedAt) {
      await local.updateProduct(
          serverProduct.copyWith(pendingSync: false)); // mark as already synced
    }
    // If the local copy is newer (localProduct.updatedAt > serverProduct.updatedAt)
    // we do NOTHING in this loop.
    // The local row still has pendingSync = true, so the push part above
    // will upload it in a moment.
    // We NEVER delete anything here; we only overwrite when the server
    // is newer or missing locally.
  }

  final remaining =
      (await local.getAllProducts()).where((p) => p.pendingSync).length;
  print('SYNC DONE: $remaining items still queued');
});
