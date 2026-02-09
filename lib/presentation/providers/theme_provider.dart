import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for SharedPreferences instance - nullable to handle initialization failure
final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) {
  return null; // Will be overridden in main.dart
});

// Theme state notifier with null-safe SharedPreferences handling
class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences? prefs;

  ThemeNotifier(this.prefs) : super(_getInitialTheme(prefs));

  static ThemeMode _getInitialTheme(SharedPreferences? prefs) {
    if (prefs == null) return ThemeMode.system;
    final isDark = prefs.getBool('isDarkMode');
    if (isDark == null) return ThemeMode.system;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme(bool isDark) async {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
    await prefs?.setBool('isDarkMode', isDark);
  }
}

// Global theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});

// Helper to check if dark mode is active
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeProvider);
  if (themeMode == ThemeMode.system) {
    // Default to false or system setting logic if needed
    return false;
  }
  return themeMode == ThemeMode.dark;
});
