import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/emi_models.dart';
import '../services/emi_calculator_service.dart';
import '../theme/app_theme.dart';

class EMICalculatorScreen extends StatefulWidget {
  const EMICalculatorScreen({super.key});

  @override
  State<EMICalculatorScreen> createState() => _EMICalculatorScreenState();
}

class _EMICalculatorScreenState extends State<EMICalculatorScreen> {
  // Form Controllers
  final TextEditingController _loanAmountController = TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _loanTermController = TextEditingController();
  final TextEditingController _targetEMIController = TextEditingController();
  final TextEditingController _prePaymentAmountController =
      TextEditingController();
  final TextEditingController _prePaymentStartController =
      TextEditingController();

  // Form States
  String _loanTermUnit = 'years';
  bool _hasPrePayment = false;
  String _prePaymentType = 'year';
  String _calculationMode = 'tenure'; // 'tenure' or 'emi'
  bool _showTotalInterest = false;

  // Calculation Results
  EMICalculation _calculation = EMICalculation.empty();

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Add listeners to all text controllers for debounced calculation
    _loanAmountController.addListener(_onInputChanged);
    _interestRateController.addListener(_onInputChanged);
    _loanTermController.addListener(_onInputChanged);
    _targetEMIController.addListener(_onInputChanged);
    _prePaymentAmountController.addListener(_onInputChanged);
    _prePaymentStartController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _loanAmountController.dispose();
    _interestRateController.dispose();
    _loanTermController.dispose();
    _targetEMIController.dispose();
    _prePaymentAmountController.dispose();
    _prePaymentStartController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _calculateEMI();
    });
  }

  void _onModeChanged() {
    // Clear mode-specific fields when switching tabs
    _loanAmountController.clear();
    _interestRateController.clear();
    _loanTermController.clear();
    _targetEMIController.clear();
    _hasPrePayment = false;
    _prePaymentAmountController.clear();
    _prePaymentStartController.clear();
    setState(() {
      _calculation = EMICalculation.empty();
    });
  }

  void _calculateEMI() {
    final result = EMICalculatorService.calculateEMI(
      loanAmount: _loanAmountController.text,
      interestRate: _interestRateController.text,
      loanTerm: _loanTermController.text,
      targetEMI: _targetEMIController.text,
      loanTermUnit: _loanTermUnit,
      hasPrePayment: _hasPrePayment,
      prePaymentAmount: _prePaymentAmountController.text,
      prePaymentStart: _prePaymentStartController.text,
      prePaymentType: _prePaymentType,
      calculationMode: _calculationMode,
    );

    setState(() {
      _calculation = result;
    });
  }

  String _formatCurrency(double amount) {
    return '₹${amount.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},')}';
  }

  String _formatMonthsToYearsMonths(int? months) {
    final m = months ?? 0;
    final yrs = m ~/ 12;
    final remMonths = m % 12;
    if (yrs > 0 && remMonths > 0) return '$yrs yrs $remMonths m';
    if (yrs > 0) return '$yrs yrs';
    return '$remMonths months';
  }

  Widget _buildSegmentedButton() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calculation Mode',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_calculationMode != 'tenure') {
                        setState(() {
                          _calculationMode = 'tenure';
                        });
                        _onModeChanged();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _calculationMode == 'tenure'
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      child: Text(
                        'Calculate EMI',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _calculationMode == 'tenure'
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_calculationMode != 'emi') {
                        setState(() {
                          _calculationMode = 'emi';
                        });
                        _onModeChanged();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _calculationMode == 'emi'
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      child: Text(
                        'Calculate Tenure',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _calculationMode == 'emi'
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanDetailsCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Loan Details',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // Loan Amount
            Text(
              'Loan Amount',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _loanAmountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: const InputDecoration(
                prefixText: '₹ ',
                hintText: 'Enter loan amount',
              ),
            ),
            const SizedBox(height: 16),

            // Interest Rate
            Text(
              'Interest Rate',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _interestRateController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: const InputDecoration(
                suffixText: '%',
                hintText: 'Enter interest rate',
              ),
            ),
            const SizedBox(height: 16),

            // Target EMI (when calculating tenure)
            if (_calculationMode == 'emi') ...[
              Text(
                'Target EMI Amount',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _targetEMIController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(
                  prefixText: '₹ ',
                  hintText: 'Enter target EMI',
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Loan Term (only in tenure mode)
            if (_calculationMode == 'tenure') ...[
              Text(
                'Loan Term',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _loanTermController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(hintText: '20'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _loanTermUnit,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'years', child: Text('years')),
                        DropdownMenuItem(
                          value: 'months',
                          child: Text('months'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _loanTermUnit = value!;
                        });
                        _onInputChanged();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrepaymentCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Prepayment',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Switch(
                  value: _hasPrePayment,
                  onChanged: (value) {
                    setState(() {
                      _hasPrePayment = value;
                      if (!value) {
                        _prePaymentAmountController.clear();
                        _prePaymentStartController.clear();
                      }
                    });
                    _onInputChanged();
                  },
                ),
              ],
            ),

            if (_hasPrePayment) ...[
              const SizedBox(height: 16),

              // Prepayment Amount
              Text(
                'Prepayment Amount',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _prePaymentAmountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(
                  prefixText: '₹ ',
                  hintText: 'Enter prepayment amount',
                ),
              ),
              const SizedBox(height: 16),

              // Prepayment Start
              Text(
                'Prepayment Start',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _prePaymentStartController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        hintText: 'Enter number',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _prePaymentType,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'year', child: Text('year')),
                        DropdownMenuItem(value: 'month', child: Text('month')),
                        DropdownMenuItem(
                          value: 'installment',
                          child: Text('installment'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _prePaymentType = value!;
                        });
                        _onInputChanged();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Payments',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Show Total Interest',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: _showTotalInterest,
                  onChanged: (value) {
                    setState(() {
                      _showTotalInterest = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // EMI/Duration Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  // Label
                  SizedBox(
                    width: 60,
                    child: Text(
                      _calculationMode == 'tenure' ? 'EMI' : 'Duration',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),

                  // Main Amount/Duration
                  Expanded(
                    child: Column(
                      children: [
                        if (_calculationMode == 'tenure')
                          Text(
                            _formatCurrency(_calculation.emi),
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: AppColors.lightSuccess,
                                  fontWeight: FontWeight.w700,
                                ),
                            textAlign: TextAlign.center,
                          )
                        else
                          Text(
                            _calculation.totalMonths != null
                                ? _formatMonthsToYearsMonths(
                                    _calculation.totalMonths,
                                  )
                                : '${_loanTermController.text} $_loanTermUnit',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),

                  // Total Interest (if shown)
                  if (_showTotalInterest)
                    SizedBox(
                      width: 110,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Total Interest',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatCurrency(_calculation.totalInterest),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EMI Calculator'),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              // Theme toggle - this is just a visual indicator for now
              // The theme would be controlled by the main app's theme provider
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSegmentedButton(),
            _buildLoanDetailsCard(),
            _buildPrepaymentCard(),
            _buildResultsCard(),
            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }
}
