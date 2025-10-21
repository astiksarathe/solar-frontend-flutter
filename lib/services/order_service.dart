import '../models/order_models.dart';

class OrderService {
  static final List<SolarOrder> _orders = [];
  static bool _initialized = false;

  // Current user role for access control
  static UserRole _currentUserRole = UserRole.admin;

  static void setUserRole(UserRole role) {
    _currentUserRole = role;
  }

  static UserRole get currentUserRole => _currentUserRole;

  // Check if user can view cost breakdown
  static bool canViewCostBreakdown() {
    return _currentUserRole == UserRole.admin ||
        _currentUserRole == UserRole.manager;
  }

  // Check if user can edit orders
  static bool canEditOrders() {
    return _currentUserRole == UserRole.admin ||
        _currentUserRole == UserRole.manager;
  }

  // Check if user can view all orders
  static bool canViewAllOrders() {
    return _currentUserRole == UserRole.admin ||
        _currentUserRole == UserRole.manager;
  }

  static void _initializeSampleData() {
    if (_initialized) return;

    final now = DateTime.now();

    // Sample orders with different stages
    _orders.addAll([
      SolarOrder(
        id: 'order_1',
        orderId: 'SO-2024-001',
        customerName: 'Rajesh Kumar',
        customerPhone: '9876543210',
        customerEmail: 'rajesh.kumar@email.com',
        installationAddress: '123 Green Park, New Delhi - 110016',
        systemCapacity: 5.0,
        panelBrand: 'Tata Solar',
        inverterBrand: 'ABB',
        status: OrderStatus.panelInstallation,
        createdAt: now.subtract(const Duration(days: 15)),
        expectedCompletionDate: now.add(const Duration(days: 10)),
        assignedTo: 'Tech Team A',
        leadId: 'lead_1',
        stages: [
          OrderStage(
            id: 'stage_1',
            name: 'Order Confirmation',
            description: 'Order confirmed and payment received',
            isCompleted: true,
            completedAt: now.subtract(const Duration(days: 15)),
            completedBy: 'Sales Team',
            notes: 'Advance payment of ₹50,000 received',
          ),
          OrderStage(
            id: 'stage_2',
            name: 'Documents Collection',
            description: 'All required documents collected',
            isCompleted: true,
            completedAt: now.subtract(const Duration(days: 12)),
            completedBy: 'Documentation Team',
            notes:
                'Electricity bill, property documents, and ID proof collected',
          ),
          OrderStage(
            id: 'stage_3',
            name: 'Loan Processing',
            description: 'Loan application and approval process',
            isCompleted: true,
            completedAt: now.subtract(const Duration(days: 8)),
            completedBy: 'Finance Team',
            notes: 'Loan approved for ₹2,50,000 at 8.5% interest',
          ),
          OrderStage(
            id: 'stage_4',
            name: 'Structure Installation',
            description: 'Mounting structure installation on roof',
            isCompleted: true,
            completedAt: now.subtract(const Duration(days: 3)),
            completedBy: 'Installation Team',
            notes: 'Galvanized steel structure installed with proper earthing',
          ),
          OrderStage(
            id: 'stage_5',
            name: 'Panel Installation',
            description: 'Solar panels installation and wiring',
            isCompleted: false,
            notes: 'In progress - 60% panels installed',
          ),
          OrderStage(
            id: 'stage_6',
            name: 'Net Metering',
            description: 'Net metering application and installation',
            isCompleted: false,
          ),
        ],
        costBreakdown: CostBreakdown(
          panelCost: 150000,
          inverterCost: 80000,
          structureCost: 40000,
          installationCost: 35000,
          netMeteringCost: 15000,
          miscellaneousCost: 10000,
          discount: 15000,
          taxAmount: 31500,
          totalCost: 346500,
        ),
      ),

      SolarOrder(
        id: 'order_2',
        orderId: 'SO-2024-002',
        customerName: 'Priya Sharma',
        customerPhone: '9123456789',
        customerEmail: 'priya.sharma@email.com',
        installationAddress: '456 Solar Avenue, Mumbai - 400001',
        systemCapacity: 3.0,
        panelBrand: 'Adani Solar',
        inverterBrand: 'Delta',
        status: OrderStatus.underLoan,
        createdAt: now.subtract(const Duration(days: 8)),
        expectedCompletionDate: now.add(const Duration(days: 20)),
        assignedTo: 'Finance Team',
        leadId: 'lead_2',
        stages: [
          OrderStage(
            id: 'stage_1',
            name: 'Order Confirmation',
            description: 'Order confirmed and payment received',
            isCompleted: true,
            completedAt: now.subtract(const Duration(days: 8)),
            completedBy: 'Sales Team',
            notes: 'Full payment of ₹2,10,000 received',
          ),
          OrderStage(
            id: 'stage_2',
            name: 'Documents Collection',
            description: 'All required documents collected',
            isCompleted: true,
            completedAt: now.subtract(const Duration(days: 6)),
            completedBy: 'Documentation Team',
            notes: 'All documents verified and approved',
          ),
          OrderStage(
            id: 'stage_3',
            name: 'Loan Processing',
            description: 'Loan application and approval process',
            isCompleted: false,
            notes: 'Loan application submitted to bank, awaiting approval',
          ),
          OrderStage(
            id: 'stage_4',
            name: 'Structure Installation',
            description: 'Mounting structure installation on roof',
            isCompleted: false,
          ),
          OrderStage(
            id: 'stage_5',
            name: 'Panel Installation',
            description: 'Solar panels installation and wiring',
            isCompleted: false,
          ),
          OrderStage(
            id: 'stage_6',
            name: 'Net Metering',
            description: 'Net metering application and installation',
            isCompleted: false,
          ),
        ],
        costBreakdown: CostBreakdown(
          panelCost: 90000,
          inverterCost: 50000,
          structureCost: 25000,
          installationCost: 20000,
          netMeteringCost: 12000,
          miscellaneousCost: 8000,
          discount: 10000,
          taxAmount: 19500,
          totalCost: 214500,
        ),
      ),

      SolarOrder(
        id: 'order_3',
        orderId: 'SO-2024-003',
        customerName: 'Ankit Patel',
        customerPhone: '9555666777',
        customerEmail: 'ankit.patel@email.com',
        installationAddress: '789 Sun City, Ahmedabad - 380001',
        systemCapacity: 7.0,
        panelBrand: 'Vikram Solar',
        inverterBrand: 'SMA',
        status: OrderStatus.netMeteringCompleted,
        createdAt: now.subtract(const Duration(days: 45)),
        expectedCompletionDate: now.subtract(const Duration(days: 5)),
        assignedTo: 'Project Manager',
        leadId: 'lead_3',
        stages: [
          OrderStage(
            id: 'stage_1',
            name: 'Order Confirmation',
            description: 'Order confirmed and payment received',
            isCompleted: true,
            completedAt: now.subtract(const Duration(days: 45)),
            completedBy: 'Sales Team',
            notes:
                'Advance payment of ₹1,00,000 received, balance on completion',
          ),
          OrderStage(
            id: 'stage_2',
            name: 'Documents Collection',
            description: 'All required documents collected',
            isCompleted: true,
            completedAt: now.subtract(const Duration(days: 42)),
            completedBy: 'Documentation Team',
            notes: 'Complete documentation for 7kW system',
          ),
          OrderStage(
            id: 'stage_3',
            name: 'Loan Processing',
            description: 'Loan application and approval process',
            isCompleted: true,
            completedAt: now.subtract(const Duration(days: 35)),
            completedBy: 'Finance Team',
            notes: 'Subsidized loan approved under PM KUSUM scheme',
          ),
          OrderStage(
            id: 'stage_4',
            name: 'Structure Installation',
            description: 'Mounting structure installation on roof',
            isCompleted: true,
            completedAt: now.subtract(const Duration(days: 25)),
            completedBy: 'Installation Team',
            notes: 'Heavy-duty structure for 7kW system installed',
          ),
          OrderStage(
            id: 'stage_5',
            name: 'Panel Installation',
            description: 'Solar panels installation and wiring',
            isCompleted: true,
            completedAt: now.subtract(const Duration(days: 15)),
            completedBy: 'Installation Team',
            notes: '28 panels of 250W each installed with complete wiring',
          ),
          OrderStage(
            id: 'stage_6',
            name: 'Net Metering',
            description: 'Net metering application and installation',
            isCompleted: true,
            completedAt: now.subtract(const Duration(days: 5)),
            completedBy: 'Electrical Team',
            notes: 'Net meter installed and connected to grid. System is live!',
          ),
        ],
        costBreakdown: CostBreakdown(
          panelCost: 210000,
          inverterCost: 120000,
          structureCost: 60000,
          installationCost: 50000,
          netMeteringCost: 20000,
          miscellaneousCost: 15000,
          discount: 25000,
          taxAmount: 45000,
          totalCost: 495000,
        ),
      ),
    ]);

    _initialized = true;
  }

