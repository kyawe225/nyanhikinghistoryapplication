import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Minimal theme types
enum ThemeType { material, cupertino, ios26Liquid }

// Provider holding the current theme selection - use Riverpod 3 Notifier style
final themeTypeProvider = NotifierProvider<ThemeNotifier, ThemeType>(ThemeNotifier.new);

class ThemeNotifier extends Notifier<ThemeType> {
  @override
  ThemeType build() => ThemeType.material; // initial value

  // Helper to set theme (you can also set state directly)
  void set(ThemeType t) => state = t;
}

// Central map from ThemeType to ThemeData (no if-statements required when using)
final Map<ThemeType, ThemeData> themeDataMap = {
  ThemeType.material: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.teal, // changed to teal (green-cyan)
      brightness: Brightness.light,
    ),
    primaryColor: Colors.teal,
    scaffoldBackgroundColor: Colors.grey.shade50,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.teal.shade700,
      elevation: 2,
      titleTextStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal.shade600,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 6,
      backgroundColor: Colors.cyanAccent.shade400,
      foregroundColor: Colors.black87,
    ),
    // Borderless text fields with extra vertical padding to visually space inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      isDense: false,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
    ),
    textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Roboto'),
  ),

  ThemeType.cupertino: ThemeData(
    // Cupertino-like approximation using green tones
    brightness: Brightness.light,
    primaryColor: Colors.green,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black87),
      iconTheme: IconThemeData(color: Colors.green),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textTheme: ThemeData.light().textTheme.apply(
      fontFamily: 'SF Pro Text',
      bodyColor: Colors.black87,
      displayColor: Colors.black87,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.green.shade600,
      unselectedItemColor: Colors.black54,
    ),
  ),

  ThemeType.ios26Liquid: ThemeData(
    // "Liquid glass" / cyan-green translucent approximation
    brightness: Brightness.light,
    primaryColor: Colors.cyan,
    scaffoldBackgroundColor: Colors.grey.shade100,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.cyan.withOpacity(0.65), // translucent feel
      elevation: 0,
      titleTextStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black87),
      iconTheme: const IconThemeData(color: Colors.black87),
    ),
    cardTheme: CardThemeData(
      color: Colors.white.withOpacity(0.72),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.cyanAccent.shade100.withOpacity(0.95),
        foregroundColor: Colors.black87,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textTheme: ThemeData.light().textTheme.apply(
      fontFamily: 'SF Pro Text',
      bodyColor: Colors.black87,
      displayColor: Colors.black87,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.6),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.greenAccent.shade100.withOpacity(0.95),
      foregroundColor: Colors.black87,
      elevation: 0,
    ),
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan, brightness: Brightness.light),
  ),
};
