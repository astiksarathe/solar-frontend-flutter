import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_phoenix/screens/directory_screen.dart';
import 'package:solar_phoenix/services/lead_service.dart';
import 'package:solar_phoenix/models/lead_models.dart';

void main() {
  group('DirectoryScreen', () {
    setUp(() {
      // Add some test leads
      LeadService.addLead(
        Lead(
          id: 'test_1',
          name: 'Test User 1',
          phone: '1234567890',
          divisionName: 'Test Division',
          consumerNumber: 'TEST001',
          monthlyUnits: '100',
          amount: '1000',
          purpose: 'Residential',
        ),
      );

      LeadService.addLead(
        Lead(
          id: 'test_2',
          name: 'Test User 2',
          phone: '0987654321',
          divisionName: 'Test Division 2',
          consumerNumber: 'TEST002',
          monthlyUnits: '200',
          amount: '2000',
          purpose: 'Commercial',
          reminderAt: DateTime.now().add(const Duration(days: 1)),
          reminderType: 'call',
        ),
      );
    });

    tearDown(() {
      // Clear leads after each test
      final leads = LeadService.getLeads();
      for (final lead in leads) {
        if (lead.id != null) {
          LeadService.deleteLead(lead.id!);
        }
      }
    });

    testWidgets('should display directory screen with leads', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DirectoryScreen()));

      // Wait for loading to complete
      await tester.pump(const Duration(milliseconds: 600));

      // Verify screen title
      expect(find.text('Directory'), findsOneWidget);

      // Verify search bar
      expect(find.byType(TextField), findsOneWidget);

      // Verify filter button
      expect(find.text('Filter'), findsOneWidget);
    });

    testWidgets('should filter leads by search query', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DirectoryScreen()));

      // Wait for loading to complete
      await tester.pump(const Duration(milliseconds: 600));

      // Find and tap search field
      final searchField = find.byType(TextField);
      await tester.tap(searchField);
      await tester.pump();

      // Enter search query
      await tester.enterText(searchField, 'Test User 1');
      await tester.pump();

      // Verify only matching lead is shown
      expect(find.text('Test User 1'), findsOneWidget);
      expect(find.text('Test User 2'), findsNothing);
    });

    testWidgets('should show empty state when no leads match search', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: DirectoryScreen()));

      // Wait for loading to complete
      await tester.pump(const Duration(milliseconds: 600));

      // Search for non-existent lead
      final searchField = find.byType(TextField);
      await tester.tap(searchField);
      await tester.enterText(searchField, 'Non-existent User');
      await tester.pump();

      // Verify empty state
      expect(find.text('No leads found'), findsOneWidget);
    });

    testWidgets('should open filter modal when filter button is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: DirectoryScreen()));

      // Wait for loading to complete
      await tester.pump(const Duration(milliseconds: 600));

      // Tap filter button
      await tester.tap(find.text('Filter'));
      await tester.pump();

      // Verify modal is opened
      expect(find.text('Sort & Filter'), findsOneWidget);
    });

    testWidgets('should display lead count', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DirectoryScreen()));

      // Wait for loading to complete
      await tester.pump(const Duration(milliseconds: 600));

      // Verify lead count is displayed (should include test leads + sample leads)
      expect(find.textContaining('leads'), findsOneWidget);
    });
  });
}
