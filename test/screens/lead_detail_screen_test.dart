import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_phoenix/screens/lead_detail_screen.dart';
import 'package:solar_phoenix/services/lead_service.dart';
import 'package:solar_phoenix/models/lead_models.dart';

void main() {
  group('LeadDetailScreen', () {
    setUp(() {
      // Add a test lead
      LeadService.addLead(
        Lead(
          id: 'test_detail_1',
          name: 'Test Detail User',
          phone: '9876543210',
          divisionName: 'Test Division',
          monthlyUnits: '150',
          amount: '15000',
          purpose: 'Residential',
          avgUnits: '145',
          reminderAt: DateTime.now().add(const Duration(days: 3)),
          reminderType: 'callback',
          reminderNote: 'Follow up on system sizing',
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

    testWidgets('should display lead detail screen with lead information', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: LeadDetailScreen(leadId: 'test_detail_1')),
      );

      // Wait for loading to complete
      await tester.pump(const Duration(milliseconds: 600));

      // Verify lead name is displayed
      expect(find.text('Test Detail User'), findsOneWidget);

      // Verify phone number is displayed
      expect(find.text('9876543210'), findsOneWidget);

      // Verify solar requirements section
      expect(find.text('Solar requirements'), findsOneWidget);
      expect(find.text('Monthly units'), findsOneWidget);
      expect(find.text('150'), findsOneWidget);
    });

    testWidgets('should display reminder information when present', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: LeadDetailScreen(leadId: 'test_detail_1')),
      );

      // Wait for loading to complete
      await tester.pump(const Duration(milliseconds: 600));

      // Verify reminder section
      expect(find.text('Reminder'), findsOneWidget);
      expect(find.text('CALLBACK'), findsOneWidget);
      expect(find.text('Follow up on system sizing'), findsOneWidget);
    });

    testWidgets('should display history section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LeadDetailScreen(leadId: 'test_detail_1')),
      );

      // Wait for loading to complete
      await tester.pump(const Duration(milliseconds: 600));

      // Verify history section
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Call'), findsOneWidget);
      expect(find.text('Meeting'), findsOneWidget);
      expect(find.text('Note'), findsOneWidget);
    });

    testWidgets('should open action sheet when FAB is tapped', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LeadDetailScreen(leadId: 'test_detail_1')),
      );

      // Wait for loading to complete
      await tester.pump(const Duration(milliseconds: 600));

      // Tap FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // Verify action sheet is displayed
      expect(find.text('Call'), findsOneWidget);
      expect(find.text('Schedule meeting'), findsOneWidget);
      expect(find.text('Add note'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('should handle non-existent lead ID', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LeadDetailScreen(leadId: 'non_existent')),
      );

      // Wait for loading to complete
      await tester.pump(const Duration(milliseconds: 600));

      // Should show sample lead since ID doesn't exist
      expect(find.text('Sample Lead'), findsOneWidget);
    });

    testWidgets('should close action sheet when cancel is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: LeadDetailScreen(leadId: 'test_detail_1')),
      );

      // Wait for loading to complete
      await tester.pump(const Duration(milliseconds: 600));

      // Open action sheet
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pump();

      // Action sheet should be closed (only one Cancel button remaining)
      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('should trigger call action', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LeadDetailScreen(leadId: 'test_detail_1')),
      );

      // Wait for loading to complete
      await tester.pump(const Duration(milliseconds: 600));

      // Open action sheet
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // Tap call option
      await tester.tap(find.text('Call'));
      await tester.pump();

      // Should show alert dialog
      expect(find.text('Call'), findsOneWidget);
      expect(find.text('Calling 9876543210...'), findsOneWidget);
    });
  });
}
