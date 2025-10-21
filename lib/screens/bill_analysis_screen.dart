import 'package:flutter/material.dart';

class BillAnalysisScreen extends StatefulWidget {
  const BillAnalysisScreen({super.key});

  @override
  State<BillAnalysisScreen> createState() => _BillAnalysisScreenState();
}

class _BillAnalysisScreenState extends State<BillAnalysisScreen> {
  final _unitsController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic>? _analysisResult;
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _unitsController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _analyzeBill() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isAnalyzing = true;
    });

    // Simulate analysis
    await Future.delayed(const Duration(seconds: 2));

    final units = double.tryParse(_unitsController.text) ?? 0;
    final amount = double.tryParse(_amountController.text) ?? 0;
    final ratePerUnit = units > 0 ? amount / units : 0;

    // Solar savings calculation
    final solarCapacity = (units / 30 / 4)
        .ceilToDouble(); // Assuming 4 hours sun
    final monthlySolarGeneration = solarCapacity * 4 * 30;
    final potentialSavings = monthlySolarGeneration * ratePerUnit;
    final annualSavings = potentialSavings * 12;

    setState(() {
      _analysisResult = {
        'currentUnits': units,
        'currentAmount': amount,
        'ratePerUnit': ratePerUnit,
        'recommendedCapacity': solarCapacity,
        'monthlySolarGeneration': monthlySolarGeneration,
        'monthlySavings': potentialSavings,
        'annualSavings': annualSavings,
        'paybackPeriod':
            (solarCapacity * 60000) / annualSavings, // Assuming ₹60k per kW
      };
      _isAnalyzing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.1),
                    colorScheme.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.receipt_long,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bill Analysis',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Analyze your electricity bill and discover solar savings',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Input Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter Bill Details',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _unitsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Monthly Units (kWh)',
                          hintText: 'Enter consumed units',
                          prefixIcon: Icon(Icons.electric_meter),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter units consumed';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Bill Amount (₹)',
                          hintText: 'Enter total bill amount',
                          prefixIcon: Icon(Icons.currency_rupee),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter bill amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isAnalyzing ? null : _analyzeBill,
                          icon: _isAnalyzing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.analytics),
                          label: Text(
                            _isAnalyzing ? 'Analyzing...' : 'Analyze Bill',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (_analysisResult != null) ...[
              const SizedBox(height: 24),

              // Analysis Results
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.insights, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Analysis Results',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildAnalysisRow(
                        'Current Rate per Unit',
                        '₹${_analysisResult!['ratePerUnit'].toStringAsFixed(2)}',
                        Icons.electric_meter,
                        colorScheme,
                      ),

                      _buildAnalysisRow(
                        'Recommended Solar Capacity',
                        '${_analysisResult!['recommendedCapacity'].toStringAsFixed(1)} kW',
                        Icons.solar_power,
                        colorScheme,
                      ),

                      _buildAnalysisRow(
                        'Monthly Solar Generation',
                        '${_analysisResult!['monthlySolarGeneration'].toStringAsFixed(0)} kWh',
                        Icons.wb_sunny,
                        colorScheme,
                      ),

                      _buildAnalysisRow(
                        'Monthly Savings',
                        '₹${_analysisResult!['monthlySavings'].toStringAsFixed(0)}',
                        Icons.savings,
                        colorScheme,
                      ),

                      _buildAnalysisRow(
                        'Annual Savings',
                        '₹${_analysisResult!['annualSavings'].toStringAsFixed(0)}',
                        Icons.trending_up,
                        colorScheme,
                      ),

                      _buildAnalysisRow(
                        'Payback Period',
                        '${_analysisResult!['paybackPeriod'].toStringAsFixed(1)} years',
                        Icons.schedule,
                        colorScheme,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Share analysis
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Analysis shared!')),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        // Generate quote
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Quote generation coming soon!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.description),
                      label: const Text('Get Quote'),
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

  Widget _buildAnalysisRow(
    String label,
    String value,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8)),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
