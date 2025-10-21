import 'dart:math';
import '../models/emi_models.dart';

class EMICalculatorService {
  static LoanCalculationResult calculateLoanWithPrepayments(
    LoanCalculationInput input,
  ) {
    final loanAmount = input.loanAmount;
    final annualRate = input.annualRate;
    int? tenureMonths = input.tenureMonths;
    double? emi = input.emi;
    final prepayments = input.prepayments;
    final mode = input.mode;

    final monthlyRate = annualRate / 12 / 100;

    // Calculate missing value (EMI or tenure)
    if (emi == null && tenureMonths != null) {
      emi =
          (loanAmount * monthlyRate * pow(1 + monthlyRate, tenureMonths)) /
          (pow(1 + monthlyRate, tenureMonths) - 1);
    } else if (emi != null && tenureMonths == null) {
      // Estimate tenure iteratively
      double tempPrincipal = loanAmount;
      int months = 0;

      while (tempPrincipal > 0 && months < 1000) {
        final interest = tempPrincipal * monthlyRate;
        final principal = emi - interest;
        if (principal <= 0) {
          throw Exception('EMI too small for given interest rate.');
        }
        tempPrincipal -= principal;
        months++;
      }
      tenureMonths = months;
    } else if (emi == null && tenureMonths == null) {
      throw Exception('Provide either EMI or tenureMonths.');
    }

    final safeEMI = emi!;
    final safeTenure = tenureMonths!;

    // Initialize
    double remainingPrincipal = loanAmount;
    double totalInterest = 0;
    double currentEMI = safeEMI;
    final List<LoanBreakdownEntry> breakdown = [];
    int month = 0;

    // Month-by-month breakdown
    while (remainingPrincipal > 0 && month < 1000) {
      month++;

      final interest = remainingPrincipal * monthlyRate;
      double principal = currentEMI - interest;

      // Adjust for final month
      if (principal > remainingPrincipal) {
        principal = remainingPrincipal;
        currentEMI = principal + interest;
      }

      remainingPrincipal -= principal;
      totalInterest += interest;

      // Apply prepayment for this month if any
      final prepay = prepayments.where((p) => p.month == month).firstOrNull;
      double prepayAmount = 0;

      if (prepay != null) {
        prepayAmount = prepay.amount;
        remainingPrincipal -= prepayAmount;

        if (remainingPrincipal < 0) remainingPrincipal = 0;

        if (mode == 'reduceEMI' && remainingPrincipal > 0) {
          final remainingMonths = safeTenure - month;
          currentEMI =
              (remainingPrincipal *
                  monthlyRate *
                  pow(1 + monthlyRate, remainingMonths)) /
              (pow(1 + monthlyRate, remainingMonths) - 1);
        }
      }

      breakdown.add(
        LoanBreakdownEntry(
          month: month,
          emi: currentEMI.toStringAsFixed(2),
          interest: interest.toStringAsFixed(2),
          principal: principal.toStringAsFixed(2),
          prepayment: prepayAmount.toStringAsFixed(2),
          remainingPrincipal: remainingPrincipal.toStringAsFixed(2),
        ),
      );

      if (remainingPrincipal <= 0) break;
    }

    final totalPaid = breakdown.fold<double>(
      0,
      (sum, r) => sum + double.parse(r.emi) + double.parse(r.prepayment),
    );

    return LoanCalculationResult(
      loanAmount: loanAmount,
      annualRate: annualRate,
      emi: safeEMI.toStringAsFixed(2),
      mode: mode,
      totalInterest: totalInterest.toStringAsFixed(2),
      totalPaid: totalPaid.toStringAsFixed(2),
      totalMonths: breakdown.length,
      breakdown: breakdown,
    );
  }

  static EMICalculation calculateEMI({
    required String loanAmount,
    required String interestRate,
    String? loanTerm,
    String? targetEMI,
    required String loanTermUnit,
    required bool hasPrePayment,
    String? prePaymentAmount,
    String? prePaymentStart,
    required String prePaymentType,
    required String calculationMode,
  }) {
    // Validation check for required fields
    if (loanAmount.isEmpty || interestRate.isEmpty) {
      return EMICalculation.empty();
    }

    if (calculationMode == 'tenure' && (loanTerm?.isEmpty ?? true)) {
      return EMICalculation(
        emi: 0,
        totalInterest: 0,
        totalPayment: 0,
        principalAmount: double.tryParse(loanAmount) ?? 0,
      );
    }

    if (calculationMode == 'emi' && (targetEMI?.isEmpty ?? true)) {
      return EMICalculation(
        emi: 0,
        totalInterest: 0,
        totalPayment: 0,
        principalAmount: double.tryParse(loanAmount) ?? 0,
      );
    }

    final principal = double.tryParse(loanAmount) ?? 0;
    final termValue = int.tryParse(loanTerm ?? '0') ?? 0;
    int totalMonths = loanTermUnit == 'years' ? termValue * 12 : termValue;

    // Build input for util
    final input = LoanCalculationInput(
      loanAmount: principal,
      annualRate: double.tryParse(interestRate) ?? 0,
      tenureMonths: totalMonths > 0 ? totalMonths : null,
      emi: calculationMode == 'emi' ? double.tryParse(targetEMI ?? '0') : null,
      prepayments: [],
      mode: calculationMode == 'emi' ? 'reduceEMI' : 'reduceTenure',
    );

    if (hasPrePayment &&
        prePaymentAmount != null &&
        prePaymentStart != null &&
        prePaymentAmount.isNotEmpty &&
        prePaymentStart.isNotEmpty) {
      final prePayment = double.tryParse(prePaymentAmount) ?? 0;
      final startPeriod = double.tryParse(prePaymentStart) ?? 0;

      // Interpret prepayment type into a month index
      int monthIndex = 0;
      if (prePaymentType == 'year') {
        monthIndex = max(1, (startPeriod * 12).round());
      } else if (prePaymentType == 'month') {
        monthIndex = max(1, startPeriod.round());
      } else if (prePaymentType == 'installment') {
        monthIndex = max(1, startPeriod.round());
      }

      input.prepayments.add(
        PrepaymentDetail(month: monthIndex, amount: prePayment),
      );
    }

    try {
      final result = calculateLoanWithPrepayments(input);

      return EMICalculation(
        emi: double.tryParse(result.emi) ?? 0,
        totalInterest: double.tryParse(result.totalInterest) ?? 0,
        totalPayment: double.tryParse(result.totalPaid) ?? 0,
        totalMonths: result.totalMonths,
        principalAmount: principal,
      );
    } catch (e) {
      print('EMI calculation error: $e');
      return EMICalculation(
        emi: 0,
        totalInterest: 0,
        totalPayment: 0,
        principalAmount: principal,
      );
    }
  }
}

extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
