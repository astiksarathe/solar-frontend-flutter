import 'package:flutter/material.dart';
import '../models/lead_models.dart';
import '../services/lead_service.dart';

class LeadCard extends StatelessWidget {
  final Lead lead;
  final VoidCallback? onPress;
  final Function(String)? onCall;
  final EdgeInsetsGeometry? margin;

  const LeadCard({
    super.key,
    required this.lead,
    this.onPress,
    this.onCall,
    this.margin,
  });

  void _makePhoneCall(String phoneNumber) {
    // TODO: Implement actual phone call functionality
    // For now, just call the callback
    onCall?.call(phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    radius: 24,
                    child: Text(
                      lead.name.isNotEmpty ? lead.name[0].toUpperCase() : 'L',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name and basic info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lead.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          LeadService.formatPhone(lead.phone),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                      ],
                    ),
                  ),

                  // Call button
                  IconButton(
                    onPressed: () => _makePhoneCall(lead.phone),
                    icon: Icon(
                      Icons.phone,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Additional Information
              if (lead.consumerNumber != null ||
                  lead.divisionName != null ||
                  lead.monthlyUnits != null)
                Column(
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // Consumer Number
                    if (lead.consumerNumber != null)
                      _buildInfoRow(
                        context,
                        'Consumer Number',
                        lead.consumerNumber!,
                        Icons.account_box,
                      ),

                    // Division/City
                    if (lead.divisionName != null)
                      _buildInfoRow(
                        context,
                        'Division',
                        lead.divisionName!,
                        Icons.location_on,
                      ),

                    // Monthly Units
                    if (lead.monthlyUnits != null)
                      _buildInfoRow(
                        context,
                        'Monthly Units',
                        '${lead.monthlyUnits} kWh',
                        Icons.electric_bolt,
                      ),

                    // Amount
                    if (lead.amount != null)
                      _buildInfoRow(
                        context,
                        'Amount',
                        '₹${lead.amount}',
                        Icons.currency_rupee,
                      ),

                    // Purpose
                    if (lead.purpose != null)
                      _buildInfoRow(
                        context,
                        'Purpose',
                        lead.purpose!,
                        Icons.business,
                      ),
                  ],
                ),

              // Reminder info
              if (lead.reminderAt != null)
                Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Reminder: ${_formatDate(lead.reminderAt!)}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
