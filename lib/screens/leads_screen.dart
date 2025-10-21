import 'package:flutter/material.dart';
import '../models/lead_models.dart';
import '../services/lead_service.dart';
import 'add_lead_screen.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  List<Lead> _leads = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLeads();
  }

  void _loadLeads() {
    setState(() {
      _loading = true;
    });
    
    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _leads = LeadService.getLeads();
        _loading = false;
      });
    });
  }

  void _navigateToAddLead() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddLeadScreen()),
    );
    
    // Refresh the list when returning from add screen
    if (result == true || mounted) {
      _loadLeads();
    }
  }

  void _deleteLead(Lead lead) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Lead'),
          content: Text('Are you sure you want to delete ${lead.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && lead.id != null) {
      final success = await LeadService.deleteLead(lead.id!);
      if (success) {
        _loadLeads();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${lead.name} deleted successfully')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leads'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _leads.isEmpty
              ? _buildEmptyState()
              : _buildLeadsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddLead,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No leads yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first lead',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToAddLead,
            icon: const Icon(Icons.add),
            label: const Text('Add Lead'),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _leads.length,
      itemBuilder: (context, index) {
        final lead = _leads[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                lead.name.isNotEmpty ? lead.name[0].toUpperCase() : 'L',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              lead.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(LeadService.formatPhone(lead.phone)),
                if (lead.divisionName != null) 
                  Text(
                    lead.divisionName!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  // TODO: Navigate to edit screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit feature coming soon!')),
                  );
                } else if (value == 'delete') {
                  _deleteLead(lead);
                }
              },
            ),
            onTap: () {
              // TODO: Navigate to lead details
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tapped on ${lead.name}')),
              );
            },
          ),
        );
      },
    );
  }
}