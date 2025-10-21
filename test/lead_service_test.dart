import 'package:flutter_test/flutter_test.dart';
import 'package:solar_phoenix/models/lead_models.dart';
import 'package:solar_phoenix/services/lead_service.dart';

void main() {
  group('Lead Service Tests', () {
    setUp(() {
      // Clear leads before each test
      LeadService.clearLeads();
    });

    test('Should add a new lead successfully', () async {
      final lead = Lead(
        name: 'John Doe',
        phone: '9876543210',
        divisionName: 'Mumbai',
      );

      final success = await LeadService.addLead(lead);
      expect(success, isTrue);

      final leads = LeadService.getLeads();
      expect(leads.length, equals(1));
      expect(leads.first.name, equals('John Doe'));
      expect(leads.first.phone, equals('9876543210'));
    });

    test('Should validate phone numbers correctly', () {
      expect(LeadService.validatePhone('9876543210'), isTrue); // 10 digits
      expect(
        LeadService.validatePhone('+919876543210'),
        isTrue,
      ); // 13 digits with +91
      expect(LeadService.validatePhone('987654321'), isFalse); // 9 digits
      expect(
        LeadService.validatePhone('98765432101234567'),
        isFalse,
      ); // 17 digits
      expect(
        LeadService.validatePhone('abc1234567'),
        isTrue,
      ); // Non-digits are filtered
    });

    test('Should search leads by name and phone', () async {
      final lead1 = Lead(name: 'John Doe', phone: '9876543210');
      final lead2 = Lead(name: 'Jane Smith', phone: '9123456789');
      final lead3 = Lead(
        name: 'Bob Johnson',
        phone: '9555666777',
        divisionName: 'Delhi',
      );

      await LeadService.addLead(lead1);
      await LeadService.addLead(lead2);
      await LeadService.addLead(lead3);

      // Search by name
      var results = LeadService.searchLeads('john');
      expect(results.length, equals(2)); // John Doe and Bob Johnson

      // Search by phone
      results = LeadService.searchLeads('9876');
      expect(results.length, equals(1));
      expect(results.first.name, equals('John Doe'));

      // Search by city
      results = LeadService.searchLeads('delhi');
      expect(results.length, equals(1));
      expect(results.first.name, equals('Bob Johnson'));
    });

    test('Should format phone numbers correctly', () {
      expect(LeadService.formatPhone('9876543210'), equals('987-654-3210'));
      expect(
        LeadService.formatPhone('+91-9876543210'),
        equals('+91-9876543210'),
      ); // Non-10 digit
      expect(LeadService.formatPhone('123'), equals('123')); // Too short
    });

    test('Should delete leads successfully', () async {
      final lead = Lead(name: 'Test User', phone: '9876543210');
      await LeadService.addLead(lead);

      var leads = LeadService.getLeads();
      expect(leads.length, equals(1));

      final leadId = leads.first.id!;
      final success = await LeadService.deleteLead(leadId);
      expect(success, isTrue);

      leads = LeadService.getLeads();
      expect(leads.length, equals(0));
    });

    test('Should update leads successfully', () async {
      final lead = Lead(name: 'Original Name', phone: '9876543210');
      await LeadService.addLead(lead);

      var leads = LeadService.getLeads();
      final originalLead = leads.first;

      final updatedLead = originalLead.copyWith(name: 'Updated Name');
      final success = await LeadService.updateLead(updatedLead);
      expect(success, isTrue);

      leads = LeadService.getLeads();
      expect(leads.first.name, equals('Updated Name'));
      expect(leads.first.phone, equals('9876543210')); // Phone unchanged
    });
  });

  group('Lead Model Tests', () {
    test('Should create Lead from JSON correctly', () {
      final json = {
        'id': 'lead_123',
        'name': 'Test User',
        'phone': '9876543210',
        'divisionName': 'Mumbai',
        'createdAt': '2023-01-01T00:00:00.000Z',
        'status': 'active',
      };

      final lead = Lead.fromJson(json);
      expect(lead.id, equals('lead_123'));
      expect(lead.name, equals('Test User'));
      expect(lead.phone, equals('9876543210'));
      expect(lead.divisionName, equals('Mumbai'));
      expect(lead.status, equals('active'));
    });

    test('Should convert Lead to JSON correctly', () {
      final lead = Lead(
        id: 'lead_123',
        name: 'Test User',
        phone: '9876543210',
        divisionName: 'Mumbai',
        status: 'active',
      );

      final json = lead.toJson();
      expect(json['id'], equals('lead_123'));
      expect(json['name'], equals('Test User'));
      expect(json['phone'], equals('9876543210'));
      expect(json['divisionName'], equals('Mumbai'));
      expect(json['status'], equals('active'));
    });

    test('Should handle copyWith correctly', () {
      final original = Lead(
        id: 'lead_123',
        name: 'Original Name',
        phone: '9876543210',
      );

      final updated = original.copyWith(name: 'Updated Name');
      expect(updated.id, equals(original.id));
      expect(updated.name, equals('Updated Name'));
      expect(updated.phone, equals(original.phone));
    });
  });
}
