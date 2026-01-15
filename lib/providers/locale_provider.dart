import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final localeBoxProvider = Provider<Box>((_) => Hive.box('settings'));

final localeProvider = StateProvider<Locale>((ref) {
  final box = ref.watch(localeBoxProvider);
  final code = box.get('locale', defaultValue: 'en');
  return Locale(code);
});

Future<void> setLocale(WidgetRef ref, String code) async {
  final box = ref.read(localeBoxProvider);
  ref.read(localeProvider.notifier).state = Locale(code);
  await box.put('locale', code);
}
