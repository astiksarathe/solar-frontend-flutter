import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/filter_models.dart';
import '../services/consumer_data_service.dart';
import '../widgets/search_bar.dart' as custom;
import '../widgets/sort_filter_modal.dart';
import 'consumer_detail_screen.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  List<Map<String, dynamic>> _consumerData = [];
  String _query = '';
  bool _modalOpen = false;
  DirectorySort _sort = DirectorySort.none;
  DirectoryFilter _filter = DirectoryFilter();
  bool _loading = true;
  String? _error;

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
      final response = await ConsumerDataService.getAllConsumerData(
        limit: 50,
        sortBy: 'avgUnits',
        sortOrder: 'desc',
      );

      if (response.success && response.data != null) {
        setState(() {
          _consumerData = response.data!.data;
          _loading = false;
        });
      } else {
        // Handle API connection issues with demo data
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
      // Handle network errors gracefully
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
      _consumerData = [
        {
          "_id": "68fa1b84bc8d79fe620fdd65",
          "name": "Rahul Sharma",
          "consumerNumber": "N2183020005",
          "address": "123 MG Road, Pune",
          "divisionName": "Pune Division",
          "mobileNumber": "9988776655",
          "purpose": "Domestic",
          "amount": [
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
          "last6MonthsUnits": [
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
          "avgUnits": 110,
          "avgMonthlyBill": 1341.67,
          "propertyType": "residential",
          "status": "new",
          "isHighConsumer": false,
          "qualificationScore": 15,
          "estimatedSolarCapacity": 0.7,
          "createdAt": "2025-10-23T12:11:48.217Z",
          "updatedAt": "2025-10-23T12:11:48.217Z",
        },
        {
          "_id": "68fa1b84bc8d79fe620fdd66",
          "name": "Priya Patel",
          "consumerNumber": "N2183020006",
          "address": "45 Baner Road, Pune",
          "divisionName": "Pune Division",
          "mobileNumber": "9876543210",
          "purpose": "Commercial",
          "amount": [
            2500,
            2400,
            2600,
            2550,
            2700,
            2800,
            2900,
            2850,
            2750,
            2650,
            2550,
            2450,
          ],
          "last6MonthsUnits": [
            250,
            240,
            260,
            255,
            270,
            275,
            280,
            278,
            272,
            265,
            258,
            250,
          ],
          "avgUnits": 263,
          "avgMonthlyBill": 2654.17,
          "propertyType": "commercial",
          "status": "qualified",
          "isHighConsumer": true,
          "qualificationScore": 22,
          "estimatedSolarCapacity": 1.5,
          "createdAt": "2025-10-23T12:11:48.217Z",
          "updatedAt": "2025-10-23T12:11:48.217Z",
        },
        {
          "_id": "68fa1b84bc8d79fe620fdd67",
          "name": "Amit Singh",
          "consumerNumber": "N2183020007",
          "address": "78 FC Road, Pune",
          "divisionName": "Pune Division",
          "mobileNumber": "9876512345",
          "purpose": "Domestic",
          "amount": [
            800,
            750,
            900,
            850,
            950,
            1000,
            1100,
            1050,
            950,
            850,
            750,
            700,
          ],
          "last6MonthsUnits": [
            80,
            75,
            90,
            85,
            95,
            100,
            110,
            105,
            95,
            85,
            75,
            70,
          ],
          "avgUnits": 87,
          "avgMonthlyBill": 887.5,
          "propertyType": "residential",
          "status": "contacted",
          "isHighConsumer": false,
          "qualificationScore": 12,
          "estimatedSolarCapacity": 0.5,
          "createdAt": "2025-10-23T12:11:48.217Z",
          "updatedAt": "2025-10-23T12:11:48.217Z",
        },
      ];
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

  List<Map<String, dynamic>> get _filteredConsumerData {
    final q = _query.trim().toLowerCase();
    List<Map<String, dynamic>> filtered = _consumerData.where((consumer) {
      // Search filter - expanded to include more fields
      if (q.isNotEmpty &&
          !((consumer['name']?.toString().toLowerCase().contains(q) ?? false) ||
              (consumer['mobileNumber']?.toString().contains(q) ?? false) ||
              (consumer['consumerNumber']?.toString().contains(q) ?? false) ||
              (consumer['address']?.toString().toLowerCase().contains(q) ??
                  false) ||
              (consumer['divisionName']?.toString().toLowerCase().contains(q) ??
                  false))) {
        return false;
      }

      // Has reminder filter
      if (_filter.hasReminder == true && consumer['reminderAt'] == null) {
        return false;
      }

      // Monthly units range filter (using avgUnits from new structure)
      if (_filter.minUnits != null) {
        final minUnits = double.tryParse(_filter.minUnits!) ?? 0;
        final consumerUnits =
            double.tryParse(consumer['avgUnits']?.toString() ?? '0') ?? 0;
        if (consumerUnits < minUnits) return false;
      }

      if (_filter.maxUnits != null) {
        final maxUnits = double.tryParse(_filter.maxUnits!) ?? double.infinity;
        final consumerUnits =
            double.tryParse(consumer['avgUnits']?.toString() ?? '0') ?? 0;
        if (consumerUnits > maxUnits) return false;
      }

      // Purpose filter
      if (_filter.purpose != null && _filter.purpose!.isNotEmpty) {
        final purposeFilter = _filter.purpose!.toLowerCase();
        if (!(consumer['purpose']?.toString().toLowerCase().contains(
              purposeFilter,
            ) ??
            false)) {
          return false;
        }
      }

      // Reminder type filter
      if (_filter.reminderType != null && _filter.reminderType != 'any') {
        if (consumer['reminderType'] == null ||
            consumer['reminderType'] != _filter.reminderType) {
          return false;
        }
      }

      // Date range filters
      if (_filter.startDate != null && consumer['reminderAt'] != null) {
        try {
          final reminderDate = DateTime.parse(
            consumer['reminderAt'].toString(),
          );
          if (reminderDate.isBefore(_filter.startDate!)) return false;
        } catch (e) {
          // Invalid date format, skip this filter
        }
      }

      if (_filter.endDate != null && consumer['reminderAt'] != null) {
        try {
          final reminderDate = DateTime.parse(
            consumer['reminderAt'].toString(),
          );
          if (reminderDate.isAfter(_filter.endDate!)) return false;
        } catch (e) {
          // Invalid date format, skip this filter
        }
      }

      return true;
    }).toList();

    // Apply sorting
    switch (_sort) {
      case DirectorySort.units:
        filtered.sort((a, b) {
          final aUnits = double.tryParse(b['avgUnits']?.toString() ?? '0') ?? 0;
          final bUnits = double.tryParse(a['avgUnits']?.toString() ?? '0') ?? 0;
          return aUnits.compareTo(bUnits);
        });
        break;
      case DirectorySort.amount:
        filtered.sort((a, b) {
          final aAmount = (b['avgMonthlyBill'] as num?)?.toDouble() ?? 0;
          final bAmount = (a['avgMonthlyBill'] as num?)?.toDouble() ?? 0;
          return aAmount.compareTo(bAmount);
        });
        break;
      case DirectorySort.consumerNumber:
        filtered.sort((a, b) {
          return (a['consumerNumber']?.toString() ?? '').compareTo(
            b['consumerNumber']?.toString() ?? '',
          );
        });
        break;
      case DirectorySort.name:
        filtered.sort(
          (a, b) => (a['name']?.toString() ?? '').compareTo(
            b['name']?.toString() ?? '',
          ),
        );
        break;
      case DirectorySort.reminder:
        filtered.sort((a, b) {
          final aHasReminder = a['reminderAt'] != null ? 1 : 0;
          final bHasReminder = b['reminderAt'] != null ? 1 : 0;
          return bHasReminder.compareTo(aHasReminder);
        });
        break;
      case DirectorySort.none:
        // No sorting
        break;
    }

    return filtered;
  }

  void _onConsumerPress(Map<String, dynamic> consumer) {
    final consumerId = consumer['_id']?.toString();

    if (consumerId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConsumerDetailScreen(consumerId: consumerId),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Consumer ID not found')));
    }
  }

  void _onCall(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot make call to $phone'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error making call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredConsumerData = _filteredConsumerData;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Search Bar
                custom.SearchBar(
                  value: _query,
                  onChanged: (value) {
                    setState(() {
                      _query = value;
                    });
                  },
                  placeholder: 'Search name, mobile, address, or division',
                ),

                // Content
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? _buildErrorState()
                      : filteredConsumerData.isEmpty
                      ? _buildEmptyState()
                      : _buildConsumerList(filteredConsumerData),
                ),
              ],
            ),
          ),

          // Filter FAB
          Positioned(
            right: 18,
            bottom: 26,
            child: FloatingActionButton.extended(
              heroTag: "directory_filter_fab",
              onPressed: () {
                setState(() {
                  _modalOpen = true;
                });
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              icon: const Icon(Icons.filter_list),
              label: const Text(
                'Filter',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),

          // Sort/Filter Modal
          SortFilterModal(
            visible: _modalOpen,
            onClose: () {
              setState(() {
                _modalOpen = false;
              });
            },
            onApply: (sort, filter) {
              setState(() {
                _sort = sort;
                _filter = filter;
              });
            },
            initialSort: _sort,
            initialFilter: _filter,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Error Loading Directory',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Something went wrong',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadConsumerData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            _query.isNotEmpty ? 'No consumers found' : 'No consumers available',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _query.isNotEmpty
                ? 'Try adjusting your search or filters'
                : 'Add some consumer data to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsumerList(List<Map<String, dynamic>> consumers) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 120),
      itemCount: consumers.length,
      itemBuilder: (context, index) {
        final consumer = consumers[index];
        return _buildConsumerCard(consumer);
      },
    );
  }

  Widget _buildConsumerCard(Map<String, dynamic> consumer) {
    final name = consumer['name']?.toString() ?? 'Unknown';
    final mobileNumber = consumer['mobileNumber']?.toString() ?? '';
    final consumerNumber = consumer['consumerNumber']?.toString() ?? '';
    final address = consumer['address']?.toString() ?? '';
    final divisionName = consumer['divisionName']?.toString() ?? '';
    final purpose = consumer['purpose']?.toString() ?? '';
    final status = consumer['status']?.toString() ?? '';
    final propertyType = consumer['propertyType']?.toString() ?? '';
    final isHighConsumer = consumer['isHighConsumer'] == true;
    final qualificationScore =
        consumer['qualificationScore']?.toString() ?? '0';
    final estimatedSolarCapacity =
        consumer['estimatedSolarCapacity']?.toString() ?? '0';

    // Calculate average units and bill from arrays
    final avgUnits = consumer['avgUnits']?.toString() ?? '0';
    final avgMonthlyBill = consumer['avgMonthlyBill'];
    final avgBillFormatted = avgMonthlyBill != null
        ? '₹${avgMonthlyBill.round()}'
        : '₹0';

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      elevation: isHighConsumer ? 4 : 1,
      child: InkWell(
        onTap: () => _onConsumerPress(consumer),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isHighConsumer
                ? Border.all(color: Colors.orange, width: 1.5)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row with name and call button
                Row(
                  children: [
                    // Avatar with first letter
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      radius: 20,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              if (isHighConsumer) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'HIGH',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (consumerNumber.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Consumer No: $consumerNumber',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                            ),
                          ],
                          if (divisionName.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              divisionName,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (mobileNumber.isNotEmpty)
                      IconButton(
                        onPressed: () => _onCall(mobileNumber),
                        icon: const Icon(Icons.phone),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                        ),
                      ),
                  ],
                ),

                // Address section
                if (address.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          address,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),

                // Metrics Row
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoChip(
                        '$avgUnits kWh',
                        'Avg Units',
                        Icons.electric_bolt,
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoChip(
                        avgBillFormatted,
                        'Avg Bill',
                        Icons.currency_rupee,
                        Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoChip(
                        '${estimatedSolarCapacity}kW',
                        'Solar Est.',
                        Icons.solar_power,
                        Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Status and Property Type chips
                Row(
                  children: [
                    if (status.isNotEmpty) ...[
                      Chip(
                        label: Text(status.toUpperCase()),
                        backgroundColor: _getStatusColor(status),
                        labelStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (propertyType.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(propertyType.toUpperCase()),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (purpose.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(purpose.toUpperCase()),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.tertiary.withOpacity(0.1),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ],
                    const Spacer(),
                    // Qualification Score
                    if (qualificationScore != '0') ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getScoreColor(
                            int.tryParse(qualificationScore) ?? 0,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 12, color: Colors.white),
                            const SizedBox(width: 2),
                            Text(
                              qualificationScore,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontSize: 13,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: color.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return Colors.blue.withOpacity(0.1);
      case 'contacted':
        return Colors.orange.withOpacity(0.1);
      case 'qualified':
        return Colors.green.withOpacity(0.1);
      case 'proposal':
        return Colors.purple.withOpacity(0.1);
      case 'closed':
        return Colors.green.withOpacity(0.2);
      case 'lost':
        return Colors.red.withOpacity(0.1);
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 20) {
      return Colors.green; // High qualification score
    } else if (score >= 15) {
      return Colors.orange; // Medium qualification score
    } else if (score >= 10) {
      return Colors.blue; // Low qualification score
    } else {
      return Colors.grey; // Very low qualification score
    }
  }
}
