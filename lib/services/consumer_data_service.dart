import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ConsumerDataService {
  // Create consumer data
  static Future<ApiResponse<Map<String, dynamic>>> createConsumerData(
    Map<String, dynamic> consumerData,
  ) async {
    ApiConfig.logRequest('POST', '/consumer-data', body: consumerData);

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.post(
        ApiUtils.buildUri('/consumer-data'),
        headers: headers,
        body: jsonEncode(consumerData),
      );
      return response;
    }, endpoint: 'create-consumer-data');
  }

  // Get all consumer data with filters and pagination
  static Future<ApiResponse<PaginatedResponse<Map<String, dynamic>>>>
  getAllConsumerData({
    int page = 1,
    int limit = 10,
    String? interestLevel,
    String? status,
    String? propertyType,
    String? leadSource,
    String? search,
    String? sortBy,
    String? sortOrder,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (interestLevel != null && interestLevel.isNotEmpty)
        'interestLevel': interestLevel,
      if (status != null && status.isNotEmpty) 'status': status,
      if (propertyType != null && propertyType.isNotEmpty)
        'propertyType': propertyType,
      if (leadSource != null && leadSource.isNotEmpty) 'leadSource': leadSource,
      if (search != null && search.isNotEmpty) 'search': search,
      if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
      if (sortOrder != null && sortOrder.isNotEmpty) 'sortOrder': sortOrder,
      if (fromDate != null) 'fromDate': fromDate.toIso8601String(),
      if (toDate != null) 'toDate': toDate.toIso8601String(),
    };

    ApiConfig.logRequest('GET', '/consumer-data', body: queryParams);

    return ApiUtils.handleRequest<PaginatedResponse<Map<String, dynamic>>>(
      () async {
        final headers = await ApiConfig.authHeaders;
        final uri = ApiUtils.buildUri(
          '/consumer-data',
          queryParameters: queryParams,
        );

        // Console logging
        print('🔍 [ConsumerDataService] Making request to: $uri');
        print('📋 [ConsumerDataService] Query params: $queryParams');
        print('🔑 [ConsumerDataService] Headers: $headers');

        final response = await http.get(uri, headers: headers);

        // Log response details
        print(
          '📊 [ConsumerDataService] Response status: ${response.statusCode}',
        );
        print(
          '📄 [ConsumerDataService] Response body length: ${response.body.length}',
        );
        print('💾 [ConsumerDataService] Response body: ${response.body}');

        return response;
      },
      fromJson: (data) {
        print('🔄 [ConsumerDataService] Parsing response data...');
        print('📦 [ConsumerDataService] Raw data keys: ${data.keys.toList()}');
        final result = PaginatedResponse.fromJson(data, (item) => item);
        print(
          '✅ [ConsumerDataService] Parsed ${result.data.length} items, total: ${result.total}',
        );
        return result;
      },
      endpoint: 'get-consumer-data',
    );
  }

  // Get consumer data by ID
  static Future<ApiResponse<Map<String, dynamic>>> getConsumerDataById(
    String id,
  ) async {
    ApiConfig.logRequest('GET', '/consumer-data/$id');

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.get(
        ApiUtils.buildUri('/consumer-data/$id'),
        headers: headers,
      );
      return response;
    }, endpoint: 'get-consumer-data-by-id');
  }

  // Update consumer data
  static Future<ApiResponse<Map<String, dynamic>>> updateConsumerData(
    String id,
    Map<String, dynamic> consumerData,
  ) async {
    ApiConfig.logRequest('PATCH', '/consumer-data/$id', body: consumerData);

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.patch(
        ApiUtils.buildUri('/consumer-data/$id'),
        headers: headers,
        body: jsonEncode(consumerData),
      );
      return response;
    }, endpoint: 'update-consumer-data');
  }

  // Delete consumer data
  static Future<ApiResponse<Map<String, dynamic>>> deleteConsumerData(
    String id,
  ) async {
    ApiConfig.logRequest('DELETE', '/consumer-data/$id');

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.delete(
        ApiUtils.buildUri('/consumer-data/$id'),
        headers: headers,
      );
      return response;
    }, endpoint: 'delete-consumer-data');
  }

  // Search consumer data
  static Future<ApiResponse<List<Map<String, dynamic>>>> searchConsumerData(
    String query,
  ) async {
    ApiConfig.logRequest('GET', '/consumer-data/search', body: {'q': query});

    return ApiUtils.handleRequest<List<Map<String, dynamic>>>(
      () async {
        final headers = await ApiConfig.authHeaders;
        final response = await http.get(
          ApiUtils.buildUri(
            '/consumer-data/search',
            queryParameters: {'q': query},
          ),
          headers: headers,
        );
        return response;
      },
      fromJson: (data) =>
          (data['results'] as List?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList() ??
          [],
      endpoint: 'search-consumer-data',
    );
  }

  // Get consumer data statistics
  static Future<ApiResponse<Map<String, dynamic>>> getConsumerDataStats({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final queryParams = <String, dynamic>{
      if (fromDate != null) 'fromDate': fromDate.toIso8601String(),
      if (toDate != null) 'toDate': toDate.toIso8601String(),
    };

    ApiConfig.logRequest('GET', '/consumer-data/stats', body: queryParams);

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.get(
        ApiUtils.buildUri('/consumer-data/stats', queryParameters: queryParams),
        headers: headers,
      );
      return response;
    }, endpoint: 'get-consumer-data-stats');
  }

  // Get consumer data by phone number
  static Future<ApiResponse<Map<String, dynamic>>> getConsumerDataByPhone(
    String phoneNumber,
  ) async {
    ApiConfig.logRequest('GET', '/consumer-data/phone/$phoneNumber');

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.get(
        ApiUtils.buildUri('/consumer-data/phone/$phoneNumber'),
        headers: headers,
      );
      return response;
    }, endpoint: 'get-consumer-data-by-phone');
  }

  // Get consumer data by email
  static Future<ApiResponse<Map<String, dynamic>>> getConsumerDataByEmail(
    String email,
  ) async {
    ApiConfig.logRequest('GET', '/consumer-data/email/$email');

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.get(
        ApiUtils.buildUri('/consumer-data/email/$email'),
        headers: headers,
      );
      return response;
    }, endpoint: 'get-consumer-data-by-email');
  }

  // Update consumer status
  static Future<ApiResponse<Map<String, dynamic>>> updateConsumerStatus(
    String id,
    String status, {
    String? notes,
  }) async {
    final data = {'status': status, if (notes != null) 'notes': notes};

    ApiConfig.logRequest('PATCH', '/consumer-data/$id/status', body: data);

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.patch(
        ApiUtils.buildUri('/consumer-data/$id/status'),
        headers: headers,
        body: jsonEncode(data),
      );
      return response;
    }, endpoint: 'update-consumer-status');
  }

  // Bulk import consumer data
  static Future<ApiResponse<Map<String, dynamic>>> bulkImportConsumerData(
    List<Map<String, dynamic>> consumerDataList,
  ) async {
    ApiConfig.logRequest(
      'POST',
      '/consumer-data/bulk-import',
      body: {'data': consumerDataList},
    );

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.post(
        ApiUtils.buildUri('/consumer-data/bulk-import'),
        headers: headers,
        body: jsonEncode({'data': consumerDataList}),
      );
      return response;
    }, endpoint: 'bulk-import-consumer-data');
  }
}

