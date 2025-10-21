enum DirectorySort { none, units, amount, consumerNumber, name, reminder }

class DirectoryFilter {
  final bool? hasReminder;
  final String? minUnits;
  final String? maxUnits;
  final String? reminderType;
  final String? purpose;
  final DateTime? startDate;
  final DateTime? endDate;

  DirectoryFilter({
    this.hasReminder,
    this.minUnits,
    this.maxUnits,
    this.reminderType,
    this.purpose,
    this.startDate,
    this.endDate,
  });

  DirectoryFilter copyWith({
    bool? hasReminder,
    String? minUnits,
    String? maxUnits,
    String? reminderType,
    String? purpose,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return DirectoryFilter(
      hasReminder: hasReminder ?? this.hasReminder,
      minUnits: minUnits ?? this.minUnits,
      maxUnits: maxUnits ?? this.maxUnits,
      reminderType: reminderType ?? this.reminderType,
      purpose: purpose ?? this.purpose,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  bool get isEmpty {
    return hasReminder == null &&
        minUnits == null &&
        maxUnits == null &&
        reminderType == null &&
        purpose == null &&
        startDate == null &&
        endDate == null;
  }

  @override
  String toString() {
    return 'DirectoryFilter{hasReminder: $hasReminder, minUnits: $minUnits, maxUnits: $maxUnits, reminderType: $reminderType, purpose: $purpose, startDate: $startDate, endDate: $endDate}';
  }
}
