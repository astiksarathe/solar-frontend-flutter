class PrepaymentDetail {
  final int month;
  final double amount;

  PrepaymentDetail({required this.month, required this.amount});
}

class LoanCalculationInput {
  final double loanAmount;
  final double annualRate;
  final int? tenureMonths;
  final double? emi;
  final List<PrepaymentDetail> prepayments;
  final String mode; // 'reduceTenure' or 'reduceEMI'

  LoanCalculationInput({
    required this.loanAmount,
    required this.annualRate,
    this.tenureMonths,
    this.emi,
    this.prepayments = const [],
    this.mode = 'reduceTenure',
  });
}

class LoanBreakdownEntry {
  final int month;
  final String emi;
  final String interest;
  final String principal;
  final String prepayment;
  final String remainingPrincipal;

  LoanBreakdownEntry({
    required this.month,
    required this.emi,
    required this.interest,
    required this.principal,
    required this.prepayment,
    required this.remainingPrincipal,
  });
}

class LoanCalculationResult {
  final double loanAmount;
  final double annualRate;
  final String emi;
  final String mode;
  final String totalInterest;
  final String totalPaid;
  final int totalMonths;
  final List<LoanBreakdownEntry> breakdown;

  LoanCalculationResult({
    required this.loanAmount,
    required this.annualRate,
    required this.emi,
    required this.mode,
    required this.totalInterest,
    required this.totalPaid,
    required this.totalMonths,
    required this.breakdown,
  });
}

class EMICalculation {
  final double emi;
  final double totalInterest;
  final double totalPayment;
  final int? totalMonths;
  final double principalAmount;

  EMICalculation({
    required this.emi,
    required this.totalInterest,
    required this.totalPayment,
    this.totalMonths,
    required this.principalAmount,
  });

  factory EMICalculation.empty() {
    return EMICalculation(
      emi: 0,
      totalInterest: 0,
      totalPayment: 0,
      totalMonths: 0,
      principalAmount: 0,
    );
  }
}
