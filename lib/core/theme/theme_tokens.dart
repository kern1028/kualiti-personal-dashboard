import 'package:flutter/material.dart';

enum AppThemeMode {
  defaultTheme,
  darkMode,
  aestheticBrown,
  vintage,
  retroXp,
  pixel,
}

class ThemeTokens extends ThemeExtension<ThemeTokens> {
  final Color bg;
  final Color surface;
  final Color ink;
  final Color inkMuted;
  final Color accent;
  final Color onAccent;
  final Color line;
  final Color priorityLow;
  final Color priorityMid;
  final Color priorityHigh;
  final double radius;
  final double borderWidth;
  final String fontBody;
  final String fontTitle;
  final bool isRetroXp;
  final bool isPixel;

  const ThemeTokens({
    required this.bg,
    required this.surface,
    required this.ink,
    required this.inkMuted,
    required this.accent,
    required this.onAccent,
    required this.line,
    required this.priorityLow,
    required this.priorityMid,
    required this.priorityHigh,
    required this.radius,
    required this.borderWidth,
    required this.fontBody,
    required this.fontTitle,
    this.isRetroXp = false,
    this.isPixel = false,
  });

  // 1. Default (Pagi yang tenang)
  static const defaultTokens = ThemeTokens(
    bg: Color(0xFFF6F1E9),
    surface: Color(0xFFFFFBF5),
    ink: Color(0xFF3B342C),
    inkMuted: Color(0xFF8C8276),
    accent: Color(0xFFC4704B),
    onAccent: Color(0xFFFFFFFF),
    line: Color(0xFFE8DFD2),
    priorityLow: Color(0xFF8FB39A),
    priorityMid: Color(0xFFE0B25C),
    priorityHigh: Color(0xFFD1675A),
    radius: 16.0,
    borderWidth: 1.0,
    fontBody: 'Nunito',
    fontTitle: 'Nunito',
  );

  // 2. Dark Mode (Malam hangat)
  static const darkModeTokens = ThemeTokens(
    bg: Color(0xFF26231F),
    surface: Color(0xFF302C27),
    ink: Color(0xFFEDE3D3),
    inkMuted: Color(0xFF9A8F80),
    accent: Color(0xFFE3B15C),
    onAccent: Color(0xFF26231F),
    line: Color(0xFF3E3933),
    priorityLow: Color(0xFF7FA38C),
    priorityMid: Color(0xFFD9A85A),
    priorityHigh: Color(0xFFD9776A),
    radius: 16.0,
    borderWidth: 1.0,
    fontBody: 'Nunito',
    fontTitle: 'Nunito',
  );

  // 3. Aesthetic Brown (Kafe)
  static const aestheticBrownTokens = ThemeTokens(
    bg: Color(0xFFEADBC8),
    surface: Color(0xFFF6EBDD),
    ink: Color(0xFF4A3426),
    inkMuted: Color(0xFF8A6F5B),
    accent: Color(0xFFB5603A),
    onAccent: Color(0xFFFFFFFF),
    line: Color(0xFFD9C5AC),
    priorityLow: Color(0xFF8E9B6F),
    priorityMid: Color(0xFFD2A04F),
    priorityHigh: Color(0xFFB5483A),
    radius: 14.0,
    borderWidth: 1.0,
    fontBody: 'Quicksand',
    fontTitle: 'Quicksand',
  );

  // 4. Vintage (Buku catatan lama)
  static const vintageTokens = ThemeTokens(
    bg: Color(0xFFEFE3C8),
    surface: Color(0xFFF7EEDB),
    ink: Color(0xFF3E2F1F),
    inkMuted: Color(0xFF8B7355),
    accent: Color(0xFF7A4E2D),
    onAccent: Color(0xFFFFFFFF),
    line: Color(0xFFD8C7A3),
    priorityLow: Color(0xFF7C8B5A),
    priorityMid: Color(0xFFC79A3B),
    priorityHigh: Color(0xFFA4452F),
    radius: 6.0,
    borderWidth: 1.0,
    fontBody: 'Lora',
    fontTitle: 'Lora',
  );

