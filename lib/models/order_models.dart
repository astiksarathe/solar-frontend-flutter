enum OrderStatus {
  confirmed,
  documentsReceived,
  underLoan,
  structureInstallation,
  panelInstallation,
  netMeteringCompleted,
  completed,
  cancelled,
}

enum UserRole { admin, manager, salesPerson, technician, customer }

class OrderStage {
  final String id;
  final String name;
  final String description;
  final DateTime? completedAt;
  final String? completedBy;
  final String? notes;
  final List<String>? attachments;
  final bool isCompleted;

  OrderStage({
    required this.id,
    required this.name,
    required this.description,
    this.completedAt,
    this.completedBy,
    this.notes,
    this.attachments,
    this.isCompleted = false,
  });

  OrderStage copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? completedAt,
    String? completedBy,
    String? notes,
    List<String>? attachments,
    bool? isCompleted,
  }) {
    return OrderStage(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      completedAt: completedAt ?? this.completedAt,
      completedBy: completedBy ?? this.completedBy,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory OrderStage.fromJson(Map<String, dynamic> json) {
    return OrderStage(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      completedBy: json['completedBy'],
      notes: json['notes'],
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : null,
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'completedAt': completedAt?.toIso8601String(),
      'completedBy': completedBy,
      'notes': notes,
      'attachments': attachments,
      'isCompleted': isCompleted,
    };
  }
}

class CostBreakdown {
  final double panelCost;
  final double inverterCost;
  final double structureCost;
  final double installationCost;
  final double netMeteringCost;
  final double miscellaneousCost;
  final double discount;
  final double taxAmount;
  final double totalCost;

  CostBreakdown({
    required this.panelCost,
    required this.inverterCost,
    required this.structureCost,
    required this.installationCost,
    required this.netMeteringCost,
    required this.miscellaneousCost,
    this.discount = 0,
    required this.taxAmount,
    required this.totalCost,
  });

  factory CostBreakdown.fromJson(Map<String, dynamic> json) {
    return CostBreakdown(
      panelCost: (json['panelCost'] as num).toDouble(),
      inverterCost: (json['inverterCost'] as num).toDouble(),
      structureCost: (json['structureCost'] as num).toDouble(),
      installationCost: (json['installationCost'] as num).toDouble(),
      netMeteringCost: (json['netMeteringCost'] as num).toDouble(),
      miscellaneousCost: (json['miscellaneousCost'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      taxAmount: (json['taxAmount'] as num).toDouble(),
      totalCost: (json['totalCost'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'panelCost': panelCost,
      'inverterCost': inverterCost,
      'structureCost': structureCost,
      'installationCost': installationCost,
      'netMeteringCost': netMeteringCost,
      'miscellaneousCost': miscellaneousCost,
      'discount': discount,
      'taxAmount': taxAmount,
      'totalCost': totalCost,
    };
  }

  double get subtotal =>
      panelCost +
      inverterCost +
      structureCost +
      installationCost +
      netMeteringCost +
      miscellaneousCost;

  double get finalAmount => subtotal - discount + taxAmount;
}

class SolarOrder {
  final String id;
  final String orderId;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String installationAddress;
  final double systemCapacity;
  final String panelBrand;
  final String inverterBrand;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? expectedCompletionDate;
  final List<OrderStage> stages;
  final CostBreakdown? costBreakdown;
  final String? assignedTo;
  final String? leadId;

  SolarOrder({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.installationAddress,
    required this.systemCapacity,
    required this.panelBrand,
    required this.inverterBrand,
    required this.status,
    required this.createdAt,
    this.expectedCompletionDate,
    required this.stages,
    this.costBreakdown,
    this.assignedTo,
    this.leadId,
  });

  factory SolarOrder.fromJson(Map<String, dynamic> json) {
    return SolarOrder(
      id: json['id'],
      orderId: json['orderId'],
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      customerEmail: json['customerEmail'],
      installationAddress: json['installationAddress'],
      systemCapacity: (json['systemCapacity'] as num).toDouble(),
      panelBrand: json['panelBrand'],
      inverterBrand: json['inverterBrand'],
      status: OrderStatus.values[json['status']],
      createdAt: DateTime.parse(json['createdAt']),
      expectedCompletionDate: json['expectedCompletionDate'] != null
          ? DateTime.parse(json['expectedCompletionDate'])
          : null,
      stages: (json['stages'] as List)
          .map((stage) => OrderStage.fromJson(stage))
          .toList(),
      costBreakdown: json['costBreakdown'] != null
          ? CostBreakdown.fromJson(json['costBreakdown'])
          : null,
      assignedTo: json['assignedTo'],
      leadId: json['leadId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
      'installationAddress': installationAddress,
      'systemCapacity': systemCapacity,
      'panelBrand': panelBrand,
      'inverterBrand': inverterBrand,
      'status': status.index,
      'createdAt': createdAt.toIso8601String(),
      'expectedCompletionDate': expectedCompletionDate?.toIso8601String(),
      'stages': stages.map((stage) => stage.toJson()).toList(),
      'costBreakdown': costBreakdown?.toJson(),
      'assignedTo': assignedTo,
      'leadId': leadId,
    };
  }

  SolarOrder copyWith({
    String? id,
    String? orderId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? installationAddress,
    double? systemCapacity,
    String? panelBrand,
    String? inverterBrand,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? expectedCompletionDate,
    List<OrderStage>? stages,
    CostBreakdown? costBreakdown,
    String? assignedTo,
    String? leadId,
  }) {
    return SolarOrder(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      installationAddress: installationAddress ?? this.installationAddress,
      systemCapacity: systemCapacity ?? this.systemCapacity,
      panelBrand: panelBrand ?? this.panelBrand,
      inverterBrand: inverterBrand ?? this.inverterBrand,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expectedCompletionDate:
          expectedCompletionDate ?? this.expectedCompletionDate,
      stages: stages ?? this.stages,
      costBreakdown: costBreakdown ?? this.costBreakdown,
      assignedTo: assignedTo ?? this.assignedTo,
      leadId: leadId ?? this.leadId,
    );
  }

  int get completedStages => stages.where((stage) => stage.isCompleted).length;

  double get progressPercentage =>
      stages.isEmpty ? 0 : (completedStages / stages.length) * 100;

  String get statusDisplayName {
    switch (status) {
      case OrderStatus.confirmed:
        return 'Order Confirmed';
      case OrderStatus.documentsReceived:
        return 'Documents Received';
      case OrderStatus.underLoan:
        return 'Under Loan Processing';
      case OrderStatus.structureInstallation:
        return 'Structure Installation';
      case OrderStatus.panelInstallation:
        return 'Panel Installation';
      case OrderStatus.netMeteringCompleted:
        return 'Net Metering Completed';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}
