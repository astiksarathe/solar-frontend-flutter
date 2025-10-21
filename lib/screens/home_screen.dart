import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../models/bill_models.dart';
import '../services/bill_api_service.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _consumerNumberController =
      TextEditingController();

  bool _loading = false;
  bool _hasFetchedData = false;
  BillData? _billDetails;
  String? _error;

  @override
  void dispose() {
    _consumerNumberController.dispose();
    super.dispose();
  }

  Future<void> _fetchBillDetails() async {
    if (_consumerNumberController.text.trim().isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _hasFetchedData = false;
      _billDetails = null;
    });

    final response = await BillApiService.fetchBillDetails(
      _consumerNumberController.text.trim(),
    );

    setState(() {
      _loading = false;
      if (response.success && response.data != null) {
        _billDetails = response.data;
        _hasFetchedData = true;
      } else {
        _error = response.message ?? 'Failed to fetch bill details.';
      }
    });
  }

  String _formatCurrency(double amount) {
    return '₹ ${amount.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},')}';
  }

  Widget _buildInputCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your electricity consumer number',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _consumerNumberController,
              decoration: const InputDecoration(
                hintText: 'Consumer number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _loading || _consumerNumberController.text.trim().isEmpty
                    ? null
                    : _fetchBillDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightSuccess,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Fetch Bill Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConsumerDetailsCard() {
    if (_billDetails == null) return const SizedBox.shrink();

    final consumer = _billDetails!.consumerDetails;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Consumer Details',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Name:', consumer.name),
            _buildDetailRow('Consumer Number:', consumer.consumerNo),
            _buildDetailRow('Phone Number:', consumer.mobile),
            _buildDetailRow('Address:', consumer.address),
            _buildDetailRow('Connection Type:', consumer.purpose),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageChartCard() {
    if (_billDetails == null) return const SizedBox.shrink();

    final billAnalysis = _billDetails!.billAnalysis;
    final consumptionData = billAnalysis.last6MonthsData
        .map((item) => double.tryParse(item.consumption) ?? 0)
        .toList();
    final maxConsumption = consumptionData.isEmpty
        ? 0
        : consumptionData.reduce((a, b) => a > b ? a : b);
    final minConsumption = consumptionData.isEmpty
        ? 0
        : consumptionData.reduce((a, b) => a < b ? a : b);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Last 6 Months Usage',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // Chart
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxConsumption * 1.2,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 &&
                              index < billAnalysis.last6MonthsData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                billAnalysis.last6MonthsData[index].billMonth
                                    .substring(0, 3),
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: consumptionData
                      .asMap()
                      .entries
                      .map(
                        (entry) => BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value,
                              color: AppColors.lightSuccess,
                              width: 16,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            // Usage Statistics
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '${billAnalysis.totalConsumption.round()}',
                    'Total Units (6 months)',
                    Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '${billAnalysis.averageConsumption.round()}',
                    'Average Units/Month',
                    Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '${maxConsumption.round()}',
                    'Max Units/Month',
                    AppColors.lightSuccess,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '${minConsumption.round()}',
                    'Min Units/Month',
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSolarRecommendationCard() {
    if (_billDetails == null) return const SizedBox.shrink();

    final recommendation = _billDetails!.solarRecommendation;
    final billAnalysis = _billDetails!.billAnalysis;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recommended Solar System',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Based on your average monthly usage (${billAnalysis.averageConsumption.round()} units)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${recommendation.recommendedSystemSize} kW Solar System',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.lightSuccess,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightSuccess.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.solar_power,
                    size: 48,
                    color: AppColors.lightSuccess,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsCard() {
    if (_billDetails == null) return const SizedBox.shrink();

    final savings = _billDetails!.solarRecommendation.savings;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estimated Savings',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Text(
              '${_formatCurrency(savings.monthlyBillSavings)}/month',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.lightSuccess,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Payback period',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            LinearPercentIndicator(
              lineHeight: 8,
              percent: savings.paybackPeriod > 0
                  ? (1 / savings.paybackPeriod).clamp(0.0, 1.0)
                  : 0,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.outline.withOpacity(0.2),
              progressColor: AppColors.lightPrimary,
              barRadius: const Radius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              '${savings.paybackPeriod.round()} years',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedCTA() {
    if (!_hasFetchedData) return const SizedBox.shrink();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.lightSuccess, AppColors.lightPrimary],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to quote screen or show dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Get Free Solar Quote feature coming soon!'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Get Free Solar Quote',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solar Phoenix'), centerTitle: true),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildInputCard(),
                if (_hasFetchedData && _billDetails != null) ...[
                  _buildConsumerDetailsCard(),
                  _buildUsageChartCard(),
                  _buildSolarRecommendationCard(),
                  _buildSavingsCard(),
                  const SizedBox(height: 100), // Space for fixed CTA
                ],
              ],
            ),
          ),
          _buildFixedCTA(),
        ],
      ),
    );
  }
}
