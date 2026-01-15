import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:new_inventory/adaptors/manual_product_adaptor.dart';
import 'package:new_inventory/providers/theme_provider.dart';
import 'package:new_inventory/screens/product_list_screen.dart';
import 'package:new_inventory/screens/settings_screen.dart';

import 'models/product.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and register manual adapter BEFORE opening the box
  await Hive.initFlutter();

  Hive.registerAdapter(ManualProductAdapter());

  await Hive.openBox<Product>('products_v2');
  await Hive.openBox('settings');

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final user = ref.watch(userProvider);
    final themeMode = ref.watch(themeProvider);
    // final bool isLoggedIn = ref.watch(userProvider);

    return MaterialApp(
      title: 'Inventory Pro',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      home: ProductListScreen(),
      routes: {
        '/products': (context) => ProductListScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
