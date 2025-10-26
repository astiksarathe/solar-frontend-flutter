import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/consumer_data_service.dart';

class ConsumerDetailScreen extends StatefulWidget {
  final String consumerId;

  const ConsumerDetailScreen({super.key, required this.consumerId});

  @override
  State<ConsumerDetailScreen> createState() => _ConsumerDetailScreenState();
}

class _ConsumerDetailScreenState extends State<ConsumerDetailScreen> {
  Map<String, dynamic>? _consumer;
  bool _loading = true;
  String? _error;
  bool _isChartView = true; // Toggle between chart and grid view

  @override
  void initState() {
    super.initState();
    _loadConsumerData();
  }

  Future<void> _loadConsumerData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await ConsumerDataService.getConsumerDataById(
        widget.consumerId,
      );

      if (response.success && response.data != null) {
        setState(() {
          _consumer = response.data!;
          _loading = false;
        });
      } else {
        // If API fails, try to provide demo data based on the consumer ID
        if (response.message?.contains('Connection refused') == true ||
            response.message?.contains('SocketException') == true ||
            response.message?.contains('No internet connection') == true) {
          _loadDemoData();
        } else {
          setState(() {
            _error = response.message ?? 'Failed to load consumer data';
            _loading = false;
          });
        }
      }
    } catch (e) {
      // Handle network errors gracefully with demo data
      if (e.toString().contains('Connection refused') ||
          e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        _loadDemoData();
      } else {
        setState(() {
          _error = 'Error loading consumer data: $e';
          _loading = false;
        });
      }
    }
  }

  void _loadDemoData() {
    // Provide demo data when API is unavailable
    setState(() {
      _consumer = {
        '_id': widget.consumerId,
        'name': 'Demo Consumer',
        'consumerNumber': 'N2183020005',
        'address': '123 MG Road, Pune',
        'divisionName': 'Pune Division',
        'mobileNumber': '9988776655',
        'purpose': 'Domestic',
        'amount': [
          1200,
          1100,
          1300,
          1250,
          1400,
          1500,
          1600,
          1550,
          1450,
          1350,
          1250,
          1150,
        ],
        'last6MonthsUnits': [
          100,
          95,
          110,
          105,
          120,
          125,
          130,
          128,
          122,
          115,
          108,
          100,
        ],
        'avgUnits': 110,
        'avgMonthlyBill': 1341.67,
        'propertyType': 'residential',
        'status': 'new',
        'isHighConsumer': false,
        'qualificationScore': 15,
        'estimatedSolarCapacity': 0.7,
        'createdAt': '2025-10-23T12:11:48.217Z',
        'updatedAt': '2025-10-23T12:11:48.217Z',
      };
      _loading = false;
    });

    // Show info about demo mode
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Using demo data - API server not available'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showActionSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildActionSheet(),
    );
  }

  Widget _buildActionSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Quick Actions',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildActionTile(
            icon: Icons.phone,
            title: 'Call Customer',
            subtitle: 'Make a phone call',
            onTap: () {
              Navigator.pop(context);
              _makePhoneCall();
            },
          ),
          _buildActionTile(
            icon: Icons.note_add,
            title: 'Add Note',
            subtitle: 'Record interaction',
            onTap: () {
              Navigator.pop(context);
              _showAddNoteDialog();
            },
          ),
          _buildActionTile(
            icon: Icons.schedule,
            title: 'Schedule Follow-up',
            subtitle: 'Set reminder',
            onTap: () {
              Navigator.pop(context);
              _showScheduleDialog();
            },
          ),
          _buildActionTile(
            icon: Icons.solar_power,
            title: 'Create Proposal',
            subtitle: 'Generate solar proposal',
            onTap: () {
              Navigator.pop(context);
              _createProposal();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  void _makePhoneCall() async {
    final mobileNumber = _consumer?['mobileNumber']?.toString() ?? '';
    if (mobileNumber.isEmpty) {
      _showAlert('Error', 'No phone number available');
      return;
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: mobileNumber);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showAlert('Error', 'Cannot make call to $mobileNumber');
      }
    } catch (e) {
      _showAlert('Error', 'Error making call: $e');
    }
  }

  void _showAddNoteDialog() {
    final TextEditingController noteController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            hintText: 'Enter your note here...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addNote(noteController.text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showScheduleDialog() {
    _showAlert('Schedule Follow-up', 'Schedule follow-up feature coming soon!');
  }

  void _createProposal() {
    _showAlert('Create Proposal', 'Solar proposal generation coming soon!');
  }

  void _addNote(String note) {
    if (note.trim().isEmpty) return;
    _showAlert('Note Added', 'Note recorded successfully');
  }

  void _showAlert(String title, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$title: $message')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(_consumer?['name'] ?? 'Consumer Details'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3748),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorState()
          : _consumer == null
          ? _buildNotFoundState()
          : _buildModernConsumerDetails(),
      floatingActionButton: _consumer != null
          ? FloatingActionButton(
              onPressed: _showActionSheet,
              backgroundColor: const Color(0xFF667EEA),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildModernConsumerDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Compact Header Card
          _buildCompactHeader(),
          const SizedBox(height: 16),

          // Solar Recommendation Card
          _buildSolarRecommendationCard(),
          const SizedBox(height: 16),

          // Quick Stats - 3 Column Summary
          _buildQuickStatsCard(),
          const SizedBox(height: 16),

          // Consumption Chart Card
          _buildConsumptionChartCard(),
          const SizedBox(height: 16),

          // Recent Activity Card
          _buildRecentActivityCard(),
          const SizedBox(height: 16),

          // Reminders Card
          _buildRemindersCard(),
          const SizedBox(height: 80), // Extra space for FAB
        ],
      ),
    );
  }

  Widget _buildCompactHeader() {
    final name = _consumer?['name']?.toString() ?? 'Unknown';
    final consumerNumber = _consumer?['consumerNumber']?.toString() ?? '';
    final mobileNumber = _consumer?['mobileNumber']?.toString() ?? '';
    final address = _consumer?['address']?.toString() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar and basic info
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    if (consumerNumber.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        consumerNumber,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Contact button
              if (mobileNumber.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF48BB78), Color(0xFF38A169)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _makePhoneCall,
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.phone, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Address and contact info
          if (address.isNotEmpty || mobileNumber.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  if (address.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Color(0xFF667EEA),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            address,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4A5568),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (address.isNotEmpty && mobileNumber.isNotEmpty)
                    const SizedBox(height: 4),
                  if (mobileNumber.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          size: 14,
                          color: Color(0xFF667EEA),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          mobileNumber,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4A5568),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSolarRecommendationCard() {
    final estimatedCapacity =
        _consumer?['estimatedSolarCapacity']?.toString() ?? '0.7';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF48BB78), Color(0xFF38A169)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'Recommended Solar System',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${estimatedCapacity}kW',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Based on your consumption pattern',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsCard() {
    final avgBill = _consumer?['avgMonthlyBill']?.round() ?? 3500;
    final avgUnits = _consumer?['avgUnits']?.round() ?? 420;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Average Bill
          Expanded(
            child: Column(
              children: [
                Text(
                  '₹$avgBill',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Average Bill',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(width: 1, height: 40, color: Colors.grey[300]),

          // Average Units
          Expanded(
            child: Column(
              children: [
                Text(
                  '$avgUnits',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Average Units',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final isNetworkError =
        _error?.contains('Connection refused') == true ||
        _error?.contains('SocketException') == true ||
        _error?.contains('No internet connection') == true;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isNetworkError ? Icons.wifi_off : Icons.error_outline,
            size: 80,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            isNetworkError ? 'Connection Error' : 'Error Loading Consumer',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isNetworkError
                ? 'Unable to connect to server. Please check if the backend server is running.'
                : _error ?? 'Something went wrong',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          if (isNetworkError) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 24),
                  const SizedBox(height: 8),
                  Text(
                    'To connect to your backend server:\n\n1. Make sure your Node.js server is running\n2. Check the API URL in api_config.dart\n3. For Android emulator, use 10.0.2.2:3000',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _loadConsumerData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
              if (isNetworkError) ...[
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: _loadDemoData,
                  icon: const Icon(Icons.preview),
                  label: const Text('Demo Mode'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Consumer Not Found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The consumer you are looking for does not exist',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConsumptionChartCard() {
    final amountArray = _consumer?['amount'] as List?;
    final unitsArray = _consumer?['last6MonthsUnits'] as List?;

    if (amountArray == null) {
      return const SizedBox.shrink();
    }

    final amounts = amountArray.take(12).map((e) => e as num).toList();
    final units =
        unitsArray?.take(12).map((e) => e as num).toList() ??
        [
          450,
          420,
          480,
          520,
          490,
          380,
          360,
          340,
          320,
          310,
          350,
          380,
        ]; // Fallback data
    final maxAmount = amounts.reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with toggle button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📊 Consumption Analytics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3748),
                ),
              ),
              // Toggle Button
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggleButton(
                      icon: Icons.bar_chart,
                      isSelected: _isChartView,
                      onTap: () => setState(() => _isChartView = true),
                    ),
                    _buildToggleButton(
                      icon: Icons.grid_view,
                      isSelected: !_isChartView,
                      onTap: () => setState(() => _isChartView = false),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Conditional View based on toggle
          _isChartView
              ? _buildChartView(amounts, maxAmount)
              : _buildGridView(amounts, units),

          const SizedBox(height: 16),

          // Summary Stats - 2x2 Layout (always shown)
          Column(
            children: [
              // First Row: Total Yearly + Total kWh
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            '₹45,600',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Total Yearly',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            '4,900 kWh',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Total kWh',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Second Row: Highest Bill + Lowest Bill
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            '₹4,800',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Highest Bill',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            '₹2,100',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Lowest Bill',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? const Color(0xFF667EEA) : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.white : const Color(0xFF718096),
          ),
        ),
      ),
    );
  }

  Widget _buildChartView(List<num> amounts, double maxAmount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Bills (₹) - Scroll to view all',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(amounts.length, (index) {
                final amount = amounts[index];
                final height = (amount / maxAmount) * 70 + 15;

                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Bar value
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 3,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF667EEA),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          '₹${(amount / 1000).toStringAsFixed(1)}k',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Bar
                      Container(
                        width: 24,
                        height: height,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Month label
                      Text(
                        _getShortMonthName(index),
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF718096),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridView(List<num> amounts, List<num> units) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '12 Month Summary',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.2,
            ),
            itemCount: amounts.length,
            itemBuilder: (context, index) {
              final amount = amounts[index];
              final unit = units[index];
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getShortMonthName(index),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF718096),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$unit kWh',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF4A5568),
                      ),
                    ),
                    Text(
                      '₹${amount.round()}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF667EEA),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A202C),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 2,
                width: 60,
                decoration: BoxDecoration(
                  color: Color(0xFF667EEA),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Activity Items
          _buildActivityItem(
            icon: '✅',
            title: 'Follow-up Call Completed',
            date: 'Oct 25, 2025 - 2:30 PM',
            description:
                'Discussed solar benefits and scheduled site survey for next week. Customer expressed strong interest in 5kW system.',
            status: 'Completed',
            statusColor: const Color(0xFFD4EDDA),
            statusTextColor: const Color(0xFF155724),
            priority: 'High Priority',
          ),

          // Divider line
          Container(
            height: 1,
            color: Colors.grey[200],
            margin: const EdgeInsets.symmetric(vertical: 16),
          ),

          _buildActivityItem(
            icon: '📧',
            title: 'Email Sent - Solar Proposal',
            date: 'Oct 23, 2025 - 10:15 AM',
            description:
                'Sent detailed solar proposal with 25-year warranty and financing options. Included company brochure and customer testimonials.',
            status: 'Sent',
            statusColor: const Color(0xFFD4EDDA),
            statusTextColor: const Color(0xFF155724),
            priority: 'Medium Priority',
          ),

          // Divider line
          Container(
            height: 1,
            color: Colors.grey[200],
            margin: const EdgeInsets.symmetric(vertical: 16),
          ),

          _buildActivityItem(
            icon: '🏠',
            title: 'Site Survey Scheduled',
            date: 'Oct 22, 2025 - 4:45 PM',
            description:
                'Customer requested site assessment after initial consultation. Engineer visit planned for next week to evaluate roof conditions.',
            status: 'Scheduled',
            statusColor: const Color(0xFFD1ECF1),
            statusTextColor: const Color(0xFF0C5460),
            priority: 'High Priority',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required String icon,
    required String title,
    required String date,
    required String description,
    required String status,
    required Color statusColor,
    required Color statusTextColor,
    required String priority,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A202C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF667EEA),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4A5568),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),

                // Status and Priority
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusTextColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      priority,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF667EEA),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reminders & Tasks',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A202C),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 2,
                width: 60,
                decoration: BoxDecoration(
                  color: Color(0xFFED8936),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildReminderItem(
            title: '📞 Follow-up Call Scheduled',
            description:
                'Schedule a call to discuss solar installation details and answer customer questions.',
          ),

          // Divider line
          Container(
            height: 1,
            color: Colors.grey[200],
            margin: const EdgeInsets.symmetric(vertical: 16),
          ),

          _buildReminderItem(
            title: '📋 Site Survey Preparation',
            description:
                'Prepare technical assessment checklist and coordinate with engineering team for roof evaluation.',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildReminderItem({
    required String title,
    required String description,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4A5568),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _getShortMonthName(int index) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final currentMonth = DateTime.now().month;
    final monthIndex = (currentMonth - index - 1) % 12;
    return months[monthIndex < 0 ? monthIndex + 12 : monthIndex];
  }
}
