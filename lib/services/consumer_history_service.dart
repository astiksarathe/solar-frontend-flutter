import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ConsumerHistoryService {
  // Create consumer history entry
  static Future<ApiResponse<Map<String, dynamic>>> createConsumerHistory(
    Map<String, dynamic> historyData,
  ) async {
    ApiConfig.logRequest('POST', '/consumer-history', body: historyData);

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.post(
        ApiUtils.buildUri('/consumer-history'),
        headers: headers,
        body: jsonEncode(historyData),
      );
      return response;
    }, endpoint: 'create-consumer-history');
  }

  // Get all consumer history with filters and pagination
  static Future<ApiResponse<PaginatedResponse<Map<String, dynamic>>>>
  getAllConsumerHistory({
    int page = 1,
    int limit = 10,
    String? status,
    String? assignedTo,
    String? interactionType,
    String? priority,
    String? consumerId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (status != null && status.isNotEmpty) 'status': status,
      if (assignedTo != null && assignedTo.isNotEmpty) 'assignedTo': assignedTo,
      if (interactionType != null && interactionType.isNotEmpty)
        'interactionType': interactionType,
      if (priority != null && priority.isNotEmpty) 'priority': priority,
      if (consumerId != null && consumerId.isNotEmpty) 'consumerId': consumerId,
      if (fromDate != null) 'fromDate': fromDate.toIso8601String(),
      if (toDate != null) 'toDate': toDate.toIso8601String(),
    };

    ApiConfig.logRequest('GET', '/consumer-history', body: queryParams);

    return ApiUtils.handleRequest<PaginatedResponse<Map<String, dynamic>>>(
      () async {
        final headers = await ApiConfig.authHeaders;
        final response = await http.get(
          ApiUtils.buildUri('/consumer-history', queryParameters: queryParams),
          headers: headers,
        );
        return response;
      },
      fromJson: (data) => PaginatedResponse.fromJson(data, (item) => item),
      endpoint: 'get-consumer-history',
    );
  }

  // Get consumer history by ID
  static Future<ApiResponse<Map<String, dynamic>>> getConsumerHistoryById(
    String id,
  ) async {
    ApiConfig.logRequest('GET', '/consumer-history/$id');

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.get(
        ApiUtils.buildUri('/consumer-history/$id'),
        headers: headers,
      );
      return response;
    }, endpoint: 'get-consumer-history-by-id');
  }

  // Get consumer history by consumer ID
  static Future<ApiResponse<List<Map<String, dynamic>>>>
  getConsumerHistoryByConsumerId(String consumerId) async {
    ApiConfig.logRequest('GET', '/consumer-history/consumer/$consumerId');

    return ApiUtils.handleRequest<List<Map<String, dynamic>>>(
      () async {
        final headers = await ApiConfig.authHeaders;
        final response = await http.get(
          ApiUtils.buildUri('/consumer-history/consumer/$consumerId'),
          headers: headers,
        );
        return response;
      },
      fromJson: (data) =>
          (data['data'] as List?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList() ??
          [],
      endpoint: 'get-consumer-history-by-consumer',
    );
  }

  // Update consumer history
  static Future<ApiResponse<Map<String, dynamic>>> updateConsumerHistory(
    String id,
    Map<String, dynamic> historyData,
  ) async {
    ApiConfig.logRequest('PATCH', '/consumer-history/$id', body: historyData);

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.patch(
        ApiUtils.buildUri('/consumer-history/$id'),
        headers: headers,
        body: jsonEncode(historyData),
      );
      return response;
    }, endpoint: 'update-consumer-history');
  }

  // Delete consumer history
  static Future<ApiResponse<Map<String, dynamic>>> deleteConsumerHistory(
    String id,
  ) async {
    ApiConfig.logRequest('DELETE', '/consumer-history/$id');

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.delete(
        ApiUtils.buildUri('/consumer-history/$id'),
        headers: headers,
      );
      return response;
    }, endpoint: 'delete-consumer-history');
  }

  // Complete interaction
  static Future<ApiResponse<Map<String, dynamic>>> completeInteraction(
    String id,
    Map<String, dynamic> completionData,
  ) async {
    ApiConfig.logRequest(
      'PATCH',
      '/consumer-history/$id/complete',
      body: completionData,
    );

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.patch(
        ApiUtils.buildUri('/consumer-history/$id/complete'),
        headers: headers,
        body: jsonEncode(completionData),
      );
      return response;
    }, endpoint: 'complete-interaction');
  }

  // Get interaction statistics
  static Future<ApiResponse<Map<String, dynamic>>> getInteractionStats({
    DateTime? fromDate,
    DateTime? toDate,
    String? assignedTo,
  }) async {
    final queryParams = <String, dynamic>{
      if (fromDate != null) 'fromDate': fromDate.toIso8601String(),
      if (toDate != null) 'toDate': toDate.toIso8601String(),
      if (assignedTo != null && assignedTo.isNotEmpty) 'assignedTo': assignedTo,
    };

    ApiConfig.logRequest('GET', '/consumer-history/stats', body: queryParams);

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.get(
        ApiUtils.buildUri(
          '/consumer-history/stats',
          queryParameters: queryParams,
        ),
        headers: headers,
      );
      return response;
    }, endpoint: 'get-interaction-stats');
  }

  // Schedule interaction
  static Future<ApiResponse<Map<String, dynamic>>> scheduleInteraction(
    Map<String, dynamic> interactionData,
  ) async {
    ApiConfig.logRequest(
      'POST',
      '/consumer-history/schedule',
      body: interactionData,
    );

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.post(
        ApiUtils.buildUri('/consumer-history/schedule'),
        headers: headers,
        body: jsonEncode(interactionData),
      );
      return response;
    }, endpoint: 'schedule-interaction');
  }

  // Reschedule interaction
  static Future<ApiResponse<Map<String, dynamic>>> rescheduleInteraction(
    String id,
    DateTime newScheduledAt, {
    String? reason,
  }) async {
    final data = {
      'scheduledAt': newScheduledAt.toIso8601String(),
      if (reason != null) 'reason': reason,
    };

    ApiConfig.logRequest(
      'PATCH',
      '/consumer-history/$id/reschedule',
      body: data,
    );

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.patch(
        ApiUtils.buildUri('/consumer-history/$id/reschedule'),
        headers: headers,
        body: jsonEncode(data),
      );
      return response;
    }, endpoint: 'reschedule-interaction');
  }

  // Cancel interaction
  static Future<ApiResponse<Map<String, dynamic>>> cancelInteraction(
    String id, {
    String? reason,
  }) async {
    final data = {'status': 'CANCELLED', if (reason != null) 'reason': reason};

    ApiConfig.logRequest('PATCH', '/consumer-history/$id/cancel', body: data);

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.patch(
        ApiUtils.buildUri('/consumer-history/$id/cancel'),
        headers: headers,
        body: jsonEncode(data),
      );
      return response;
    }, endpoint: 'cancel-interaction');
  }

  // Get upcoming interactions
  static Future<ApiResponse<List<Map<String, dynamic>>>>
  getUpcomingInteractions({String? assignedTo, int? days = 7}) async {
    final queryParams = <String, dynamic>{
      if (assignedTo != null && assignedTo.isNotEmpty) 'assignedTo': assignedTo,
      if (days != null) 'days': days,
    };

    ApiConfig.logRequest(
      'GET',
      '/consumer-history/upcoming',
      body: queryParams,
    );

    return ApiUtils.handleRequest<List<Map<String, dynamic>>>(
      () async {
        final headers = await ApiConfig.authHeaders;
        final response = await http.get(
          ApiUtils.buildUri(
            '/consumer-history/upcoming',
            queryParameters: queryParams,
          ),
          headers: headers,
        );
        return response;
      },
      fromJson: (data) =>
          (data['interactions'] as List?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList() ??
          [],
      endpoint: 'get-upcoming-interactions',
    );
  }

  // Get overdue interactions
  static Future<ApiResponse<List<Map<String, dynamic>>>>
  getOverdueInteractions({String? assignedTo}) async {
    final queryParams = <String, dynamic>{
      if (assignedTo != null && assignedTo.isNotEmpty) 'assignedTo': assignedTo,
    };

    ApiConfig.logRequest('GET', '/consumer-history/overdue', body: queryParams);

    return ApiUtils.handleRequest<List<Map<String, dynamic>>>(
      () async {
        final headers = await ApiConfig.authHeaders;
        final response = await http.get(
          ApiUtils.buildUri(
            '/consumer-history/overdue',
            queryParameters: queryParams,
          ),
          headers: headers,
        );
        return response;
      },
      fromJson: (data) =>
          (data['interactions'] as List?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList() ??
          [],
      endpoint: 'get-overdue-interactions',
    );
  }
}

// Consumer History enums
enum InteractionType {
  phoneCall('PHONE_CALL'),
  email('EMAIL'),
  siteVisit('SITE_VISIT'),
  meeting('MEETING'),
  followUp('FOLLOW_UP'),
  documentation('DOCUMENTATION'),
  technical('TECHNICAL'),
  other('OTHER');

  const InteractionType(this.value);
  final String value;

  static InteractionType? fromString(String? value) {
    if (value == null) return null;
    for (InteractionType type in InteractionType.values) {
      if (type.value == value) return type;
    }
    return null;
  }
}

enum InteractionStatus {
  pending('PENDING'),
  inProgress('IN_PROGRESS'),
  completed('COMPLETED'),
  cancelled('CANCELLED'),
  rescheduled('RESCHEDULED');

  const InteractionStatus(this.value);
  final String value;

  static InteractionStatus? fromString(String? value) {
    if (value == null) return null;
    for (InteractionStatus status in InteractionStatus.values) {
      if (status.value == value) return status;
    }
    return null;
  }
}

enum InteractionPriority {
  low('LOW'),
  medium('MEDIUM'),
  high('HIGH'),
  urgent('URGENT');

  const InteractionPriority(this.value);
  final String value;

  static InteractionPriority? fromString(String? value) {
    if (value == null) return null;
    for (InteractionPriority priority in InteractionPriority.values) {
      if (priority.value == value) return priority;
    }
    return null;
  }
}
