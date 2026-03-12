import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes.dart';
import '../core/theme/app_theme.dart';


class RentCarProApp extends ConsumerWidget {
  const RentCarProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    // Ignore the user preference, force light theme for the new professional Apple design
    // final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Drive Easy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Forced directly to new light redesign
      routerConfig: router,
    );
  }
}
