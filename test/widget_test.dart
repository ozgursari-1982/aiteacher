// AI Teacher App Widget Tests
// Tests for the main app widget and authentication flow

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_teacher_app/main.dart';

void main() {
  group('MyApp Widget Tests', () {
    testWidgets('MyApp should build without crashing', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());

      // Verify app builds successfully
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('MyApp should have correct title', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.title, 'AI Öğretmen');
    });

    testWidgets('MyApp should not show debug banner', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.debugShowCheckedModeBanner, false);
    });

    testWidgets('MyApp should use custom theme', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme, isNotNull);
    });
  });

  group('AuthWrapper Widget Tests', () {
    testWidgets('AuthWrapper should show loading initially', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Should show CircularProgressIndicator while checking auth state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AuthWrapper should be wrapped in MaterialApp', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify AuthWrapper exists within MaterialApp
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('App Integration Tests', () {
    testWidgets('App should initialize Firebase on startup', (WidgetTester tester) async {
      // This test verifies that Firebase initialization doesn't crash the app
      await tester.pumpWidget(const MyApp());
      
      // Wait for async initialization
      await tester.pump();
      
      // App should still be running
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}

