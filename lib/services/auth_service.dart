import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class AuthService {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userEmailKey = 'user_email';
  static const String _authTokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Get saved auth token
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  // Save login state with complete user data
  static Future<void> saveLoginState({
    required bool isLoggedIn,
    String? email,
    String? token,
    String? userId,
    String? role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
    if (email != null) {
      await prefs.setString(_userEmailKey, email);
    }
    if (token != null) {
      await prefs.setString(_authTokenKey, token);
    }
    if (userId != null) {
      await prefs.setString(_userIdKey, userId);
    }
    if (role != null) {
      await prefs.setString(_userRoleKey, role);
    }
  }

  // Get saved user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Get saved user role
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  // Get saved user email
  static Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Register a new user
  static Future<ApiResponse<Map<String, dynamic>>> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String role = 'SALES_REPRESENTATIVE',
    String department = 'SALES',
    String? phoneNumber,
  }) async {
    ApiConfig.logRequest(
      'POST',
      '/auth/signup',
      body: {
        'username': username,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
        'department': department,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
      },
    );

    return ApiUtils.handleRequest(() async {
      final response = await http.post(
        ApiUtils.buildUri('/auth/signup'),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'role': role,
          'department': department,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
        }),
      );
      return response;
    }, endpoint: 'signup');
  }

  // Sign in user
  static Future<ApiResponse<Map<String, dynamic>>> signIn({
    required String email,
    required String password,
  }) async {
    ApiConfig.logRequest('POST', '/auth/signin', body: {'email': email});

    final result = await ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final response = await http.post(
        ApiUtils.buildUri('/auth/signin'),
        headers: ApiConfig.headers,
        body: jsonEncode({'email': email, 'password': password}),
      );
      return response;
    }, endpoint: 'signin');

    if (result.success && result.data != null) {
      final data = result.data!;
      final token = data['access_token'] as String?;
      final user = data['user'] as Map<String, dynamic>?;

      if (token != null && user != null) {
        await saveLoginState(
          isLoggedIn: true,
          email: email,
          token: token,
          userId: user['id'] as String?,
          role: user['role'] as String?,
        );
      }
    }

    return result;
  }

  // Reset password (Note: API documentation doesn't specify this endpoint, keeping for compatibility)
  static Future<ApiResponse<Map<String, dynamic>>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    ApiConfig.logRequest(
      'POST',
      '/auth/reset-password',
      body: {'email': email},
    );

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final response = await http.post(
        ApiUtils.buildUri('/auth/reset-password'),
        headers: ApiConfig.headers,
        body: jsonEncode({'email': email, 'newPassword': newPassword}),
      );
      return response;
    }, endpoint: 'reset-password');
  }

  // Get user profile
  static Future<ApiResponse<Map<String, dynamic>>> getProfile() async {
    ApiConfig.logRequest('GET', '/auth/profile');

    return ApiUtils.handleRequest<Map<String, dynamic>>(() async {
      final headers = await ApiConfig.authHeaders;
      final response = await http.get(
        ApiUtils.buildUri('/auth/profile'),
        headers: headers,
      );
      return response;
    }, endpoint: 'profile');
  }

  // Sign out user
  static Future<ApiResponse<Map<String, dynamic>>> signOut() async {
    ApiConfig.logRequest('POST', '/auth/signout');

    try {
      final token = await getAuthToken();
      if (token != null) {
        await ApiUtils.handleRequest<Map<String, dynamic>>(() async {
          final headers = await ApiConfig.authHeaders;
          final response = await http.post(
            ApiUtils.buildUri('/auth/signout'),
            headers: headers,
          );
          return response;
        }, endpoint: 'signout');
      }

      await clearAuthData();
      return ApiResponse<Map<String, dynamic>>.success({
        'message': 'Signed out successfully',
      });
    } catch (e) {
      await clearAuthData(); // Clear local data even if API call fails
      return ApiResponse<Map<String, dynamic>>.success({
        'message': 'Signed out locally',
      });
    }
  }

  // Login user (legacy method for backward compatibility)
  static Future<void> login(String email) async {
    await saveLoginState(isLoggedIn: true, email: email);
  }

  // Logout user (legacy method for backward compatibility)
  static Future<void> logout() async {
    await clearAuthData();
  }

  // Clear all auth data
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_authTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userRoleKey);
  }
}
