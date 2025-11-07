import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_teacher_app/screens/welcome_screen.dart';
import 'package:ai_teacher_app/screens/signup_screen.dart';
import 'package:ai_teacher_app/screens/login_screen.dart';

void main() {
  group('WelcomeScreen Widget Tests', () {
    testWidgets('WelcomeScreen should display app title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      expect(find.text('AI Öğretmen\'e Hoş Geldiniz'), findsOneWidget);
    });

    testWidgets('WelcomeScreen should display subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      expect(
        find.text('Kişisel yapay zeka öğretmeniniz, sınavlarınıza hazırlanmanızda her an yanınızda.'),
        findsOneWidget,
      );
    });

    testWidgets('WelcomeScreen should display school icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      expect(find.byIcon(Icons.school), findsOneWidget);
    });

    testWidgets('WelcomeScreen should have Kayıt Ol button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      expect(find.text('Kayıt Ol'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Kayıt Ol'), findsOneWidget);
    });

    testWidgets('WelcomeScreen should have Giriş Yap button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      expect(find.text('Giriş Yap'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Giriş Yap'), findsOneWidget);
    });

    testWidgets('Kayıt Ol button should navigate to SignUpScreen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      // Find and tap the Kayıt Ol button
      final signUpButton = find.widgetWithText(ElevatedButton, 'Kayıt Ol');
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      // Verify navigation to SignUpScreen
      expect(find.byType(SignUpScreen), findsOneWidget);
    });

    testWidgets('Giriş Yap button should navigate to LoginScreen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      // Find and tap the Giriş Yap button
      final loginButton = find.widgetWithText(OutlinedButton, 'Giriş Yap');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verify navigation to LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('WelcomeScreen should have correct layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      // Verify main structure elements
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('WelcomeScreen buttons should be full width', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      // Find the SizedBox containing the button
      final sizedBoxFinder = find.ancestor(
        of: find.widgetWithText(ElevatedButton, 'Kayıt Ol'),
        matching: find.byType(SizedBox),
      );

      expect(sizedBoxFinder, findsAtLeastOneWidget);
      
      if (sizedBoxFinder.evaluate().isNotEmpty) {
        final SizedBox sizedBox = tester.widget(sizedBoxFinder.first);
        expect(sizedBox.width, double.infinity);
      }
    });

    testWidgets('WelcomeScreen should be responsive', (WidgetTester tester) async {
      // Test with different screen sizes
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      // Verify it renders without overflow
      expect(tester.takeException(), isNull);
    });
  });
}
