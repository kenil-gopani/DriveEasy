import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/routes.dart';
import '../providers/auth_provider.dart';
import '../widgets/typing_loader.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _animationFinished = false;

  @override
  void initState() {
    super.initState();
    _startAnimationTimer();
  }

  Future<void> _startAnimationTimer() async {
    // Exact 2-second delay for the splash animation
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    setState(() => _animationFinished = true);
    _checkNavigation();
  }

  void _checkNavigation() {
    if (!_animationFinished) return;

    final authState = ref.read(authStateProvider);
    // Don't navigate if Firebase is still loading
    if (authState.isLoading) return; 

    authState.when(
      data: (user) => user != null
          ? context.go(AppRoutes.home)
          : context.go(AppRoutes.onboarding),
      loading: () {}, // Already handled above
      error: (_, __) => context.go(AppRoutes.onboarding),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if we should navigate whenever auth state changes
    ref.listen(authStateProvider, (_, __) => _checkNavigation());

    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: TypingLoader(
          color: Colors.black,
          shadowColor: Color.fromRGBO(0, 0, 0, 0.2),
        ),
      ),
    );
  }
}
