import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bill_models.dart';

class BillApiService {
  static const String baseUrl = 'https://solar-backend-455t.vercel.app';

  static Future<ApiResponse> fetchBillDetails(String consumerNumber) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/electricity-bill/analyze/$consumerNumber',
      );

      final response = await http
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout. Please try again.');
            },
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ApiResponse.fromJson(jsonData);
      } else {
        // Try to parse error message from response body
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          return ApiResponse(
            success: false,
            message: errorData['message'] ?? 'Failed to fetch bill details.',
          );
        } catch (e) {
          return ApiResponse(
            success: false,
            message: 'Server error. Please try again later.',
          );
        }
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        return ApiResponse(
          success: false,
          message: 'Request timeout. Please check your internet connection.',
        );
      } else if (e.toString().contains('SocketException')) {
        return ApiResponse(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'An error occurred. Please try again.',
        );
      }
    }
  }
}
