import 'package:flutter/foundation.dart';
import 'api_config.dart';
import 'auth_service.dart';

/// Utility class for testing authentication flows and handling edge cases
class AuthTestUtil {
  /// Simulate an unauthorized response for testing purposes
  /// This can be used during development to test the automatic logout functionality
  static Future<void> simulateUnauthorizedResponse() async {
    if (kDebugMode) {
      debugPrint(
        '🧪 [AuthTestUtil] Simulating unauthorized response for testing...',
      );

      // Clear auth data
      await AuthService.clearAuthData();

      // Trigger the unauthorized handler
      await ApiUtils.handleUnauthorized();

      debugPrint('✅ [AuthTestUtil] Unauthorized simulation completed');
    }
  }

  /// Check if the current user session is valid
  /// Returns true if user has valid session, false otherwise
  static Future<bool> validateSession() async {
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      final token = await AuthService.getAuthToken();

      if (!isLoggedIn || token == null) {
        debugPrint(
          '❌ [AuthTestUtil] Session validation failed - no token or not logged in',
        );
        return false;
      }

      // Here you could add additional token validation logic
      // For example, checking token expiration, format, etc.

      debugPrint('✅ [AuthTestUtil] Session validation passed');
      return true;
    } catch (e) {
      debugPrint('💥 [AuthTestUtil] Error validating session: $e');
      return false;
    }
  }

  /// Force logout and redirect to login screen
  /// Useful for manual logout or when session becomes invalid
  static Future<void> forceLogout({String? reason}) async {
    debugPrint(
      '🚪 [AuthTestUtil] Force logout triggered${reason != null ? ' - Reason: $reason' : ''}',
    );

    try {
      // Clear all auth data
      await AuthService.clearAuthData();

      // Trigger unauthorized handler (which includes navigation)
      await ApiUtils.handleUnauthorized();

      debugPrint('✅ [AuthTestUtil] Force logout completed');
    } catch (e) {
      debugPrint('💥 [AuthTestUtil] Error during force logout: $e');
    }
  }
}
