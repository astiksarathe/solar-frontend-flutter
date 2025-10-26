import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class UserManagementService {
  // Get all users (Admin only)
  static Future<ApiResponse<PaginatedResponse<Map<String, dynamic>>>>
  getAllUsers({
    int page = 1,
    int limit = 10,
    String? role,
    String? department,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (role != null && role.isNotEmpty) 'role': role,
      if (department != null && department.isNotEmpty) 'department': department,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    ApiConfig.logRequest('GET', '/user', body: queryParams);

    return ApiUtils.handleRequest<PaginatedResponse<Map<String, dynamic>>>(
      () async {
        final headers = await ApiConfig.authHeaders;
        final response = await http.get(
          ApiUtils.buildUri('/user', queryParameters: queryParams),
          headers: headers,
        );
        return response;
      },
      fromJson: (data) => PaginatedResponse.fromJson(data, (item) => item),
      endpoint: 'get-users',
    );
  }

  // Get user by ID
  static Future<ApiResponse<Map<String, dynamic>>> getUserById(
    String userId,
  ) async {
    ApiConfig.logRequest('GET', '/user/$userId');

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.get(
        ApiUtils.buildUri('/user/$userId'),
        headers: headers,
      );
      return response;
    }, endpoint: 'get-user');
  }

  // Update user
  static Future<ApiResponse<Map<String, dynamic>>> updateUser(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    ApiConfig.logRequest('PATCH', '/user/$userId', body: userData);

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.patch(
        ApiUtils.buildUri('/user/$userId'),
        headers: headers,
        body: jsonEncode(userData),
      );
      return response;
    }, endpoint: 'update-user');
  }

  // Delete user (Admin only)
  static Future<ApiResponse<Map<String, dynamic>>> deleteUser(
    String userId,
  ) async {
    ApiConfig.logRequest('DELETE', '/user/$userId');

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.delete(
        ApiUtils.buildUri('/user/$userId'),
        headers: headers,
      );
      return response;
    }, endpoint: 'delete-user');
  }

  // Activate/Deactivate user
  static Future<ApiResponse<Map<String, dynamic>>> toggleUserStatus(
    String userId,
    bool isActive,
  ) async {
    ApiConfig.logRequest(
      'PATCH',
      '/user/$userId/status',
      body: {'isActive': isActive},
    );

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.patch(
        ApiUtils.buildUri('/user/$userId/status'),
        headers: headers,
        body: jsonEncode({'isActive': isActive}),
      );
      return response;
    }, endpoint: 'toggle-user-status');
  }

  // Get users by department
  static Future<ApiResponse<List<Map<String, dynamic>>>> getUsersByDepartment(
    String department,
  ) async {
    ApiConfig.logRequest('GET', '/user/department/$department');

    return ApiUtils.handleRequest<List<Map<String, dynamic>>>(
      () async {
        final headers = await ApiConfig.authHeaders;
        final response = await http.get(
          ApiUtils.buildUri('/user/department/$department'),
          headers: headers,
        );
        return response;
      },
      fromJson: (data) =>
          (data['users'] as List?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList() ??
          [],
      endpoint: 'get-users-by-department',
    );
  }

  // Get users by role
  static Future<ApiResponse<List<Map<String, dynamic>>>> getUsersByRole(
    String role,
  ) async {
    ApiConfig.logRequest('GET', '/user/role/$role');

    return ApiUtils.handleRequest<List<Map<String, dynamic>>>(
      () async {
        final headers = await ApiConfig.authHeaders;
        final response = await http.get(
          ApiUtils.buildUri('/user/role/$role'),
          headers: headers,
        );
        return response;
      },
      fromJson: (data) =>
          (data['users'] as List?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList() ??
          [],
      endpoint: 'get-users-by-role',
    );
  }

  // Change user password (Admin only)
  static Future<ApiResponse<Map<String, dynamic>>> changeUserPassword(
    String userId,
    String newPassword,
  ) async {
    ApiConfig.logRequest('PATCH', '/user/$userId/password');

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.patch(
        ApiUtils.buildUri('/user/$userId/password'),
        headers: headers,
        body: jsonEncode({'newPassword': newPassword}),
      );
      return response;
    }, endpoint: 'change-user-password');
  }

  // Get user statistics (Admin only)
  static Future<ApiResponse<Map<String, dynamic>>> getUserStatistics() async {
    ApiConfig.logRequest('GET', '/user/stats');

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.get(
        ApiUtils.buildUri('/user/stats'),
        headers: headers,
      );
      return response;
    }, endpoint: 'get-user-stats');
  }
}

// User roles enum for better type safety
enum UserRole {
  admin('ADMIN'),
  manager('MANAGER'),
  salesRepresentative('SALES_REPRESENTATIVE'),
  technician('TECHNICIAN'),
  financeTeam('FINANCE_TEAM'),
  customerService('CUSTOMER_SERVICE');

  const UserRole(this.value);
  final String value;

  static UserRole? fromString(String? value) {
    if (value == null) return null;
    for (UserRole role in UserRole.values) {
      if (role.value == value) return role;
    }
    return null;
  }
}

// User departments enum
enum UserDepartment {
  sales('SALES'),
  technical('TECHNICAL'),
  finance('FINANCE'),
  customerService('CUSTOMER_SERVICE'),
  management('MANAGEMENT');

  const UserDepartment(this.value);
  final String value;

  static UserDepartment? fromString(String? value) {
    if (value == null) return null;
    for (UserDepartment dept in UserDepartment.values) {
      if (dept.value == value) return dept;
    }
    return null;
  }
}
