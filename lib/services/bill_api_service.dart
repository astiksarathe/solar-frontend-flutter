import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/bill_models.dart';

class BillApiService {
  static const String baseUrl = 'https://solar-backend-455t.vercel.app';

  static Future<ApiResponse> fetchBillDetails(String consumerNumber) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/electricity-bill/analyze/$consumerNumber',
      );

      // Log the request
      debugPrint('🚀 API Request:');
      debugPrint('📍 URL: $uri');
      debugPrint('📊 Consumer Number: $consumerNumber');
      debugPrint('⏰ Timestamp: ${DateTime.now()}');

      final response = await http
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              debugPrint('⏱️ Request timeout after 30 seconds');
              throw Exception('Request timeout. Please try again.');
            },
          );

      // Log the response
      debugPrint('📨 API Response:');
      debugPrint('🔢 Status Code: ${response.statusCode}');
      debugPrint('📋 Headers: ${response.headers}');
      debugPrint('📄 Response Body: ${response.body}');
      debugPrint('📏 Body Length: ${response.body.length} characters');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        debugPrint('✅ Success: JSON parsed successfully');
        debugPrint('🔍 JSON Keys: ${jsonData.keys.toList()}');

        final apiResponse = ApiResponse.fromJson(jsonData);
        debugPrint('🎯 API Response Object Created: ${apiResponse.success}');
        return apiResponse;
      } else {
        debugPrint('❌ Error Response - Status: ${response.statusCode}');
        // Try to parse error message from response body
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          debugPrint('📝 Error Data: $errorData');
          return ApiResponse(
            success: false,
            message: errorData['message'] ?? 'Failed to fetch bill details.',
          );
        } catch (e) {
          debugPrint('💥 Failed to parse error response: $e');
          return ApiResponse(
            success: false,
            message: 'Server error. Please try again later.',
          );
        }
      }
    } catch (e) {
      debugPrint('💥 Exception caught: $e');
      debugPrint('🔍 Exception type: ${e.runtimeType}');
      debugPrint('📍 Stack trace: ${StackTrace.current}');

      if (e.toString().contains('timeout')) {
        debugPrint('⏱️ Timeout error detected');
        return ApiResponse(
          success: false,
          message: 'Request timeout. Please check your internet connection.',
        );
      } else if (e.toString().contains('SocketException')) {
        debugPrint('🌐 Network error detected');
        return ApiResponse(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      } else {
        debugPrint('❓ Unknown error detected');
        return ApiResponse(
          success: false,
          message: 'An error occurred. Please try again.',
        );
      }
    }
  }
}
