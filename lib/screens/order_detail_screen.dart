import 'package:flutter/material.dart';
import '../models/order_models.dart';
import '../services/order_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  SolarOrder? _order;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await OrderService.getOrderById(widget.orderId);

      if (response.success && response.data != null) {
        // Convert API response to SolarOrder model
        final orderData = response.data!['order'];
        final order = SolarOrder.fromJson(orderData);

        setState(() {
          _order = order;
          _loading = false;
        });
      } else {
        setState(() {
          _error = response.message ?? 'Failed to load order details';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading order: $e';
        _loading = false;
      });
    }
  }

  Color _getStatusColor(OrderStatus status) {
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
        return Colors.teal;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Error Loading Order',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadOrder,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_order == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: colorScheme.outline),
              const SizedBox(height: 16),
              Text(
                'Order not found',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final statusColor = _getStatusColor(_order!.status);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with title and refresh
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _order!.orderId,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadOrder,
                  ),
                ],
              ),
            ),
            // Header Card
            _buildHeaderCard(statusColor, theme),

            const SizedBox(height: 16),

            // Customer Details Card
            _buildCustomerCard(theme),

            const SizedBox(height: 16),

            // System Details Card
            _buildSystemCard(theme),

            const SizedBox(height: 16),

            // Progress Tracking Card
            _buildProgressCard(theme),

            const SizedBox(height: 16),

            // Cost Breakdown Card
            if (_order!.costBreakdown != null) _buildCostCard(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Color statusColor, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.solar_power, color: statusColor, size: 24),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _order!.orderId,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _order!.statusDisplayName,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Progress Overview
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_order!.completedStages}/${_order!.stages.length} stages completed',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${_order!.progressPercentage.toInt()}%',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            LinearProgressIndicator(
              value: _order!.progressPercentage / 100,
              backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            _buildDetailRow('Name', _order!.customerName, Icons.person, theme),
            _buildDetailRow('Phone', _order!.customerPhone, Icons.phone, theme),
            _buildDetailRow('Email', _order!.customerEmail, Icons.email, theme),
            _buildDetailRow(
              'Address',
              _order!.installationAddress,
              Icons.location_on,
              theme,
            ),

            if (_order!.assignedTo != null)
              _buildDetailRow(
                'Assigned To',
                _order!.assignedTo!,
                Icons.assignment_ind,
                theme,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Specifications',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            _buildDetailRow(
              'Capacity',
              '${_order!.systemCapacity}kW',
              Icons.electrical_services,
              theme,
            ),
            _buildDetailRow(
              'Panel Brand',
              _order!.panelBrand,
              Icons.solar_power,
              theme,
            ),
            _buildDetailRow(
              'Inverter Brand',
              _order!.inverterBrand,
              Icons.power,
              theme,
            ),

            if (_order!.expectedCompletionDate != null)
              _buildDetailRow(
                'Expected Completion',
                '${_order!.expectedCompletionDate!.day}/${_order!.expectedCompletionDate!.month}/${_order!.expectedCompletionDate!.year}',
                Icons.schedule,
                theme,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Installation Progress',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            ..._order!.stages.map((stage) => _buildStageItem(stage, theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildStageItem(OrderStage stage, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final isCompleted = stage.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green.withOpacity(0.1)
                  : colorScheme.outline.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isCompleted ? Colors.green : colorScheme.outline,
            ),
          ),

          const SizedBox(width: 12),

          // Stage Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        stage.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isCompleted
                              ? colorScheme.onSurface
                              : colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),

                    // Toggle button temporarily disabled until permission system is implemented
                  ],
                ),

                Text(
                  stage.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),

                if (stage.completedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Completed on ${stage.completedAt!.day}/${stage.completedAt!.month}/${stage.completedAt!.year}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                if (stage.completedBy != null) ...[
                  Text(
                    'by ${stage.completedBy}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],

                if (stage.notes != null && stage.notes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(
                        0.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      stage.notes!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostCard(ThemeData theme) {
    final cost = _order!.costBreakdown!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lock, color: theme.colorScheme.primary, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Cost Breakdown (Authorized Access)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildCostRow('Solar Panels', cost.panelCost, theme),
            _buildCostRow('Inverter', cost.inverterCost, theme),
            _buildCostRow('Structure', cost.structureCost, theme),
            _buildCostRow('Installation', cost.installationCost, theme),
            _buildCostRow('Net Metering', cost.netMeteringCost, theme),
            _buildCostRow('Miscellaneous', cost.miscellaneousCost, theme),

            const Divider(),

            _buildCostRow('Subtotal', cost.subtotal, theme, isBold: true),

            if (cost.discount > 0)
              _buildCostRow(
                'Discount',
                -cost.discount,
                theme,
                isDiscount: true,
              ),

            _buildCostRow('Tax (GST)', cost.taxAmount, theme),

            const Divider(),

            _buildCostRow(
              'Total Amount',
              cost.totalCost,
              theme,
              isBold: true,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
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

  Widget _buildCostRow(
    String label,
    double amount,
    ThemeData theme, {
    bool isBold = false,
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
              color: isTotal ? colorScheme.primary : null,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: isDiscount
                  ? Colors.green
                  : isTotal
                  ? colorScheme.primary
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
