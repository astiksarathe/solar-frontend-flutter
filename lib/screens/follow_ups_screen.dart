import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/lead_models.dart';
import '../services/lead_service.dart';
import '../widgets/search_bar.dart' as custom;
import '../widgets/lead_card.dart';
import '../screens/lead_detail_screen.dart';

enum FollowUpTab { today, tomorrow, week, all }

class FollowUpsScreen extends StatefulWidget {
  const FollowUpsScreen({super.key});

  @override
  State<FollowUpsScreen> createState() => _FollowUpsScreenState();
}

class _FollowUpsScreenState extends State<FollowUpsScreen> {
  List<Lead> _leads = [];
  String _query = '';
  FollowUpTab _activeTab = FollowUpTab.today;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLeads();
  }

  Future<void> _loadLeads() async {
    setState(() {
      _loading = true;
    });

    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _leads = LeadService.getLeads();
      _loading = false;
    });
  }

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get _tomorrow {
    return _today.add(const Duration(days: 1));
  }

  DateTime get _endOfWeek {
    return _today.add(const Duration(days: 7));
  }

  bool _filterByQuery(Lead lead) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return lead.name.toLowerCase().contains(q) || lead.phone.contains(q);
  }

  List<Lead> get _dueToday {
    return _leads.where((lead) {
      if (!_filterByQuery(lead) || lead.reminderAt == null) return false;
      final reminderDate = DateTime(
        lead.reminderAt!.year,
        lead.reminderAt!.month,
        lead.reminderAt!.day,
      );
      return reminderDate.isAtSameMomentAs(_today);
    }).toList();
  }

  List<Lead> get _dueTomorrow {
    return _leads.where((lead) {
      if (!_filterByQuery(lead) || lead.reminderAt == null) return false;
      final reminderDate = DateTime(
        lead.reminderAt!.year,
        lead.reminderAt!.month,
        lead.reminderAt!.day,
      );
      return reminderDate.isAtSameMomentAs(_tomorrow);
    }).toList();
  }

  List<Lead> get _dueThisWeek {
    return _leads.where((lead) {
      if (!_filterByQuery(lead) || lead.reminderAt == null) return false;
      final reminderDate = lead.reminderAt!;
      return reminderDate.isAfter(_today.subtract(const Duration(days: 1))) &&
          reminderDate.isBefore(_endOfWeek.add(const Duration(days: 1)));
    }).toList();
  }

  List<Lead> get _dueAll {
    return _leads.where((lead) {
      return _filterByQuery(lead) && lead.reminderAt != null;
    }).toList();
  }

  // Demo data for when there are no real follow-ups
  List<Lead> get _demoToday {
    final now = DateTime.now();
    return [
      Lead(
        id: 'D-TODAY-1',
        name: 'Demo — Ramesh Kumar',
        phone: '+919810000099',
        divisionName: 'Demo City',
        monthlyUnits: '320',
        reminderAt: DateTime(now.year, now.month, now.day, 10, 0),
        reminderType: 'callback',
        reminderNote: 'Call to confirm roof availability',
      ),
      Lead(
        id: 'D-TODAY-2',
        name: 'Demo — Suman Verma',
        phone: '+919810000098',
        divisionName: 'Demo Town',
        monthlyUnits: '210',
        reminderAt: DateTime(now.year, now.month, now.day, 15, 30),
        reminderType: 'meeting',
        reminderNote: 'Site visit at 3:30 PM',
      ),
    ];
  }

  List<Lead> get _demoTomorrow {
    final tomorrow = _tomorrow;
    return [
      Lead(
        id: 'D-TOM-1',
        name: 'Demo — Anjali Rao',
        phone: '+919810000097',
        divisionName: 'Demo Ville',
        monthlyUnits: '410',
        reminderAt: DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
          11,
          0,
        ),
        reminderType: 'site_visit',
        reminderNote: 'Measure roof for proposal',
      ),
      Lead(
        id: 'D-TOM-2',
        name: 'Demo — Vikash Singh',
        phone: '+919810000096',
        divisionName: 'Demo Nagar',
        monthlyUnits: '180',
        reminderAt: DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
          16,
          0,
        ),
        reminderType: 'callback',
        reminderNote: 'Discuss financing',
      ),
    ];
  }

  List<Lead> _getDataForTab() {
    switch (_activeTab) {
      case FollowUpTab.today:
        return _dueToday.isNotEmpty ? _dueToday : _demoToday;
      case FollowUpTab.tomorrow:
        return _dueTomorrow.isNotEmpty ? _dueTomorrow : _demoTomorrow;
      case FollowUpTab.week:
        return _dueThisWeek;
      case FollowUpTab.all:
        return _dueAll;
    }
  }

  String _getTabTitle() {
    switch (_activeTab) {
      case FollowUpTab.today:
        return 'Due Today';
      case FollowUpTab.tomorrow:
        return 'Due Tomorrow';
      case FollowUpTab.week:
        return 'Due this week';
      case FollowUpTab.all:
        return 'All follow-ups';
    }
  }

  void _onLeadPress(Lead lead) {
    if (lead.id != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LeadDetailScreen(leadId: lead.id!),
        ),
      );
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
    final theme = Theme.of(context);
    final followUpData = _getDataForTab();

    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          custom.SearchBar(
            value: _query,
            onChanged: (value) {
              setState(() {
                _query = value;
              });
            },
            placeholder: 'Search name or phone',
          ),

          // Tabs
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                _buildTab('Today', FollowUpTab.today),
                const SizedBox(width: 8),
                _buildTab('Tomorrow', FollowUpTab.tomorrow),
                const SizedBox(width: 8),
                _buildTab('This week', FollowUpTab.week),
                const SizedBox(width: 8),
                _buildTab('All', FollowUpTab.all),
              ],
            ),
          ),

          // Section Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            alignment: Alignment.centerLeft,
            child: Text(
              _getTabTitle(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Content
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : followUpData.isEmpty
                ? _buildEmptyState()
                : _buildFollowUpsList(followUpData),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, FollowUpTab tab) {
    final theme = Theme.of(context);
    final isActive = _activeTab == tab;

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = tab;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule, size: 80, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'No follow-ups scheduled',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add reminders to your leads to see them here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpsList(List<Lead> leads) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      itemCount: leads.length,
      itemBuilder: (context, index) {
        final lead = leads[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: LeadCard(
            lead: lead,
            onPress: () => _onLeadPress(lead),
            onCall: _onCall,
            margin: EdgeInsets.zero,
          ),
        );
      },
    );
  }
}
