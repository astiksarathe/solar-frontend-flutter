import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'auth_service.dart';
import 'navigation_service.dart';

class ApiConfig {
  static const String baseUrl = 'https://solar-backend-tan.vercel.app';
  static const String androidEmulatorUrl = 'https://solar-backend-tan.vercel.app';
  static const String prodUrl = 'https://solar-backend-tan.vercel.app';
  static const String stagingUrl = 'https://solar-backend-tan.vercel.app';

  // Use appropriate URL based on platform
  static String get apiBaseUrl {
    if (kDebugMode) {
      // In debug mode, check if running on Android emulator
      try {
        if (Platform.isAndroid) {
          return androidEmulatorUrl;
        }
      } catch (e) {
        // Platform not available in web
      }
      return baseUrl;
    }
    return prodUrl;
  }

  // Common headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers with authentication
  static Future<Map<String, String>> get authHeaders async {
    final token = await AuthService.getAuthToken();
    final baseHeaders = headers;
    if (token != null) {
      baseHeaders['Authorization'] = 'Bearer $token';
    }
    return baseHeaders;
  }

  // Request timeout duration
  static const Duration requestTimeout = Duration(seconds: 30);

  // Logging utility
  static void logRequest(
    String method,
    String url, {
    Map<String, dynamic>? body,
  }) {
    if (kDebugMode) {
      debugPrint('🚀 API Request:');
      debugPrint('📍 $method $url');
      if (body != null) {
        debugPrint('📄 Body: ${jsonEncode(body)}');
      }
      debugPrint('⏰ Timestamp: ${DateTime.now()}');
    }
  }

  static void logResponse(http.Response response, {String? endpoint}) {
    if (kDebugMode) {
      debugPrint('📨 API Response${endpoint != null ? ' ($endpoint)' : ''}:');
      debugPrint('🔢 Status Code: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.body}');
      debugPrint('📏 Body Length: ${response.body.length} characters');
    }
  }

  static void logError(dynamic error, {String? endpoint}) {
    if (kDebugMode) {
      debugPrint('💥 API Error${endpoint != null ? ' ($endpoint)' : ''}:');
      debugPrint('❌ Error: $error');
      debugPrint('🔍 Error type: ${error.runtimeType}');
    }
  }
}

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.success(T? data, {String? message}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: 200,
    );
  }

  factory ApiResponse.error(
    String message, {
    int? statusCode,
    Map<String, dynamic>? error,
  }) {
    return ApiResponse(
      success: false,
      message: message,
      error: error,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.fromResponse(
    http.Response response, {
    T Function(Map<String, dynamic>)? fromJson,
  }) {
    try {
      final Map<String, dynamic> jsonData = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        T? data;
        if (fromJson != null) {
          data = fromJson(jsonData);
        } else if (jsonData.containsKey('data')) {
          data = jsonData['data'] as T?;
        } else {
          data = jsonData as T?;
        }

        return ApiResponse<T>.success(
          data,
          message: jsonData['message'] as String?,
        );
      } else {
        return ApiResponse<T>.error(
          jsonData['message'] as String? ?? 'Request failed',
          statusCode: response.statusCode,
          error: jsonData,
        );
      }
    } catch (e) {
      return ApiResponse<T>.error(
        'Failed to parse response: $e',
        statusCode: response.statusCode,
      );
    }
  }
}

// Pagination response wrapper
class PaginatedResponse<T> {
  final List<T> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginatedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse(
      data:
          (json['data'] as List?)
              ?.map((item) => fromJsonT(item as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 10,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}

// Common API utility methods
class ApiUtils {
  static Future<ApiResponse<T>> handleRequest<T>(
    Future<http.Response> Function() request, {
    T Function(Map<String, dynamic>)? fromJson,
    String? endpoint,
  }) async {
    try {
      final response = await request().timeout(ApiConfig.requestTimeout);
      ApiConfig.logResponse(response, endpoint: endpoint);

      // Handle 401 Unauthorized responses
      if (response.statusCode == 401) {
        await handleUnauthorized();
        return ApiResponse<T>.error(
          'Session expired. Please login again.',
          statusCode: 401,
        );
      }

      return ApiResponse<T>.fromResponse(response, fromJson: fromJson);
    } catch (e) {
      ApiConfig.logError(e, endpoint: endpoint);

      if (e.toString().contains('TimeoutException')) {
        return ApiResponse<T>.error('Request timeout. Please try again.');
      } else if (e.toString().contains('SocketException')) {
        return ApiResponse<T>.error(
          'No internet connection. Please check your network.',
        );
      } else {
        return ApiResponse<T>.error('An error occurred: $e');
      }
    }
  }

  /// Handle unauthorized responses - clear auth data and redirect to login
  static Future<void> handleUnauthorized() async {
    try {
      // Clear authentication data
      await AuthService.clearAuthData();

      // Show message to user
      NavigationService.showSnackBar(
        'Your session has expired. Please login again.',
        isError: true,
      );

      // Navigate to login screen
      await NavigationService.navigateToLogin();
    } catch (e) {
      ApiConfig.logError('Error handling unauthorized response: $e');
    }
  }

  static Uri buildUri(String path, {Map<String, dynamic>? queryParameters}) {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}$path');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(
        queryParameters: queryParameters.map(
          (key, value) => MapEntry(key, value?.toString()),
        ),
      );
    }
    return uri;
  }
}
