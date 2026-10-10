import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/asset_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/db/user_provider.dart';
import '../onboarding/onboarding_screen.dart';
import '../navigation/main_navigation_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _titleOpacity;
  late Animation<double> _taglineOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.7, curve: Curves.easeIn),
      ),
    );

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Minimum 2 seconds presentation per design system specs
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final targetScreen = userProvider.isOnboardingComplete
        ? const MainNavigationShell()
        : const OnboardingScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.bg,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5EFE6), // Logo matching cream bg
                        borderRadius: BorderRadius.circular(tokens.radius),
                        border: Border.all(
                          color: tokens.line,
                          width: tokens.borderWidth,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        AssetConstants.logoImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.dashboard_customize_rounded,
                          size: 48,
                          color: tokens.accent,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Opacity(
                  opacity: _titleOpacity.value,
                  child: Text(
                    AssetConstants.appName,
                    style: TextStyle(
                      fontFamily: tokens.fontTitle,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: tokens.ink,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Opacity(
                  opacity: _taglineOpacity.value,
                  child: Text(
                    AssetConstants.splashTagline,
                    style: TextStyle(
                      fontFamily: tokens.fontBody,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: tokens.inkMuted,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
