import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_phoenix/screens/signup_screen.dart';

void main() {
  group('SignUpScreen Tests', () {
    testWidgets('should display sign up screen with all elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));

      // Check if the screen displays correctly
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Join Solar-Stack today'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsWidgets);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('CREATE ACCOUNT'), findsOneWidget);
      expect(find.text('Already have an account?'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('should validate email field', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));

      // Try to submit with invalid email
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.tap(find.text('CREATE ACCOUNT'));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should validate password confirmation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));

      final textFields = find.byType(TextFormField);

      // Enter different passwords
      await tester.enterText(textFields.at(1), 'password123');
      await tester.enterText(textFields.at(2), 'differentpassword');
      await tester.tap(find.text('CREATE ACCOUNT'));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });
}
