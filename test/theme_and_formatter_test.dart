import 'package:flutter_test/flutter_test.dart';
import 'package:kualiti/core/theme/theme_tokens.dart';
import 'package:kualiti/core/utils/date_time_formatter.dart';

void main() {
  group('ThemeTokens Test', () {
    test('All 6 themes define proper tokens', () {
      for (final mode in AppThemeMode.values) {
        final tokens = ThemeTokens.getTokens(mode);
        expect(tokens.bg, isNotNull);
        expect(tokens.surface, isNotNull);
        expect(tokens.ink, isNotNull);
        expect(tokens.accent, isNotNull);
      }
    });
  });

  group('DateTimeFormatter Test', () {
    test('Default DMY format', () {
      final date = DateTime(2026, 10, 24);
      expect(DateTimeFormatter.formatDate(date), '24/10/2026');
    });
  });
}
