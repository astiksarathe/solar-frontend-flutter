import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_phoenix/screens/login_screen.dart';

void main() {
  group('LoginScreen', () {
    testWidgets('should display login screen with all elements', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Verify logo and title
      expect(find.text('Solar-Stack'), findsOneWidget);
      expect(find.byIcon(Icons.wb_sunny), findsOneWidget);

      // Verify form fields
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      // Verify buttons and links
      expect(find.text('LOGIN'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);

      // Verify form fields are present
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('should validate email field', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Find email field and login button
      final emailField = find.byType(TextFormField).first;
      final loginButton = find.text('LOGIN');

      // Try to login without email
      await tester.tap(loginButton);
      await tester.pump();

      // Should show validation error
      expect(find.text('Email is required'), findsOneWidget);

      // Enter invalid email
      await tester.enterText(emailField, 'invalid-email');
      await tester.tap(loginButton);
      await tester.pump();

      // Should show validation error
      expect(find.text('Please enter a valid email'), findsOneWidget);

      // Enter valid email
      await tester.enterText(emailField, 'test@example.com');
      await tester.tap(loginButton);
      await tester.pump();

      // Email validation error should be gone
      expect(find.text('Please enter a valid email'), findsNothing);
      expect(find.text('Email is required'), findsNothing);
    });

    testWidgets('should validate password field', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Find password field and login button
      final passwordField = find.byType(TextFormField).last;
      final loginButton = find.text('LOGIN');

      // Try to login without password
      await tester.tap(loginButton);
      await tester.pump();

      // Should show validation error
      expect(find.text('Password is required'), findsOneWidget);

      // Enter short password
      await tester.enterText(passwordField, '123');
      await tester.tap(loginButton);
      await tester.pump();

      // Should show validation error
      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );

      // Enter valid password
      await tester.enterText(passwordField, 'password123');
      await tester.tap(loginButton);
      await tester.pump();

      // Password validation error should be gone
      expect(find.text('Password must be at least 6 characters'), findsNothing);
      expect(find.text('Password is required'), findsNothing);
    });

    testWidgets('should toggle password visibility', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Find password field
      final passwordField = find.byType(TextFormField).last;

      // Enter password
      await tester.enterText(passwordField, 'testpassword');
      await tester.pump();

      // Find visibility toggle button
      final visibilityButton = find.byIcon(Icons.visibility);
      expect(visibilityButton, findsOneWidget);

      // Tap to show password
      await tester.tap(visibilityButton);
      await tester.pump();

      // Icon should change to visibility_off
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsNothing);

      // Tap again to hide password
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      // Icon should change back to visibility
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNothing);
    });

    testWidgets('should handle forgot password tap', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Tap forgot password
      await tester.tap(find.text('Forgot Password?'));
      await tester.pump();

      // Should show snackbar
      expect(
        find.text('Forgot password functionality coming soon!'),
        findsOneWidget,
      );
    });

    testWidgets('should handle sign up tap', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Tap sign up link
      await tester.tap(find.text('Sign up'));
      await tester.pump();

      // Should show snackbar
      expect(find.text('Sign up functionality coming soon!'), findsOneWidget);
    });

    testWidgets('should show loading state during login', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Enter valid credentials
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      // Tap login button
      await tester.tap(find.text('LOGIN'));
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('LOGIN'), findsNothing);
    });

    testWidgets('should handle form submission with valid data', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Enter valid credentials
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      // Tap login button
      await tester.tap(find.text('LOGIN'));
      await tester.pump();

      // Should show loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for login to complete (but don't wait for navigation)
      await tester.pump(const Duration(milliseconds: 100));

      // Login process should be in progress
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
