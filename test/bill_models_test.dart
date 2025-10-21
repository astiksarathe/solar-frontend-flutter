import 'package:flutter_test/flutter_test.dart';
import 'package:solar_phoenix/models/bill_models.dart';

void main() {
  group('Bill Models Tests', () {
    test('BillData.fromJson should parse JSON correctly', () {
      final jsonData = {
        'consumerDetails': {
          'name': 'John Doe',
          'consumerNo': '123456789',
          'address': '123 Test Street',
          'mobile': '9876543210',
          'purpose': 'Residential',
        },
        'billAnalysis': {
          'totalBills': 6,
          'last6MonthsData': [
            {'billMonth': 'January', 'consumption': '100'},
            {'billMonth': 'February', 'consumption': '120'},
          ],
          'averageConsumption': 110.0,
          'averageBill': 1500.0,
          'totalConsumption': 660.0,
          'totalAmount': 9000.0,
        },
        'solarRecommendation': {
          'dailyRequirement': 15.0,
          'requiredSystemSize': 3.0,
          'recommendedSystemSize': 5.0,
          'reasonForRecommendation': 'Based on usage pattern',
          'savings': {
            'monthlyBillSavings': 1200.0,
            'annualSavings': 14400.0,
            'paybackPeriod': 7.5,
          },
        },
      };

      final billData = BillData.fromJson(jsonData);

      expect(billData.consumerDetails.name, equals('John Doe'));
      expect(billData.consumerDetails.consumerNo, equals('123456789'));
      expect(billData.billAnalysis.totalBills, equals(6));
      expect(billData.billAnalysis.averageConsumption, equals(110.0));
      expect(billData.solarRecommendation.recommendedSystemSize, equals(5.0));
      expect(
        billData.solarRecommendation.savings.monthlyBillSavings,
        equals(1200.0),
      );
    });

    test('ApiResponse should handle success and failure', () {
      // Test successful response
      final successJson = {
        'success': true,
        'data': {
          'consumerDetails': {
            'name': 'Test User',
            'consumerNo': '123',
            'address': 'Test Address',
            'mobile': '1234567890',
            'purpose': 'Test',
          },
          'billAnalysis': {
            'totalBills': 1,
            'last6MonthsData': [],
            'averageConsumption': 0,
            'averageBill': 0,
            'totalConsumption': 0,
            'totalAmount': 0,
          },
          'solarRecommendation': {
            'dailyRequirement': 0,
            'requiredSystemSize': 0,
            'recommendedSystemSize': 0,
            'reasonForRecommendation': '',
            'savings': {
              'monthlyBillSavings': 0,
              'annualSavings': 0,
              'paybackPeriod': 0,
            },
          },
        },
      };

      final successResponse = ApiResponse.fromJson(successJson);
      expect(successResponse.success, isTrue);
      expect(successResponse.data, isNotNull);
      expect(successResponse.data!.consumerDetails.name, equals('Test User'));

      // Test failure response
      final failureJson = {'success': false, 'message': 'Consumer not found'};

      final failureResponse = ApiResponse.fromJson(failureJson);
      expect(failureResponse.success, isFalse);
      expect(failureResponse.data, isNull);
      expect(failureResponse.message, equals('Consumer not found'));
    });
  });
}