  // Get all orders based on user permissions
  static List<SolarOrder> getOrders() {
    _initializeSampleData();

    if (canViewAllOrders()) {
      return List.from(_orders);
    } else {
      // Return limited orders for other roles
      return _orders
          .where(
            (order) =>
                order.assignedTo != null &&
                order.assignedTo!.toLowerCase().contains('team'),
          )
          .toList();
    }
  }

  // Get order by ID
  static SolarOrder? getOrderById(String id) {
    _initializeSampleData();

    try {
      return _orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add new order
  static Future<bool> addOrder(SolarOrder order) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final newOrder = order.copyWith(
        id: order.id.isEmpty
            ? 'order_${DateTime.now().millisecondsSinceEpoch}'
            : order.id,
      );

      _orders.add(newOrder);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Update order stage
  static Future<bool> updateOrderStage(
    String orderId,
    String stageId,
    OrderStage updatedStage,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex == -1) return false;

      final order = _orders[orderIndex];
      final stages = List<OrderStage>.from(order.stages);

      final stageIndex = stages.indexWhere((stage) => stage.id == stageId);
      if (stageIndex == -1) return false;

      stages[stageIndex] = updatedStage;

      // Update order status based on completed stages
      OrderStatus newStatus = OrderStatus.confirmed;
      int completedCount = stages.where((s) => s.isCompleted).length;

      if (completedCount >= 6) {
        newStatus = OrderStatus.completed;
      } else if (completedCount >= 5) {
        newStatus = OrderStatus.netMeteringCompleted;
      } else if (completedCount >= 4) {
        newStatus = OrderStatus.panelInstallation;
      } else if (completedCount >= 3) {
        newStatus = OrderStatus.structureInstallation;
      } else if (completedCount >= 2) {
        newStatus = OrderStatus.underLoan;
      } else if (completedCount >= 1) {
        newStatus = OrderStatus.documentsReceived;
      }

      _orders[orderIndex] = order.copyWith(stages: stages, status: newStatus);

      return true;
    } catch (e) {
      return false;
    }
  }

