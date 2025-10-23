import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_phoenix/screens/forgot_password_screen.dart';

void main() {
  group('ForgotPasswordScreen Tests', () {
    testWidgets('should display forgot password screen with all elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));

      // Check if the screen displays correctly
      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text('Reset Your Password'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('New Password'), findsOneWidget);
      expect(find.text('Confirm New Password'), findsOneWidget);
      expect(find.text('RESET PASSWORD'), findsOneWidget);
      expect(find.text('Remember your password?'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('should validate email field', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));

      // Try to submit with invalid email
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.tap(find.text('RESET PASSWORD'));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should validate password confirmation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));

      final textFields = find.byType(TextFormField);

      // Enter different passwords
      await tester.enterText(textFields.at(1), 'password123');
      await tester.enterText(textFields.at(2), 'differentpassword');
      await tester.tap(find.text('RESET PASSWORD'));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });
}
