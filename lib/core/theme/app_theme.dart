import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_tokens.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themePrefKey = 'selected_theme';
  AppThemeMode _currentTheme = AppThemeMode.defaultTheme;

  AppThemeMode get currentTheme => _currentTheme;
  ThemeTokens get tokens => ThemeTokens.getTokens(_currentTheme);

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themePrefKey);
    if (saved != null) {
      _currentTheme = AppThemeMode.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => AppThemeMode.defaultTheme,
      );
      notifyListeners();
    }
  }

  Future<void> setTheme(AppThemeMode mode) async {
    _currentTheme = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePrefKey, mode.name);
  }

  ThemeData get themeData => AppTheme.buildTheme(_currentTheme);
}

class AppTheme {
  AppTheme._();

  static ThemeData buildTheme(AppThemeMode mode) {
    final tokens = ThemeTokens.getTokens(mode);
    final isDark = mode == AppThemeMode.darkMode;

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: tokens.bg,
      fontFamily: tokens.fontBody,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: tokens.accent,
        onPrimary: tokens.onAccent,
        secondary: tokens.accent,
        onSecondary: tokens.onAccent,
        surface: tokens.surface,
        onSurface: tokens.ink,
        error: tokens.priorityHigh,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.bg,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: tokens.ink),
        titleTextStyle: TextStyle(
          color: tokens.ink,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: tokens.fontTitle,
        ),
      ),
      cardTheme: CardTheme(
        color: tokens.surface,
        elevation: tokens.isPixel ? 0 : 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius),
          side: BorderSide(
            color: tokens.line,
            width: tokens.borderWidth,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: tokens.line,
        thickness: tokens.borderWidth,
        space: 1,
      ),
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: tokens.ink,
          fontFamily: tokens.fontTitle,
          height: 1.4,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: tokens.ink,
          fontFamily: tokens.fontTitle,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: tokens.ink,
          fontFamily: tokens.fontTitle,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: tokens.ink,
          fontFamily: tokens.fontBody,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: tokens.ink,
          fontFamily: tokens.fontBody,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: tokens.inkMuted,
          fontFamily: tokens.fontBody,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: tokens.inkMuted,
          fontFamily: tokens.fontBody,
          height: 1.3,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: tokens.ink,
        contentTextStyle: TextStyle(color: tokens.bg, fontSize: 14),
        actionTextColor: tokens.accent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius > 8 ? 8 : tokens.radius),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      extensions: [tokens],
    );
  }
}

extension ThemeGetter on BuildContext {
  ThemeTokens get tokens => Theme.of(this).extension<ThemeTokens>() ?? ThemeTokens.defaultTokens;
  TextTheme get textTheme => Theme.of(this).textTheme;
}
