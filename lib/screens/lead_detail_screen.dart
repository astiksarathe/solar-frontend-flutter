import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:speech_to_text/speech_to_text.dart';  // Temporarily disabled
// import 'package:permission_handler/permission_handler.dart';  // Temporarily disabled
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
      final response = await LeadService.getLeadById(widget.leadId);

      if (response.success && response.data != null) {
        // Convert API response to Lead model
        final leadData = response.data!['lead'];
        final lead = Lead.fromJson(leadData);

        setState(() {
          _lead = lead;
          _loading = false;
        });
      } else {
        // If API fails, try to create a default lead for demo
        setState(() {
          _lead = Lead(
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
          );
          _loading = false;
        });
      }
    } catch (e) {
      // On error, create a default lead for demo
      setState(() {
        _lead = Lead(
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
        );
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

  Future<void> _makePhoneCall(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          _showAlert('Error', 'Cannot make call to $phone');
        }
      }
    } catch (e) {
      if (mounted) {
        _showAlert('Error', 'Error making call: $e');
      }
    }
  }

  Future<void> _onAction(String type) async {
    setState(() {
      _actionsOpen = false;
    });

    switch (type) {
      case 'call':
        if (_lead?.phone != null) {
          _makePhoneCall(_lead!.phone);
        } else {
          _showAlert('Call', 'Phone number not available');
        }
        break;
      case 'schedule':
        _showScheduleFollowUpDialog();
        break;
      case 'note':
        _showAddNoteDialog();
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

  void _showScheduleFollowUpDialog() {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = TimeOfDay.now();
    String selectedFollowUpType = 'Call';
    final addressController = TextEditingController();
    final notesController = TextEditingController();

    final followUpTypes = [
      'Call',
      'Meeting',
      'Site Visit',
      'Video Call',
      'Email Follow-up',
      'WhatsApp Follow-up',
      'Document Review',
      'Technical Discussion',
      'Quote Discussion',
      'Final Closing',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Schedule Follow-up'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Follow-up Type'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedFollowUpType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: followUpTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedFollowUpType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('Date'),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('Time'),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(selectedTime.format(context)),
                  trailing: const Icon(Icons.edit),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setState(() {
                        selectedTime = time;
                      });
                    }
                  },
                ),
                // Show address field only for physical follow-ups
                if ([
                  'Meeting',
                  'Site Visit',
                ].contains(selectedFollowUpType)) ...[
                  const SizedBox(height: 16),
                  Text('$selectedFollowUpType Address'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      hintText:
                          'Enter ${selectedFollowUpType.toLowerCase()} address...',
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
                const SizedBox(height: 16),
                Text('$selectedFollowUpType Notes'),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    hintText: 'Additional notes...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Save the follow-up
                _saveFollowUp(
                  selectedFollowUpType,
                  selectedDate,
                  selectedTime,
                  addressController.text,
                  notesController.text,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Schedule'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveFollowUp(
    String followUpType,
    DateTime date,
    TimeOfDay time,
    String address,
    String notes,
  ) {
    final followUpDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    String message;
    if (['Meeting', 'Site Visit'].contains(followUpType) &&
        address.isNotEmpty) {
      message =
          '$followUpType scheduled for ${followUpDateTime.day}/${followUpDateTime.month}/${followUpDateTime.year} at ${time.format(context)} - Location: $address';
    } else {
      message =
          '$followUpType scheduled for ${followUpDateTime.day}/${followUpDateTime.month}/${followUpDateTime.year} at ${time.format(context)}';
    }

    // Here you would typically save to a database or API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );

    // Add to history
    setState(() {
      _history.insert(
        0,
        HistoryItem(
          id: 'h${DateTime.now().millisecondsSinceEpoch}',
          type: followUpType,
          note: notes.isNotEmpty ? notes : 'Scheduled $followUpType',
          at: followUpDateTime,
          done: false,
        ),
      );
    });
  }

  void _showAddNoteDialog() {
    final noteController = TextEditingController();
    // Speech-to-text temporarily disabled due to build issues

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Note'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    hintText: 'Enter your note...',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.mic_none, color: Colors.grey),
                      onPressed: () async {
                        // Voice-to-text functionality temporarily disabled
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Voice-to-text feature coming soon! Please type your note for now.',
                            ),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      },
                    ),
                  ),
                  maxLines: 5,
                  minLines: 3,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Note: Voice input will be available in a future update.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _saveNote(noteController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Save Note'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveNote(String note) {
    if (note.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a note'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Here you would typically save to a database or API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Note saved: ${note.substring(0, note.length > 30 ? 30 : note.length)}${note.length > 30 ? '...' : ''}',
        ),
        backgroundColor: Colors.green,
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
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildHistoryItem(HistoryItem item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: colorScheme.surfaceContainerHighest,
            ),
            child: Center(
              child: Text(
                item.type.isNotEmpty ? item.type[0].toUpperCase() : '?',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.type,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ),
                    Text(
                      '${item.at.day}/${item.at.month}/${item.at.year}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.note,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
                if (item.done && item.actor != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: Colors.green.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Done by ${item.actor}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green.withOpacity(0.8),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_lead == null) {
      return Scaffold(
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildAvatar(_lead!.name, colorScheme),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _lead!.name,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${_lead!.phone} • ${_lead!.divisionName ?? 'Unknown Division'}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                  height: 1.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                        Row(
                          children: [
                            Expanded(
                              child: _buildKeyValue(
                                'Monthly units',
                                _lead!.monthlyUnits ?? '—',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildKeyValue(
                                'Avg last 6 months',
                                _lead!.avgUnits ?? '—',
                              ),
                            ),
                          ],
                        ),
                        if (_lead!.amount != null) ...[
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: _buildKeyValue(
                              'Estimated amount',
                              '₹${_lead!.amount}',
                            ),
                          ),
                        ],
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Date & Time',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.6),
                                                height: 1.2,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${_lead!.reminderAt!.day}/${_lead!.reminderAt!.month}/${_lead!.reminderAt!.year} ${_lead!.reminderAt!.hour}:${_lead!.reminderAt!.minute.toString().padLeft(2, '0')}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                height: 1.3,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  if (_lead!.reminderType != null)
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          color: _badgeColorForType(
                                            _lead!.reminderType,
                                            Theme.of(context).colorScheme,
                                          ),
                                        ),
                                        child: Text(
                                          _lead!.reminderType!.toUpperCase(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Note',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.6),
                                      height: 1.2,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _lead!.reminderNote ?? 'No note',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                    ),
                              ),
                            ],
                          )
                        : Text(
                            'No reminder set',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                                ),
                          ),
                  ),

                  // History Card
                  _buildCard(
                    title: 'History',
                    action: IconButton(
                      onPressed: () => _showAlert('Add', 'Add history event'),
                      icon: Icon(
                        Icons.add,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: _history.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.history,
                                    size: 48,
                                    color: colorScheme.onSurface.withOpacity(
                                      0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No history yet',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface.withOpacity(
                                        0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Column(
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
            right: 20,
            bottom: 30,
            child: FloatingActionButton(
              heroTag: "lead_detail_fab",
              onPressed: () {
                setState(() {
                  _actionsOpen = true;
                });
              },
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 6,
              child: const Icon(Icons.add, size: 24),
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
                          title: 'Schedule follow-up',
                          onTap: () => _onAction('schedule'),
                        ),
                        _buildActionOption(
                          icon: Icons.edit,
                          title: 'Add note',
                          onTap: () => _onAction('note'),
                          isLast: true,
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: colorScheme.outline.withOpacity(0.1),
                              ),
                            ),
                          ),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _actionsOpen = false;
                              });
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.6),
                                fontWeight: FontWeight.w600,
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
      borderRadius: isLast
          ? const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            )
          : BorderRadius.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
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
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: colorScheme.primary.withOpacity(0.1),
              ),
              child: Center(
                child: Icon(icon, color: colorScheme.primary, size: 18),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }
}
