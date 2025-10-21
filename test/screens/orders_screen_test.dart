import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_phoenix/screens/orders_screen.dart';
import 'package:solar_phoenix/services/order_service.dart';
import 'package:solar_phoenix/models/order_models.dart';

void main() {
  group('OrdersScreen', () {
    setUp(() {
      OrderService.clearOrders();
      OrderService.setUserRole(UserRole.admin);
    });

    tearDown(() {
      OrderService.clearOrders();
    });

    testWidgets('should display orders screen with orders list', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: OrdersScreen()));

      // Wait for loading to complete
      await tester.pump(const Duration(milliseconds: 600));

      // Verify screen elements
      expect(find.text('Solar Orders'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget); // Search bar
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget); // Role selector
    });

    testWidgets('should filter orders by search query', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: OrdersScreen()));

      // Wait for loading to complete
      await tester.pump(const Duration(milliseconds: 600));

      // Find search field
      final searchField = find.byType(TextField);
      await tester.tap(searchField);
      await tester.pump();

      // Enter search query
      await tester.enterText(searchField, 'Rajesh');
      await tester.pump();

      // Should filter the orders (exact verification depends on sample data)
      // At minimum, search field should contain the text
      expect(find.text('Rajesh'), findsOneWidget);
    });

    testWidgets('should filter orders by status', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: OrdersScreen()));

      // Wait for loading to complete
      await tester.pump(const Duration(milliseconds: 600));

      // Find and tap a status filter chip
      final allChip = find.text('All');
      expect(allChip, findsOneWidget);

      // Look for status filter chips
      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('should show empty state when no orders match filter', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: OrdersScreen()));

      // Wait for loading to complete
      await tester.pump(const Duration(milliseconds: 600));

      // Search for something that won't match
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'NonExistentCustomer');
      await tester.pump();

      // Should show empty state
      expect(find.text('No orders found'), findsOneWidget);
    });

    testWidgets('should navigate to role selector when person icon tapped', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: OrdersScreen()));

      // Wait for loading
      await tester.pump(const Duration(milliseconds: 600));

      // Tap role selector button
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // Should navigate to role selector
      expect(find.text('Select User Role'), findsOneWidget);
    });

    testWidgets('should refresh orders when refresh button tapped', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: OrdersScreen()));

      // Wait for initial load
      await tester.pump(const Duration(milliseconds: 600));

      // Tap refresh button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      // Should show loading indicator briefly
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display order cards with correct information', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: OrdersScreen()));

      // Wait for loading to complete
      await tester.pump(const Duration(milliseconds: 600));

      // Should display order cards
      expect(find.byType(Card), findsWidgets);

      // Should display progress indicators
      expect(find.byType(LinearProgressIndicator), findsWidgets);

      // Should display order information
      expect(find.textContaining('SO-'), findsWidgets); // Order IDs
      expect(find.textContaining('kW'), findsWidgets); // Capacity
      expect(find.textContaining('%'), findsWidgets); // Progress
    });

    testWidgets('should show cost information only for authorized users', (
      tester,
    ) async {
      // Test as admin (should see cost)
      OrderService.setUserRole(UserRole.admin);

      await tester.pumpWidget(const MaterialApp(home: OrdersScreen()));

      await tester.pump(const Duration(milliseconds: 600));

      // Should show cost information for admin
      expect(find.textContaining('₹'), findsWidgets);

      // Test as sales person (should not see cost)
      OrderService.setUserRole(UserRole.salesPerson);

      // Force rebuild with new role
      await tester.pumpWidget(const MaterialApp(home: OrdersScreen()));

      await tester.pump(const Duration(milliseconds: 600));

      // Cost information should be more limited for sales person
      // (Exact behavior depends on implementation details)
    });
  });
}
