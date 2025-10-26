import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_models.dart';
import 'api_config.dart';

class OrderService {
  // Create order
  static Future<ApiResponse<Map<String, dynamic>>> createOrder(
    Map<String, dynamic> orderData,
  ) async {
    ApiConfig.logRequest('POST', '/orders', body: orderData);

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.post(
        ApiUtils.buildUri('/orders'),
        headers: headers,
        body: jsonEncode(orderData),
      );
      return response;
    }, endpoint: 'create-order');
  }

  // Get all orders
  static Future<ApiResponse<PaginatedResponse<Map<String, dynamic>>>>
  getAllOrders({
    int page = 1,
    int limit = 10,
    String? status,
    String? assignedTo,
    String? orderType,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (status != null) 'status': status,
      if (assignedTo != null) 'assignedTo': assignedTo,
      if (orderType != null) 'orderType': orderType,
      if (fromDate != null) 'fromDate': fromDate.toIso8601String(),
      if (toDate != null) 'toDate': toDate.toIso8601String(),
    };

    return ApiUtils.handleRequest<PaginatedResponse<Map<String, dynamic>>>(
      () async {
        final headers = await ApiConfig.authHeaders;
        final response = await http.get(
          ApiUtils.buildUri('/orders', queryParameters: queryParams),
          headers: headers,
        );
        return response;
      },
      fromJson: (data) => PaginatedResponse.fromJson(data, (item) => item),
      endpoint: 'get-orders',
    );
  }

  // Get order by ID
  static Future<ApiResponse<Map<String, dynamic>>> getOrderById(
    String id,
  ) async {
    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.get(
        ApiUtils.buildUri('/orders/$id'),
        headers: headers,
      );
      return response;
    }, endpoint: 'get-order');
  }

  // Update order status
  static Future<ApiResponse<Map<String, dynamic>>> updateOrderStatus(
    String id,
    String status, {
    String? notes,
    String? updatedBy,
  }) async {
    final data = {
      'status': status,
      if (notes != null) 'notes': notes,
      if (updatedBy != null) 'updatedBy': updatedBy,
    };

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.patch(
        ApiUtils.buildUri('/orders/$id/status'),
        headers: headers,
        body: jsonEncode(data),
      );
      return response;
    }, endpoint: 'update-order-status');
  }

  // Get orders by status
  static Future<ApiResponse<List<Map<String, dynamic>>>> getOrdersByStatus(
    String status,
  ) async {
    return ApiUtils.handleRequest<List<Map<String, dynamic>>>(
      () async {
        final headers = await ApiConfig.authHeaders;
        final response = await http.get(
          ApiUtils.buildUri('/orders/status/$status'),
          headers: headers,
        );
        return response;
      },
      fromJson: (data) =>
          (data['orders'] as List?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList() ??
          [],
      endpoint: 'get-orders-by-status',
    );
  }

  // Legacy methods for backward compatibility (will be phased out)
  static Future<bool> addOrder(SolarOrder order) async {
    final orderData = {
      'customerId': order.id,
      'customerName': order.customerName,
      'customerEmail': order.customerEmail,
      'customerPhone': order.customerPhone,
      'orderType': 'SOLAR_INSTALLATION',
      'systemSize': order.systemCapacity,
      'totalAmount': order.costBreakdown?.totalCost ?? 0,
      'assignedTo': order.assignedTo,
      'expectedCompletionDate': order.expectedCompletionDate?.toIso8601String(),
    };

    final result = await createOrder(orderData);
    return result.success;
  }
}