  // Get orders by status
  static List<SolarOrder> getOrdersByStatus(OrderStatus status) {
    return getOrders().where((order) => order.status == status).toList();
  }

  // Get orders count
  static int getOrdersCount() {
    return getOrders().length;
  }

  // Clear all orders (for testing)
  static void clearOrders() {
    _orders.clear();
    _initialized = false;
  }

  // Search orders
  static List<SolarOrder> searchOrders(String query) {
    if (query.isEmpty) return getOrders();

    final lowercaseQuery = query.toLowerCase();
    return getOrders().where((order) {
      return order.customerName.toLowerCase().contains(lowercaseQuery) ||
          order.orderId.toLowerCase().contains(lowercaseQuery) ||
          order.customerPhone.contains(query) ||
          order.customerEmail.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Get orders summary
  static Map<String, int> getOrdersSummary() {
    final orders = getOrders();
    return {
      'total': orders.length,
      'confirmed': orders
          .where((o) => o.status == OrderStatus.confirmed)
          .length,
      'in_progress': orders
          .where(
            (o) =>
                o.status == OrderStatus.documentsReceived ||
                o.status == OrderStatus.underLoan ||
                o.status == OrderStatus.structureInstallation ||
                o.status == OrderStatus.panelInstallation,
          )
          .length,
      'completed': orders
          .where(
            (o) =>
                o.status == OrderStatus.netMeteringCompleted ||
                o.status == OrderStatus.completed,
          )
          .length,
      'cancelled': orders
          .where((o) => o.status == OrderStatus.cancelled)
          .length,
    };
  }
}
