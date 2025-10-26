import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ReminderService {
  // Create reminder
  static Future<ApiResponse<Map<String, dynamic>>> createReminder(
    Map<String, dynamic> reminderData,
  ) async {
    ApiConfig.logRequest('POST', '/reminders', body: reminderData);

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.post(
        ApiUtils.buildUri('/reminders'),
        headers: headers,
        body: jsonEncode(reminderData),
      );
      return response;
    }, endpoint: 'create-reminder');
  }

  // Get all reminders
  static Future<ApiResponse<PaginatedResponse<Map<String, dynamic>>>>
  getAllReminders({
    int page = 1,
    int limit = 10,
    String? status,
    String? assignedTo,
    String? priority,
    String? type,
    String? department,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (status != null) 'status': status,
      if (assignedTo != null) 'assignedTo': assignedTo,
      if (priority != null) 'priority': priority,
      if (type != null) 'type': type,
      if (department != null) 'department': department,
    };

    return ApiUtils.handleRequest<PaginatedResponse<Map<String, dynamic>>>(
      () async {
        final headers = await ApiConfig.authHeaders;
        final response = await http.get(
          ApiUtils.buildUri('/reminders', queryParameters: queryParams),
          headers: headers,
        );
        return response;
      },
      fromJson: (data) => PaginatedResponse.fromJson(data, (item) => item),
      endpoint: 'get-reminders',
    );
  }

  // Get dashboard summary
  static Future<ApiResponse<Map<String, dynamic>>> getDashboardSummary({
    String? assignedTo,
  }) async {
    final queryParams = <String, dynamic>{
      if (assignedTo != null) 'assignedTo': assignedTo,
    };

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.get(
        ApiUtils.buildUri('/reminders/dashboard', queryParameters: queryParams),
        headers: headers,
      );
      return response;
    }, endpoint: 'get-dashboard-summary');
  }

  // Complete reminder
  static Future<ApiResponse<Map<String, dynamic>>> completeReminder(
    String id,
    Map<String, dynamic> completionData,
  ) async {
    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.patch(
        ApiUtils.buildUri('/reminders/$id/complete'),
        headers: headers,
        body: jsonEncode(completionData),
      );
      return response;
    }, endpoint: 'complete-reminder');
  }

  // Add communication entry
  static Future<ApiResponse<Map<String, dynamic>>> addCommunication(
    String reminderId,
    Map<String, dynamic> communicationData,
  ) async {
    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.post(
        ApiUtils.buildUri('/reminders/$reminderId/communication'),
        headers: headers,
        body: jsonEncode(communicationData),
      );
      return response;
    }, endpoint: 'add-communication');
  }
}