  // 5. Retro Windows XP (Nostalgia desktop XP)
  static const retroXpTokens = ThemeTokens(
    bg: Color(0xFFECE9D8),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF000000),
    inkMuted: Color(0xFF555555),
    accent: Color(0xFF3A9A2E),
    onAccent: Color(0xFFFFFFFF),
    line: Color(0xFF7A96DF),
    priorityLow: Color(0xFF3A9A2E),
    priorityMid: Color(0xFFE8A400),
    priorityHigh: Color(0xFFD03A2A),
    radius: 3.0,
    borderWidth: 2.0,
    fontBody: 'Noto Sans',
    fontTitle: 'Noto Sans',
    isRetroXp: true,
  );

  // 6. Pixel (Game 8-bit lembut)
  static const pixelTokens = ThemeTokens(
    bg: Color(0xFFF4EEFF),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF2B2540),
    inkMuted: Color(0xFF6A6385),
    accent: Color(0xFFFF8FB1),
    onAccent: Color(0xFF2B2540),
    line: Color(0xFF2B2540),
    priorityLow: Color(0xFF8FD6A8),
    priorityMid: Color(0xFFFFD36E),
    priorityHigh: Color(0xFFFF7A8A),
    radius: 0.0,
    borderWidth: 3.0,
    fontBody: 'Nunito',
    fontTitle: 'Courier New',
    isPixel: true,
  );

  static ThemeTokens getTokens(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.defaultTheme:
        return defaultTokens;
      case AppThemeMode.darkMode:
        return darkModeTokens;
      case AppThemeMode.aestheticBrown:
        return aestheticBrownTokens;
      case AppThemeMode.vintage:
        return vintageTokens;
      case AppThemeMode.retroXp:
        return retroXpTokens;
      case AppThemeMode.pixel:
        return pixelTokens;
    }
  }

  @override
  ThemeExtension<ThemeTokens> copyWith({
    Color? bg,
    Color? surface,
    Color? ink,
    Color? inkMuted,
    Color? accent,
    Color? onAccent,
    Color? line,
    Color? priorityLow,
    Color? priorityMid,
    Color? priorityHigh,
    double? radius,
    double? borderWidth,
    String? fontBody,
    String? fontTitle,
    bool? isRetroXp,
    bool? isPixel,
  }) {
    return ThemeTokens(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      line: line ?? this.line,
      priorityLow: priorityLow ?? this.priorityLow,
      priorityMid: priorityMid ?? this.priorityMid,
      priorityHigh: priorityHigh ?? this.priorityHigh,
      radius: radius ?? this.radius,
      borderWidth: borderWidth ?? this.borderWidth,
      fontBody: fontBody ?? this.fontBody,
      fontTitle: fontTitle ?? this.fontTitle,
      isRetroXp: isRetroXp ?? this.isRetroXp,
      isPixel: isPixel ?? this.isPixel,
    );
  }

  @override
  ThemeExtension<ThemeTokens> lerp(ThemeExtension<ThemeTokens>? other, double t) {
    if (other is! ThemeTokens) return this;
    return ThemeTokens(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      line: Color.lerp(line, other.line, t)!,
      priorityLow: Color.lerp(priorityLow, other.priorityLow, t)!,
      priorityMid: Color.lerp(priorityMid, other.priorityMid, t)!,
      priorityHigh: Color.lerp(priorityHigh, other.priorityHigh, t)!,
      radius: radius + (other.radius - radius) * t,
      borderWidth: borderWidth + (other.borderWidth - borderWidth) * t,
      fontBody: other.fontBody,
      fontTitle: other.fontTitle,
      isRetroXp: other.isRetroXp,
      isPixel: other.isPixel,
    );
  }
}
