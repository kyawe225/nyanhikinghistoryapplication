import 'package:flutter/material.dart';
import 'package:hiking_app_one/database/create_script.dart';
import 'package:hiking_app_one/screens/hiking/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hiking_app_one/providers/theme_provider.dart';

void main() {
  if (!isDatabaseExists()) {
    createTables();
  }
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeType = ref.watch(themeTypeProvider);
    final theme = themeDataMap[themeType] ?? themeDataMap[ThemeType.material]!;
    return MaterialApp(
      title: 'Hiking App',
      theme: theme,
      home: const HomeScreen(),
    );
  }
}
