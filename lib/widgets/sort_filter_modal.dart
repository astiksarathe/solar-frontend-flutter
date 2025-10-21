import 'package:flutter/material.dart';
import '../models/filter_models.dart';

class SortFilterModal extends StatefulWidget {
  final bool visible;
  final VoidCallback onClose;
  final Function(DirectorySort sort, DirectoryFilter filter) onApply;
  final DirectorySort initialSort;
  final DirectoryFilter initialFilter;

  const SortFilterModal({
    super.key,
    required this.visible,
    required this.onClose,
    required this.onApply,
    required this.initialSort,
    required this.initialFilter,
  });

  @override
  State<SortFilterModal> createState() => _SortFilterModalState();
}

class _SortFilterModalState extends State<SortFilterModal> {
  late DirectorySort _sort;
  late DirectoryFilter _filter;

  @override
  void initState() {
    super.initState();
    _sort = widget.initialSort;
    _filter = widget.initialFilter;
  }

  @override
  void didUpdateWidget(SortFilterModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) {
      // Reset to initial values when modal opens
      setState(() {
        _sort = widget.initialSort;
        _filter = widget.initialFilter;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _sort = DirectorySort.none;
      _filter = DirectoryFilter();
    });
  }

  void _applyFilters() {
    widget.onApply(_sort, _filter);
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    return Material(
      color: Colors.black54,
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Sort & Filter',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _clearFilters,
                          child: const Text('Clear'),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: widget.onClose,
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sort Section
                          Text(
                            'Sort By',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          _buildSortOptions(),

                          const SizedBox(height: 24),

                          // Filter Section
                          Text(
                            'Filter',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          _buildFilterOptions(),
                        ],
                      ),
                    ),
                  ),

                  // Apply Button
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _applyFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOptions() {
    return Column(
      children: [
        _buildSortOption('None', DirectorySort.none),
        _buildSortOption('Name', DirectorySort.name),
        _buildSortOption('Monthly Units', DirectorySort.units),
        _buildSortOption('Amount', DirectorySort.amount),
        _buildSortOption('Consumer Number', DirectorySort.consumerNumber),
        _buildSortOption('Reminder', DirectorySort.reminder),
      ],
    );
  }

  Widget _buildSortOption(String title, DirectorySort sort) {
    return RadioListTile<DirectorySort>(
      title: Text(title),
      value: sort,
      groupValue: _sort,
      onChanged: (value) {
        setState(() {
          _sort = value!;
        });
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildFilterOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Has Reminder
        CheckboxListTile(
          title: const Text('Has Reminder'),
          value: _filter.hasReminder ?? false,
          onChanged: (value) {
            setState(() {
              _filter = _filter.copyWith(hasReminder: value);
            });
          },
          contentPadding: EdgeInsets.zero,
        ),

        const SizedBox(height: 16),

        // Monthly Units Range
        Text(
          'Monthly Units Range',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Min Units',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: _filter.minUnits ?? ''),
                onChanged: (value) {
                  _filter = _filter.copyWith(
                    minUnits: value.isEmpty ? null : value,
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Max Units',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: _filter.maxUnits ?? ''),
                onChanged: (value) {
                  _filter = _filter.copyWith(
                    maxUnits: value.isEmpty ? null : value,
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Purpose
        TextField(
          decoration: const InputDecoration(
            labelText: 'Purpose',
            border: OutlineInputBorder(),
          ),
          controller: TextEditingController(text: _filter.purpose ?? ''),
          onChanged: (value) {
            _filter = _filter.copyWith(purpose: value.isEmpty ? null : value);
          },
        ),

        const SizedBox(height: 16),

        // Reminder Type
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Reminder Type',
            border: OutlineInputBorder(),
          ),
          initialValue: _filter.reminderType,
          items: const [
            DropdownMenuItem(value: null, child: Text('Any')),
            DropdownMenuItem(value: 'call', child: Text('Call')),
            DropdownMenuItem(value: 'email', child: Text('Email')),
            DropdownMenuItem(value: 'sms', child: Text('SMS')),
            DropdownMenuItem(value: 'visit', child: Text('Visit')),
          ],
          onChanged: (value) {
            setState(() {
              _filter = _filter.copyWith(reminderType: value);
            });
          },
        ),
      ],
    );
  }
}
