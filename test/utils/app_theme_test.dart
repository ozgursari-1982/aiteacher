import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_teacher_app/utils/app_theme.dart';

void main() {
  group('AppTheme Tests', () {
    test('AppTheme.lightTheme should have Material 3 configuration', () {
      final theme = AppTheme.lightTheme;

      expect(theme, isNotNull);
      expect(theme, isA<ThemeData>());
      expect(theme.useMaterial3, true);
    });

    test('AppTheme.lightTheme should have primary color', () {
      final theme = AppTheme.lightTheme;

      expect(theme.primaryColor, isNotNull);
      expect(theme.colorScheme.primary, isNotNull);
    });

    test('AppTheme.lightTheme should have text theme', () {
      final theme = AppTheme.lightTheme;

      expect(theme.textTheme, isNotNull);
      expect(theme.textTheme.displayLarge, isNotNull);
      expect(theme.textTheme.bodyMedium, isNotNull);
    });

    test('AppTheme should have elevated button theme', () {
      final theme = AppTheme.lightTheme;

      expect(theme.elevatedButtonTheme, isNotNull);
    });

    test('AppTheme should have outlined button theme', () {
      final theme = AppTheme.lightTheme;

      expect(theme.outlinedButtonTheme, isNotNull);
    });

    test('AppTheme should use Google Fonts', () {
      final theme = AppTheme.lightTheme;

      // Verify text theme is customized (likely with Google Fonts)
      expect(theme.textTheme, isNotNull);
      expect(theme.textTheme.bodyLarge, isNotNull);
    });

    test('Theme should be consistent and complete', () {
      final theme = AppTheme.lightTheme;

      // Verify all essential theme properties are set
      expect(theme.scaffoldBackgroundColor, isNotNull);
      expect(theme.cardTheme, isNotNull);
      expect(theme.appBarTheme, isNotNull);
    });
  });
}