// Consumer Data enums
enum PropertyType {
  residential('RESIDENTIAL'),
  commercial('COMMERCIAL'),
  industrial('INDUSTRIAL'),
  agricultural('AGRICULTURAL');

  const PropertyType(this.value);
  final String value;

  static PropertyType? fromString(String? value) {
    if (value == null) return null;
    for (PropertyType type in PropertyType.values) {
      if (type.value == value) return type;
    }
    return null;
  }
}

enum RoofType {
  shingle('SHINGLE'),
  tile('TILE'),
  metal('METAL'),
  flat('FLAT'),
  concrete('CONCRETE'),
  asbestos('ASBESTOS');

  const RoofType(this.value);
  final String value;

  static RoofType? fromString(String? value) {
    if (value == null) return null;
    for (RoofType type in RoofType.values) {
      if (type.value == value) return type;
    }
    return null;
  }
}

enum LeadSource {
  website('WEBSITE'),
  referral('REFERRAL'),
  advertisement('ADVERTISEMENT'),
  socialMedia('SOCIAL_MEDIA'),
  coldCall('COLD_CALL'),
  exhibition('EXHIBITION'),
  partner('PARTNER'),
  other('OTHER');

  const LeadSource(this.value);
  final String value;

  static LeadSource? fromString(String? value) {
    if (value == null) return null;
    for (LeadSource source in LeadSource.values) {
      if (source.value == value) return source;
    }
    return null;
  }
}

enum InterestLevel {
  low('LOW'),
  medium('MEDIUM'),
  high('HIGH'),
  urgent('URGENT');

  const InterestLevel(this.value);
  final String value;

  static InterestLevel? fromString(String? value) {
    if (value == null) return null;
    for (InterestLevel level in InterestLevel.values) {
      if (level.value == value) return level;
    }
    return null;
  }
}

enum ConsumerStatus {
  newStatus('NEW'),
  contacted('CONTACTED'),
  qualified('QUALIFIED'),
  proposal('PROPOSAL'),
  negotiation('NEGOTIATION'),
  closed('CLOSED'),
  lost('LOST');

  const ConsumerStatus(this.value);
  final String value;

  static ConsumerStatus? fromString(String? value) {
    if (value == null) return null;
    for (ConsumerStatus status in ConsumerStatus.values) {
      if (status.value == value) return status;
    }
    return null;
  }
}
