class Lead {
  final String? id;
  final String name;
  final String phone;
  final String? divisionName;
  final DateTime? createdAt;
  final String? status;
  final String? consumerNumber;
  final String? monthlyUnits;
  final String? amount;
  final String? purpose;
  final DateTime? reminderAt;
  final String? reminderType;
  final String? reminderNote;
  final String? avgUnits;

  Lead({
    this.id,
    required this.name,
    required this.phone,
    this.divisionName,
    this.createdAt,
    this.status,
    this.consumerNumber,
    this.monthlyUnits,
    this.amount,
    this.purpose,
    this.reminderAt,
    this.reminderType,
    this.reminderNote,
    this.avgUnits,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'],
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      divisionName: json['divisionName'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      status: json['status'],
      consumerNumber: json['consumerNumber'],
      monthlyUnits: json['monthly_units'],
      amount: json['amount'],
      purpose: json['purpose'],
      reminderAt: json['reminder_at'] != null
          ? DateTime.parse(json['reminder_at'])
          : null,
      reminderType: json['reminder_type'],
      reminderNote: json['reminder_note'],
      avgUnits: json['avgUnits'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'divisionName': divisionName,
      'createdAt': createdAt?.toIso8601String(),
      'status': status,
      'consumerNumber': consumerNumber,
      'monthly_units': monthlyUnits,
      'amount': amount,
      'purpose': purpose,
      'reminder_at': reminderAt?.toIso8601String(),
      'reminder_type': reminderType,
      'reminder_note': reminderNote,
      'avgUnits': avgUnits,
    };
  }

  Lead copyWith({
    String? id,
    String? name,
    String? phone,
    String? divisionName,
    DateTime? createdAt,
    String? status,
    String? consumerNumber,
    String? monthlyUnits,
    String? amount,
    String? purpose,
    DateTime? reminderAt,
    String? reminderType,
    String? reminderNote,
    String? avgUnits,
  }) {
    return Lead(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      divisionName: divisionName ?? this.divisionName,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      consumerNumber: consumerNumber ?? this.consumerNumber,
      monthlyUnits: monthlyUnits ?? this.monthlyUnits,
      amount: amount ?? this.amount,
      purpose: purpose ?? this.purpose,
      reminderAt: reminderAt ?? this.reminderAt,
      reminderType: reminderType ?? this.reminderType,
      reminderNote: reminderNote ?? this.reminderNote,
      avgUnits: avgUnits ?? this.avgUnits,
    );
  }

  @override
  String toString() {
    return 'Lead{id: $id, name: $name, phone: $phone, divisionName: $divisionName, consumerNumber: $consumerNumber}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Lead &&
        other.id == id &&
        other.name == name &&
        other.phone == phone &&
        other.divisionName == divisionName;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ phone.hashCode ^ divisionName.hashCode;
  }
}

class HistoryItem {
  final String id;
  final String type;
  final String note;
  final DateTime at;
  final bool done;
  final String? actor;

  HistoryItem({
    required this.id,
    required this.type,
    required this.note,
    required this.at,
    this.done = false,
    this.actor,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'],
      type: json['type'],
      note: json['note'],
      at: DateTime.parse(json['at']),
      done: json['done'] ?? false,
      actor: json['actor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'note': note,
      'at': at.toIso8601String(),
      'done': done,
      'actor': actor,
    };
  }
}
