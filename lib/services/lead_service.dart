import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class LeadService {
  // Create lead
  static Future<ApiResponse<Map<String, dynamic>>> createLead(
    Map<String, dynamic> leadData,
  ) async {
    ApiConfig.logRequest('POST', '/leads', body: leadData);

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.post(
        ApiUtils.buildUri('/leads'),
        headers: headers,
        body: jsonEncode(leadData),
      );
      return response;
    }, endpoint: 'create-lead');
  }

  // Get all leads with filters and pagination
  static Future<ApiResponse<PaginatedResponse<Map<String, dynamic>>>>
  getAllLeads({
    int page = 1,
    int limit = 10,
    String? status,
    String? assignedTo,
    String? leadSource,
    String? interestLevel,
    String? search,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (status != null && status.isNotEmpty) 'status': status,
      if (assignedTo != null && assignedTo.isNotEmpty) 'assignedTo': assignedTo,
      if (leadSource != null && leadSource.isNotEmpty) 'leadSource': leadSource,
      if (interestLevel != null && interestLevel.isNotEmpty)
        'interestLevel': interestLevel,
      if (search != null && search.isNotEmpty) 'search': search,
      if (fromDate != null) 'fromDate': fromDate.toIso8601String(),
      if (toDate != null) 'toDate': toDate.toIso8601String(),
    };

    ApiConfig.logRequest('GET', '/leads', body: queryParams);

    return ApiUtils.handleRequest<PaginatedResponse<Map<String, dynamic>>>(
      () async {
        final headers = await ApiConfig.authHeaders;
        final response = await http.get(
          ApiUtils.buildUri('/leads', queryParameters: queryParams),
          headers: headers,
        );
        return response;
      },
      fromJson: (data) => PaginatedResponse.fromJson(data, (item) => item),
      endpoint: 'get-leads',
    );
  }

  // Get lead by ID
  static Future<ApiResponse<Map<String, dynamic>>> getLeadById(
    String id,
  ) async {
    ApiConfig.logRequest('GET', '/leads/$id');

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.get(
        ApiUtils.buildUri('/leads/$id'),
        headers: headers,
      );
      return response;
    }, endpoint: 'get-lead-by-id');
  }

  // Update lead
  static Future<ApiResponse<Map<String, dynamic>>> updateLead(
    String id,
    Map<String, dynamic> leadData,
  ) async {
    ApiConfig.logRequest('PATCH', '/leads/$id', body: leadData);

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.patch(
        ApiUtils.buildUri('/leads/$id'),
        headers: headers,
        body: jsonEncode(leadData),
      );
      return response;
    }, endpoint: 'update-lead');
  }

  // Delete lead
  static Future<ApiResponse<Map<String, dynamic>>> deleteLead(String id) async {
    ApiConfig.logRequest('DELETE', '/leads/$id');

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.delete(
        ApiUtils.buildUri('/leads/$id'),
        headers: headers,
      );
      return response;
    }, endpoint: 'delete-lead');
  }

  // Convert lead to customer
  static Future<ApiResponse<Map<String, dynamic>>> convertLeadToCustomer(
    String id,
    Map<String, dynamic> conversionData,
  ) async {
    ApiConfig.logRequest('PATCH', '/leads/$id/convert', body: conversionData);

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.patch(
        ApiUtils.buildUri('/leads/$id/convert'),
        headers: headers,
        body: jsonEncode(conversionData),
      );
      return response;
    }, endpoint: 'convert-lead');
  }

  // Get leads statistics
  static Future<ApiResponse<Map<String, dynamic>>> getLeadsStats({
    DateTime? fromDate,
    DateTime? toDate,
    String? assignedTo,
  }) async {
    final queryParams = <String, dynamic>{
      if (fromDate != null) 'fromDate': fromDate.toIso8601String(),
      if (toDate != null) 'toDate': toDate.toIso8601String(),
      if (assignedTo != null && assignedTo.isNotEmpty) 'assignedTo': assignedTo,
    };

    ApiConfig.logRequest('GET', '/leads/stats', body: queryParams);

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.get(
        ApiUtils.buildUri('/leads/stats', queryParameters: queryParams),
        headers: headers,
      );
      return response;
    }, endpoint: 'get-leads-stats');
  }

  // Search leads
  static Future<ApiResponse<List<Map<String, dynamic>>>> searchLeads(
    String query,
  ) async {
    ApiConfig.logRequest('GET', '/leads/search', body: {'q': query});

    return ApiUtils.handleRequest<List<Map<String, dynamic>>>(
      () async {
        final headers = await ApiConfig.authHeaders;
        final response = await http.get(
          ApiUtils.buildUri('/leads/search', queryParameters: {'q': query}),
          headers: headers,
        );
        return response;
      },
      fromJson: (data) =>
          (data['results'] as List?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList() ??
          [],
      endpoint: 'search-leads',
    );
  }

  // Assign lead to user
  static Future<ApiResponse<Map<String, dynamic>>> assignLead(
    String id,
    String assignedTo, {
    String? notes,
  }) async {
    final data = {'assignedTo': assignedTo, if (notes != null) 'notes': notes};

    ApiConfig.logRequest('PATCH', '/leads/$id/assign', body: data);

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.patch(
        ApiUtils.buildUri('/leads/$id/assign'),
        headers: headers,
        body: jsonEncode(data),
      );
      return response;
    }, endpoint: 'assign-lead');
  }

  // Update lead status
  static Future<ApiResponse<Map<String, dynamic>>> updateLeadStatus(
    String id,
    String status, {
    String? notes,
  }) async {
    final data = {'status': status, if (notes != null) 'notes': notes};

    ApiConfig.logRequest('PATCH', '/leads/$id/status', body: data);

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.patch(
        ApiUtils.buildUri('/leads/$id/status'),
        headers: headers,
        body: jsonEncode(data),
      );
      return response;
    }, endpoint: 'update-lead-status');
  }

  // Get leads by status
  static Future<ApiResponse<List<Map<String, dynamic>>>> getLeadsByStatus(
    String status,
  ) async {
    ApiConfig.logRequest('GET', '/leads/status/$status');

    return ApiUtils.handleRequest<List<Map<String, dynamic>>>(
      () async {
        final headers = await ApiConfig.authHeaders;
        final response = await http.get(
          ApiUtils.buildUri('/leads/status/$status'),
          headers: headers,
        );
        return response;
      },
      fromJson: (data) =>
          (data['leads'] as List?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList() ??
          [],
      endpoint: 'get-leads-by-status',
    );
  }

  // Get my leads (assigned to current user)
  static Future<ApiResponse<List<Map<String, dynamic>>>> getMyLeads() async {
    ApiConfig.logRequest('GET', '/leads/my');

    return ApiUtils.handleRequest<List<Map<String, dynamic>>>(
      () async {
        final headers = await ApiConfig.authHeaders;
        final response = await http.get(
          ApiUtils.buildUri('/leads/my'),
          headers: headers,
        );
        return response;
      },
      fromJson: (data) =>
          (data['leads'] as List?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList() ??
          [],
      endpoint: 'get-my-leads',
    );
  }

  // Bulk import leads
  static Future<ApiResponse<Map<String, dynamic>>> bulkImportLeads(
    List<Map<String, dynamic>> leadsData,
  ) async {
    ApiConfig.logRequest(
      'POST',
      '/leads/bulk-import',
      body: {'leads': leadsData},
    );

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.post(
        ApiUtils.buildUri('/leads/bulk-import'),
        headers: headers,
        body: jsonEncode({'leads': leadsData}),
      );
      return response;
    }, endpoint: 'bulk-import-leads');
  }

  // Validate phone number (utility method)
  static bool validatePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 10 && digits.length <= 15;
  }

  // Format phone number for display (utility method)
  static String formatPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    return phone;
  }
}
