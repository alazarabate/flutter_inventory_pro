import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final themeBoxProvider = Provider<Box>((_) => Hive.box('settings'));

final themeProvider = StateProvider<ThemeMode>((ref) {
  final box = ref.watch(themeBoxProvider);
  final isDark = box.get('isDark', defaultValue: false);
  return isDark ? ThemeMode.dark : ThemeMode.light;
});

Future<void> toggleTheme(WidgetRef ref) async {
  final box = ref.read(themeBoxProvider);
  final current = ref.read(themeProvider);
  final newMode = current == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  ref.read(themeProvider.notifier).state = newMode;
  await box.put('isDark', newMode == ThemeMode.dark);
}
