import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/lead_models.dart';
import '../models/filter_models.dart';
import '../services/lead_service.dart';
import '../widgets/search_bar.dart' as custom;
import '../widgets/lead_card.dart';
import '../widgets/sort_filter_modal.dart';
import '../screens/lead_detail_screen.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  List<Lead> _leads = [];
  String _query = '';
  bool _modalOpen = false;
  DirectorySort _sort = DirectorySort.none;
  DirectoryFilter _filter = DirectoryFilter();
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

    // Simulate loading delay and get leads
    await Future.delayed(const Duration(milliseconds: 500));

    // For demo purposes, create some sample leads with additional data
    final sampleLeads = [
      Lead(
        id: 'lead_1',
        name: 'John Doe',
        phone: '9876543210',
        divisionName: 'Mumbai',
        consumerNumber: 'CON123456',
        monthlyUnits: '150',
        amount: '1500',
        purpose: 'Residential',
        reminderAt: DateTime.now().add(const Duration(days: 5)),
        reminderType: 'call',
      ),
      Lead(
        id: 'lead_2',
        name: 'Jane Smith',
        phone: '9123456789',
        divisionName: 'Delhi',
        consumerNumber: 'CON789012',
        monthlyUnits: '200',
        amount: '2200',
        purpose: 'Commercial',
        reminderAt: DateTime.now().add(const Duration(days: 2)),
        reminderType: 'email',
      ),
      Lead(
        id: 'lead_3',
        name: 'Bob Johnson',
        phone: '9555666777',
        divisionName: 'Bangalore',
        consumerNumber: 'CON345678',
        monthlyUnits: '100',
        amount: '1100',
        purpose: 'Residential',
      ),
    ];

    setState(() {
      _leads = [...LeadService.getLeads(), ...sampleLeads];
      _loading = false;
    });
  }

  List<Lead> get _filteredLeads {
    final q = _query.trim().toLowerCase();
    List<Lead> filtered = _leads.where((lead) {
      // Search filter
      if (q.isNotEmpty &&
          !(lead.name.toLowerCase().contains(q) || lead.phone.contains(q))) {
        return false;
      }

      // Has reminder filter
      if (_filter.hasReminder == true && lead.reminderAt == null) {
        return false;
      }

      // Monthly units range filter
      if (_filter.minUnits != null) {
        final minUnits = double.tryParse(_filter.minUnits!) ?? 0;
        final leadUnits = double.tryParse(lead.monthlyUnits ?? '0') ?? 0;
        if (leadUnits < minUnits) return false;
      }

      if (_filter.maxUnits != null) {
        final maxUnits = double.tryParse(_filter.maxUnits!) ?? double.infinity;
        final leadUnits = double.tryParse(lead.monthlyUnits ?? '0') ?? 0;
        if (leadUnits > maxUnits) return false;
      }

      // Purpose filter
      if (_filter.purpose != null && _filter.purpose!.isNotEmpty) {
        final purposeFilter = _filter.purpose!.toLowerCase();
        if (!(lead.purpose?.toLowerCase().contains(purposeFilter) ?? false)) {
          return false;
        }
      }

      // Reminder type filter
      if (_filter.reminderType != null && _filter.reminderType != 'any') {
        if (lead.reminderType == null ||
            lead.reminderType != _filter.reminderType) {
          return false;
        }
      }

      // Date range filters
      if (_filter.startDate != null && lead.reminderAt != null) {
        if (lead.reminderAt!.isBefore(_filter.startDate!)) return false;
      }

      if (_filter.endDate != null && lead.reminderAt != null) {
        if (lead.reminderAt!.isAfter(_filter.endDate!)) return false;
      }

      return true;
    }).toList();

    // Apply sorting
    switch (_sort) {
      case DirectorySort.units:
        filtered.sort((a, b) {
          final aUnits = double.tryParse(b.monthlyUnits ?? '0') ?? 0;
          final bUnits = double.tryParse(a.monthlyUnits ?? '0') ?? 0;
          return aUnits.compareTo(bUnits);
        });
        break;
      case DirectorySort.amount:
        filtered.sort((a, b) {
          final aAmount = double.tryParse(b.amount ?? '0') ?? 0;
          final bAmount = double.tryParse(a.amount ?? '0') ?? 0;
          return aAmount.compareTo(bAmount);
        });
        break;
      case DirectorySort.consumerNumber:
        filtered.sort((a, b) {
          return (a.consumerNumber ?? '').compareTo(b.consumerNumber ?? '');
        });
        break;
      case DirectorySort.name:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case DirectorySort.reminder:
        filtered.sort((a, b) {
          final aHasReminder = a.reminderAt != null ? 1 : 0;
          final bHasReminder = b.reminderAt != null ? 1 : 0;
          return bHasReminder.compareTo(aHasReminder);
        });
        break;
      case DirectorySort.none:
        // No sorting
        break;
    }

    return filtered;
  }

  void _onLeadPress(Lead lead) {
    if (lead.id != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LeadDetailScreen(leadId: lead.id!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lead ID not available for ${lead.name}')),
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
    final filteredLeads = _filteredLeads;

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
                  placeholder: 'Search name or mobile',
                ),

                // Content
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredLeads.isEmpty
                      ? _buildEmptyState()
                      : _buildLeadsList(filteredLeads),
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
            _query.isNotEmpty ? 'No leads found' : 'No leads available',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _query.isNotEmpty
                ? 'Try adjusting your search or filters'
                : 'Add some leads to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadsList(List<Lead> leads) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 120),
      itemCount: leads.length,
      itemBuilder: (context, index) {
        final lead = leads[index];
        return LeadCard(
          lead: lead,
          onPress: () => _onLeadPress(lead),
          onCall: _onCall,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        );
      },
    );
  }
}
