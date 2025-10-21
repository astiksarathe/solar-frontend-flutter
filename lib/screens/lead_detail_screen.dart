import 'package:flutter/material.dart';
import '../models/lead_models.dart';
import '../services/lead_service.dart';

class LeadDetailScreen extends StatefulWidget {
  final String leadId;

  const LeadDetailScreen({super.key, required this.leadId});

  @override
  State<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends State<LeadDetailScreen> {
  Lead? _lead;
  bool _actionsOpen = false;
  bool _loading = true;

  // Sample history data (in a real app, this would come from API)
  late List<HistoryItem> _history;

  @override
  void initState() {
    super.initState();
    _loadLead();
    _initializeHistory();
  }

  void _initializeHistory() {
    final now = DateTime.now();
    _history = [
      HistoryItem(
        id: 'h1',
        type: 'Call',
        note: 'Left voicemail',
        at: now.subtract(const Duration(days: 1)),
        done: true,
        actor: 'Adarsh',
      ),
      HistoryItem(
        id: 'h2',
        type: 'Meeting',
        note: 'Site visit scheduled',
        at: now.subtract(const Duration(days: 3)),
        done: false,
        actor: 'Priya',
      ),
      HistoryItem(
        id: 'h3',
        type: 'Note',
        note: 'Interested in 5kW system',
        at: now.subtract(const Duration(days: 10)),
        done: false,
      ),
    ];
  }

  Future<void> _loadLead() async {
    setState(() {
      _loading = true;
    });

    try {
      final leads = LeadService.getLeads();
      final foundLead = leads.firstWhere(
        (lead) => lead.id == widget.leadId,
        orElse: () => Lead(
          id: widget.leadId,
          name: 'Sample Lead',
          phone: '9876543210',
          divisionName: 'Mumbai Division',
          monthlyUnits: '150',
          amount: '15000',
          purpose: 'Residential',
          avgUnits: '145',
          reminderAt: DateTime.now().add(const Duration(days: 3)),
          reminderType: 'callback',
          reminderNote: 'Follow up on system sizing requirements',
        ),
      );

      setState(() {
        _lead = foundLead;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  Color _badgeColorForType(String? type, ColorScheme colorScheme) {
    if (type == null) return colorScheme.surfaceContainerHighest;
    switch (type.toLowerCase()) {
      case 'callback':
        return colorScheme.primary.withOpacity(0.1);
      case 'meeting':
        return colorScheme.secondary.withOpacity(0.1);
      case 'site_visit':
      case 'site visit':
        return Colors.green.withOpacity(0.1);
      default:
        return colorScheme.surfaceContainerHighest;
    }
  }

  Future<void> _onAction(String type) async {
    setState(() {
      _actionsOpen = false;
    });

    switch (type) {
      case 'call':
        if (_lead?.phone != null) {
          _showAlert('Call', 'Calling ${_lead!.phone}...');
        } else {
          _showAlert('Call', 'Phone number not available');
        }
        break;
      case 'meeting':
        _showAlert('Schedule', 'Open schedule meeting flow (demo)');
        break;
      case 'note':
        _showAlert('Note', 'Add quick note (demo)');
        break;
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String name, ColorScheme colorScheme) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: colorScheme.primaryContainer,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required Widget child,
    Widget? action,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (action != null) action,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildKeyValue(String label, String value) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(HistoryItem item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: colorScheme.surfaceContainerHighest,
            ),
            child: Center(
              child: Text(
                item.type.isNotEmpty ? item.type[0].toUpperCase() : '?',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.type,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.note,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                if (item.done && item.actor != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Done by ${item.actor}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${item.at.day}/${item.at.month}/${item.at.year}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lead Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_lead == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lead Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 80, color: colorScheme.outline),
              const SizedBox(height: 16),
              Text(
                'Lead not found',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                backgroundColor: colorScheme.surface,
                foregroundColor: colorScheme.onSurface,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                    child: Row(
                      children: [
                        _buildAvatar(_lead!.name, colorScheme),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _lead!.name,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_lead!.phone} • ${_lead!.divisionName ?? 'Unknown Division'}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),

                  // Solar Requirements Card
                  _buildCard(
                    title: 'Solar requirements',
                    child: Column(
                      children: [
                        _buildKeyValue(
                          'Monthly units',
                          _lead!.monthlyUnits ?? '—',
                        ),
                        if (_lead!.amount != null) ...[
                          const SizedBox(height: 12),
                          _buildKeyValue(
                            'Estimated amount',
                            '₹${_lead!.amount}',
                          ),
                        ],
                        const SizedBox(height: 12),
                        _buildKeyValue(
                          'Avg last 6 months',
                          _lead!.avgUnits ?? '—',
                        ),
                      ],
                    ),
                  ),

                  // Reminder Card
                  _buildCard(
                    title: 'Reminder',
                    child: _lead!.reminderAt != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${_lead!.reminderAt!.day}/${_lead!.reminderAt!.month}/${_lead!.reminderAt!.year} ${_lead!.reminderAt!.hour}:${_lead!.reminderAt!.minute.toString().padLeft(2, '0')}',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                  if (_lead!.reminderType != null) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        color: _badgeColorForType(
                                          _lead!.reminderType,
                                          colorScheme,
                                        ),
                                      ),
                                      child: Text(
                                        _lead!.reminderType!.toUpperCase(),
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _lead!.reminderNote ?? 'No note',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'No reminder set',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                  ),

                  // History Card
                  _buildCard(
                    title: 'History',
                    action: IconButton(
                      onPressed: () => _showAlert('Add', 'Add history event'),
                      icon: Icon(Icons.add, color: colorScheme.primary),
                    ),
                    child: Column(
                      children: _history
                          .map((item) => _buildHistoryItem(item))
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 100), // Space for FAB
                ]),
              ),
            ],
          ),

          // Floating Action Button
          Positioned(
            right: 18,
            bottom: 26,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _actionsOpen = true;
                });
              },
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              child: const Icon(Icons.add),
            ),
          ),

          // Action Sheet Modal
          if (_actionsOpen)
            GestureDetector(
              onTap: () {
                setState(() {
                  _actionsOpen = false;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionOption(
                          icon: Icons.phone,
                          title: 'Call',
                          onTap: () => _onAction('call'),
                        ),
                        _buildActionOption(
                          icon: Icons.calendar_today,
                          title: 'Schedule meeting',
                          onTap: () => _onAction('meeting'),
                        ),
                        _buildActionOption(
                          icon: Icons.edit,
                          title: 'Add note',
                          onTap: () => _onAction('note'),
                          isLast: true,
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _actionsOpen = false;
                              });
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: colorScheme.outline.withOpacity(0.1),
                  ),
                ),
        ),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: 18),
            const SizedBox(width: 12),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
