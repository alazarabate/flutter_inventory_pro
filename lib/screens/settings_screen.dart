import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/sync_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final current = ref.watch(localeProvider).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr())),
      body: ListView(
        children: [
          // Dark Mode
          SwitchListTile(
            title: Text('darkMode'.tr()),
            value: isDark,
            onChanged: (_) => toggleTheme(ref),
          ),
          // Language
          ListTile(
            title: Text('language'.tr()),
            subtitle: Text(current == 'en' ? 'english'.tr() : 'amharic'.tr()),
            trailing: DropdownButton<String>(
              value: current,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'am', child: Text('አማርኛ')),
              ],
              onChanged: (code) => setLocale(ref, code!),
            ),
          ),
          const Divider(),

          Consumer(
            builder: (_, ref, __) {
              final async = ref.watch(syncNotifierProvider);
              return SwitchListTile(
                title: const Text('Cloud sync'),
                subtitle: async.isLoading
                    ? const LinearProgressIndicator()
                    : Text(async.value! ? 'Firebase' : 'Hive'),
                value: async.value ?? false,
                onChanged: (_) =>
                    ref.read(syncNotifierProvider.notifier).toggle(),
              );
            },
          )
        ],
      ),
    );
  }
}
