import 'package:flutter_test/flutter_test.dart';
import 'package:solar_phoenix/services/emi_calculator_service.dart';

void main() {
  group('EMI Calculator Tests', () {
    test('Basic EMI calculation without prepayment', () {
      final result = EMICalculatorService.calculateEMI(
        loanAmount: '1000000', // 10 Lakh
        interestRate: '8.5', // 8.5%
        loanTerm: '20', // 20 years
        loanTermUnit: 'years',
        hasPrePayment: false,
        prePaymentType: 'year',
        calculationMode: 'tenure',
      );

      expect(result.emi, greaterThan(0));
      expect(result.principalAmount, equals(1000000));
      expect(result.totalInterest, greaterThan(0));
      expect(result.totalPayment, greaterThan(result.principalAmount));
    });

    test('EMI calculation with prepayment', () {
      final result = EMICalculatorService.calculateEMI(
        loanAmount: '1000000', // 10 Lakh
        interestRate: '8.5', // 8.5%
        loanTerm: '20', // 20 years
        loanTermUnit: 'years',
        hasPrePayment: true,
        prePaymentAmount: '100000', // 1 Lakh prepayment
        prePaymentStart: '5', // After 5 years
        prePaymentType: 'year',
        calculationMode: 'tenure',
      );

      expect(result.emi, greaterThan(0));
      expect(result.principalAmount, equals(1000000));
      expect(result.totalInterest, greaterThan(0));
      expect(result.totalPayment, greaterThan(result.principalAmount));
    });

    test('Tenure calculation mode', () {
      final result = EMICalculatorService.calculateEMI(
        loanAmount: '1000000', // 10 Lakh
        interestRate: '8.5', // 8.5%
        targetEMI: '8000', // Target EMI of 8000
        loanTermUnit: 'years',
        hasPrePayment: false,
        prePaymentType: 'year',
        calculationMode: 'emi',
      );

      expect(result.totalMonths, greaterThan(0));
      expect(result.principalAmount, equals(1000000));
    });

    test('Empty inputs should return zero calculation', () {
      final result = EMICalculatorService.calculateEMI(
        loanAmount: '',
        interestRate: '',
        loanTermUnit: 'years',
        hasPrePayment: false,
        prePaymentType: 'year',
        calculationMode: 'tenure',
      );

      expect(result.emi, equals(0));
      expect(result.totalInterest, equals(0));
      expect(result.totalPayment, equals(0));
    });
  });
}
