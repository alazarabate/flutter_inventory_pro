import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_inventory/providers/background_sync_provider.dart';
import 'package:new_inventory/services/firestore_repository.dart';
import 'package:new_inventory/services/local_repository.dart';

final syncBoxProvider = Provider<Box>((ref) => Hive.box('settings'));

/// true  → Firestore (cloud)
/// false → Hive (local)
final useCloudProvider = StateProvider<bool>((ref) {
  final box = ref.watch(syncBoxProvider);
  return box.get('useCloud', defaultValue: false);
});

Future<void> toggleSync(WidgetRef ref) async {
  final box = ref.read(syncBoxProvider);
  final current = ref.read(useCloudProvider); // repo we are ON
  final newValue = !current; // repo we are going TO

  /* 1.  push EVERYTHING from the outgoing repo --------------*/
  if (current) {
    // leaving Firebase  ->  push all Firebase rows to Hive
    await _pushAllFirebaseToHive();
  } else {
    // leaving Hive      ->  push all Hive rows to Firebase
    await _pushAllHiveToFirebase();
  }

  /* 2.  flip flag & let UI rebuild --------------------------*/
  ref.read(useCloudProvider.notifier).state = newValue;
  await box.put('useCloud', newValue);
  // productProvider rebuilds automatically
}

/* ---------- helpers (add once, anywhere) ---------- */
Future<void> _pushAllHiveToFirebase() async {
  final local = LocalRepository();
  final cloud = FirestoreRepository();
  final rows = await local.getAllProducts();
  for (final p in rows) {
    final c = await cloud.getProduct(p.id);
    if (c == null || p.updatedAt > c.updatedAt) await cloud.updateProduct(p);
  }
}

Future<void> _pushAllFirebaseToHive() async {
  final local = LocalRepository();
  final cloud = FirestoreRepository();
  final rows = await cloud.getAllProducts();
  for (final p in rows) {
    final l = await local.getProduct(p.id);
    if (l == null || p.updatedAt > l.updatedAt) await local.updateProduct(p);
  }
}
