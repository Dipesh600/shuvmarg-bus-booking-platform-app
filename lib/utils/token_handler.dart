import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sumarg/views/auth/login_screen.dart';
import 'package:sumarg/utils/global_context.dart';

class TokenHandler {
  static const String _accessTokenKey = 'accessToken';
  static const String _successKey = 'success';
  static const String _roleKey = 'role';

  /// Handle token expiration by showing dialog and redirecting to login
  static Future<void> handleTokenExpiration(
      [BuildContext? context]) async {
    // Clear stored tokens and user data
    await _clearUserData();

    // Use provided context or global context
    final ctx = context ?? GlobalContext.context;

    // Show token expiration dialog
    if (ctx != null && ctx.mounted) {
      AwesomeDialog(
        context: ctx,
        dialogType: DialogType.warning,
        animType: AnimType.bottomSlide,
        title: 'Session Expired',
        desc:
            'Your session has expired. Please login again to continue.',
        btnOkText: 'Login',
        btnOkOnPress: () {
          // Navigate to login screen
          Navigator.pushAndRemoveUntil(
            ctx,
            MaterialPageRoute(
                builder: (context) => const LoginScreen()),
            (route) => false,
          );
        },
        btnOkColor: Colors.blue,
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
      ).show();
    }
  }

  /// Clear all user data from SharedPreferences
  static Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_successKey);
    await prefs.remove(_roleKey);
  }

  /// Check if response indicates token expiration
  static bool isTokenExpired(Map<String, dynamic> response) {
    if (response.containsKey('status') &&
        response.containsKey('message')) {
      final status = response['status'];
      final message =
          response['message']?.toString().toLowerCase() ?? '';

      return status == false &&
          (message.contains('unauthorized') ||
              message.contains('invalid') ||
              message.contains('expired') ||
              message.contains('token'));
    }
    return false;
  }

  /// Check if response indicates token expiration from status code
  static bool isTokenExpiredFromStatusCode(
      int statusCode, String responseBody) {
    if (statusCode == 401) {
      try {
        final response = responseBody.toLowerCase();
        return response.contains('unauthorized') ||
            response.contains('invalid') ||
            response.contains('expired') ||
            response.contains('token');
      } catch (e) {
        return true; // If we can't parse, assume it's token related for 401
      }
    }
    return false;
  }
}
