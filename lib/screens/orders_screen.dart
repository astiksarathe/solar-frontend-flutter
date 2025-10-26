import 'package:flutter/material.dart';
import '../models/order_models.dart';
import '../services/order_service.dart';
import '../widgets/search_bar.dart' as custom;
import '../widgets/user_role_selector.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<SolarOrder> _orders = [];
  String _query = '';
  bool _loading = true;
  String? _error;
  OrderStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await OrderService.getAllOrders(limit: 50);

      if (result.success && result.data != null) {
        final ordersData = result.data!.data;
        setState(() {
          // Convert API response to SolarOrder objects
          _orders = ordersData.map((item) {
            return SolarOrder(
              id: item['id'] ?? '',
              orderId: item['orderNumber'] ?? '',
              customerName: item['customerName'] ?? '',
              customerPhone: item['customerPhone'] ?? '',
              customerEmail: item['customerEmail'] ?? '',
              systemCapacity: (item['systemSize'] ?? 0.0).toDouble(),
              panelBrand: item['panelBrand'] ?? 'TBD',
              inverterBrand: item['inverterBrand'] ?? 'TBD',
              status: _mapStringToOrderStatus(item['status'] ?? 'PENDING'),
              createdAt: item['createdAt'] != null
                  ? DateTime.parse(item['createdAt'])
                  : DateTime.now(),
              expectedCompletionDate: item['expectedCompletionDate'] != null
                  ? DateTime.parse(item['expectedCompletionDate'])
                  : null,
              assignedTo: item['assignedToName'],
              installationAddress: item['installationAddress']?['street'] ?? '',
              stages: [], // Will be populated from detailed API call
            );
          }).toList();
          _loading = false;
        });
      } else {
        setState(() {
          _error = result.message ?? 'Failed to load orders';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error: $e';
        _loading = false;
      });
    }
  }

  OrderStatus _mapStringToOrderStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return OrderStatus.confirmed;
      case 'IN_PROGRESS':
        return OrderStatus.panelInstallation;
      case 'COMPLETED':
        return OrderStatus.completed;
      case 'CANCELLED':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.confirmed;
    }
  }

  List<SolarOrder> get _filteredOrders {
    List<SolarOrder> filtered = _orders;

    // Filter by search query
    if (_query.isNotEmpty) {
      final lowercaseQuery = _query.toLowerCase();
      filtered = filtered.where((order) {
        return order.customerName.toLowerCase().contains(lowercaseQuery) ||
            order.orderId.toLowerCase().contains(lowercaseQuery) ||
            order.customerPhone.contains(_query) ||
            order.customerEmail.toLowerCase().contains(lowercaseQuery);
      }).toList();
    }

    // Filter by status
    if (_selectedStatus != null) {
      filtered = filtered
          .where((order) => order.status == _selectedStatus)
          .toList();
    }

    return filtered;
  }

  Color _getStatusColor(OrderStatus status, ColorScheme colorScheme) {
    switch (status) {
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.documentsReceived:
        return Colors.orange;
      case OrderStatus.underLoan:
        return Colors.purple;
      case OrderStatus.structureInstallation:
        return Colors.amber;
      case OrderStatus.panelInstallation:
        return Colors.indigo;
      case OrderStatus.netMeteringCompleted:
        return Colors.green;
      case OrderStatus.completed:
        return colorScheme.primary;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.documentsReceived:
        return Icons.description;
      case OrderStatus.underLoan:
        return Icons.account_balance;
      case OrderStatus.structureInstallation:
        return Icons.construction;
      case OrderStatus.panelInstallation:
        return Icons.solar_power;
      case OrderStatus.netMeteringCompleted:
        return Icons.electrical_services;
      case OrderStatus.completed:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  void _onOrderTap(SolarOrder order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderDetailScreen(orderId: order.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filteredOrders = _filteredOrders;

    return Scaffold(
      body: Column(
        children: [
          // Header section with title and actions
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Solar Orders',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (context) => const UserRoleSelector(),
                          ),
                        )
                        .then((_) => _loadOrders()); // Refresh when returning
                  },
                  tooltip: 'Change Role',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadOrders,
                ),
              ],
            ),
          ),
          // Search and Filter
          Container(
            padding: const EdgeInsets.all(16),
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
                  placeholder: 'Search orders, customers...',
                ),

                const SizedBox(height: 12),

                // Status Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusChip('All', null, colorScheme),
                      const SizedBox(width: 8),
                      ...OrderStatus.values.map(
                        (status) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildStatusChip(
                            status.name.replaceAll('_', ' ').toUpperCase(),
                            status,
                            colorScheme,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? _buildErrorState(theme)
                : filteredOrders.isEmpty
                ? _buildEmptyState(theme)
                : _buildOrdersList(filteredOrders, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(
    String label,
    OrderStatus? status,
    ColorScheme colorScheme,
  ) {
    final isSelected = _selectedStatus == status;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = selected ? status : null;
        });
      },
      selectedColor: colorScheme.primary.withOpacity(0.2),
      checkmarkColor: colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadOrders,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            _query.isNotEmpty ? 'No orders found' : 'No orders yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _query.isNotEmpty
                ? 'Try adjusting your search or filters'
                : 'Orders will appear here once confirmed',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<SolarOrder> orders, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order, theme);
      },
    );
  }

  Widget _buildOrderCard(SolarOrder order, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final statusColor = _getStatusColor(order.status, colorScheme);
    final statusIcon = _getStatusIcon(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _onOrderTap(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 20),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.orderId,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          order.customerName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.statusDisplayName,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // System Details
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Capacity',
                      '${order.systemCapacity}kW',
                      Icons.electrical_services,
                      theme,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Progress',
                      '${order.progressPercentage.toInt()}%',
                      Icons.trending_up,
                      theme,
                    ),
                  ),
                  // Always show total cost for now (can be controlled by user role later)
                  if (order.costBreakdown != null)
                    Expanded(
                      child: _buildInfoItem(
                        'Total Cost',
                        '₹${(order.costBreakdown!.totalCost / 100000).toStringAsFixed(1)}L',
                        Icons.currency_rupee,
                        theme,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress: ${order.completedStages}/${order.stages.length} stages',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        '${order.progressPercentage.toInt()}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: order.progressPercentage / 100,
                    backgroundColor: colorScheme.outline.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Expected Completion
              if (order.expectedCompletionDate != null)
                Text(
                  'Expected completion: ${order.expectedCompletionDate!.day}/${order.expectedCompletionDate!.month}/${order.expectedCompletionDate!.year}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
