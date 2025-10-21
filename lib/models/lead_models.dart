class Lead {
  final String? id;
  final String name;
  final String phone;
  final String? divisionName;
  final DateTime? createdAt;
  final String? status;

  Lead({
    this.id,
    required this.name,
    required this.phone,
    this.divisionName,
    this.createdAt,
    this.status,
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
    };
  }

  Lead copyWith({
    String? id,
    String? name,
    String? phone,
    String? divisionName,
    DateTime? createdAt,
    String? status,
  }) {
    return Lead(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      divisionName: divisionName ?? this.divisionName,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'Lead{id: $id, name: $name, phone: $phone, divisionName: $divisionName}';
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
    return id.hashCode ^
        name.hashCode ^
        phone.hashCode ^
        divisionName.hashCode;
  }
}