import 'package:flutter_test/flutter_test.dart';
import 'package:solar_phoenix/models/order_models.dart';
import 'package:solar_phoenix/services/order_service.dart';

void main() {
  group('OrderService', () {
    setUp(() {
      OrderService.clearOrders();
      OrderService.setUserRole(UserRole.admin);
    });

    tearDown(() {
      OrderService.clearOrders();
    });

    test('should initialize with sample data', () {
      final orders = OrderService.getOrders();
      expect(orders.length, greaterThan(0));
    });

    test('should filter orders by user role', () {
      // Admin should see all orders
      OrderService.setUserRole(UserRole.admin);
      final adminOrders = OrderService.getOrders();

      // Sales person should see limited orders
      OrderService.setUserRole(UserRole.salesPerson);
      final salesOrders = OrderService.getOrders();

      expect(adminOrders.length, greaterThanOrEqualTo(salesOrders.length));
    });

    test('should check cost breakdown access correctly', () {
      // Admin should have access
      OrderService.setUserRole(UserRole.admin);
      expect(OrderService.canViewCostBreakdown(), isTrue);

      // Manager should have access
      OrderService.setUserRole(UserRole.manager);
      expect(OrderService.canViewCostBreakdown(), isTrue);

      // Sales person should not have access
      OrderService.setUserRole(UserRole.salesPerson);
      expect(OrderService.canViewCostBreakdown(), isFalse);

      // Customer should not have access
      OrderService.setUserRole(UserRole.customer);
      expect(OrderService.canViewCostBreakdown(), isFalse);
    });

    test('should check edit permissions correctly', () {
      // Admin should be able to edit
      OrderService.setUserRole(UserRole.admin);
      expect(OrderService.canEditOrders(), isTrue);

      // Manager should be able to edit
      OrderService.setUserRole(UserRole.manager);
      expect(OrderService.canEditOrders(), isTrue);

      // Sales person should not be able to edit
      OrderService.setUserRole(UserRole.salesPerson);
      expect(OrderService.canEditOrders(), isFalse);
    });

    test('should search orders correctly', () {
      final results = OrderService.searchOrders('rajesh');
      expect(results.isNotEmpty, isTrue);
      expect(
        results.first.customerName.toLowerCase().contains('rajesh'),
        isTrue,
      );
    });

    test('should get orders by status', () {
      final confirmedOrders = OrderService.getOrdersByStatus(
        OrderStatus.confirmed,
      );
      final completedOrders = OrderService.getOrdersByStatus(
        OrderStatus.completed,
      );

      for (final order in confirmedOrders) {
        expect(order.status, equals(OrderStatus.confirmed));
      }

      for (final order in completedOrders) {
        expect(order.status, equals(OrderStatus.completed));
      }
    });

    test('should calculate progress percentage correctly', () {
      final orders = OrderService.getOrders();

      for (final order in orders) {
        final expectedProgress =
            (order.completedStages / order.stages.length) * 100;
        expect(order.progressPercentage, equals(expectedProgress));
      }
    });

    test('should update order stage correctly', () async {
      final orders = OrderService.getOrders();
      if (orders.isNotEmpty) {
        final order = orders.first;
        final incompleteStage = order.stages.firstWhere(
          (stage) => !stage.isCompleted,
          orElse: () => order.stages.last,
        );

        final updatedStage = incompleteStage.copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
          completedBy: 'Test User',
        );

        final success = await OrderService.updateOrderStage(
          order.id,
          incompleteStage.id,
          updatedStage,
        );

        expect(success, isTrue);

        // Verify the stage was updated
        final updatedOrder = OrderService.getOrderById(order.id);
        final updatedStageInOrder = updatedOrder!.stages.firstWhere(
          (stage) => stage.id == incompleteStage.id,
        );

        expect(updatedStageInOrder.isCompleted, isTrue);
        expect(updatedStageInOrder.completedBy, equals('Test User'));
      }
    });
  });

  group('SolarOrder', () {
    test('should calculate completed stages correctly', () {
      final stages = [
        OrderStage(
          id: '1',
          name: 'Stage 1',
          description: 'Description 1',
          isCompleted: true,
        ),
        OrderStage(
          id: '2',
          name: 'Stage 2',
          description: 'Description 2',
          isCompleted: false,
        ),
        OrderStage(
          id: '3',
          name: 'Stage 3',
          description: 'Description 3',
          isCompleted: true,
        ),
      ];

      final order = SolarOrder(
        id: 'test',
        orderId: 'SO-TEST-001',
        customerName: 'Test Customer',
        customerPhone: '1234567890',
        customerEmail: 'test@example.com',
        installationAddress: 'Test Address',
        systemCapacity: 5.0,
        panelBrand: 'Test Brand',
        inverterBrand: 'Test Inverter',
        status: OrderStatus.confirmed,
        createdAt: DateTime.now(),
        stages: stages,
      );

      expect(order.completedStages, equals(2));
      expect(order.progressPercentage, equals(66.66666666666666));
    });

    test('should generate correct status display name', () {
      expect(OrderStatus.confirmed.name, equals('confirmed'));

      final order = SolarOrder(
        id: 'test',
        orderId: 'SO-TEST-001',
        customerName: 'Test Customer',
        customerPhone: '1234567890',
        customerEmail: 'test@example.com',
        installationAddress: 'Test Address',
        systemCapacity: 5.0,
        panelBrand: 'Test Brand',
        inverterBrand: 'Test Inverter',
        status: OrderStatus.confirmed,
        createdAt: DateTime.now(),
        stages: [],
      );

      expect(order.statusDisplayName, equals('Order Confirmed'));
    });
  });

  group('CostBreakdown', () {
    test('should calculate subtotal correctly', () {
      final cost = CostBreakdown(
        panelCost: 100000,
        inverterCost: 50000,
        structureCost: 30000,
        installationCost: 20000,
        netMeteringCost: 10000,
        miscellaneousCost: 5000,
        taxAmount: 21500,
        totalCost: 236500,
      );

      expect(cost.subtotal, equals(215000));
    });

    test('should calculate final amount correctly', () {
      final cost = CostBreakdown(
        panelCost: 100000,
        inverterCost: 50000,
        structureCost: 30000,
        installationCost: 20000,
        netMeteringCost: 10000,
        miscellaneousCost: 5000,
        discount: 10000,
        taxAmount: 21500,
        totalCost: 226500,
      );

      expect(cost.finalAmount, equals(226500)); // 215000 - 10000 + 21500
    });
  });

  group('OrderStage', () {
    test('should serialize and deserialize correctly', () {
      final stage = OrderStage(
        id: 'test_stage',
        name: 'Test Stage',
        description: 'Test Description',
        isCompleted: true,
        completedAt: DateTime.now(),
        completedBy: 'Test User',
        notes: 'Test notes',
        attachments: ['file1.pdf', 'file2.jpg'],
      );

      final json = stage.toJson();
      final deserializedStage = OrderStage.fromJson(json);

      expect(deserializedStage.id, equals(stage.id));
      expect(deserializedStage.name, equals(stage.name));
      expect(deserializedStage.description, equals(stage.description));
      expect(deserializedStage.isCompleted, equals(stage.isCompleted));
      expect(deserializedStage.completedBy, equals(stage.completedBy));
      expect(deserializedStage.notes, equals(stage.notes));
      expect(deserializedStage.attachments, equals(stage.attachments));
    });
  });
}
