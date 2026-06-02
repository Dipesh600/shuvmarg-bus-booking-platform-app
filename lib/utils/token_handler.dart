import 'dart:convert';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sumarg/views/auth/login_screen.dart';
import 'package:sumarg/utils/global_context.dart';
import 'package:sumarg/utils/app_theme.dart';
import 'package:sumarg/utils/api_endpoints.dart';

class TokenHandler {
  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _successKey = 'success';
  static const String _roleKey = 'role';

  /// Completer to handle concurrent refresh attempts
  static Completer<bool>? _refreshCompleter;

  /// Attempt to silently refresh the access token using the stored refresh token.
  /// Returns `true` if refresh succeeded (new tokens saved), `false` otherwise.
  static Future<bool> attemptSilentRefresh() async {
    // If a refresh is already in progress, wait for it to complete
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedRefreshToken = prefs.getString(_refreshTokenKey);

      if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
        debugPrint('[TokenHandler] No refresh token stored — cannot refresh.');
        return false;
      }

      debugPrint('[TokenHandler] Attempting silent token refresh...');

      final response = await http.post(
        Uri.parse(ApiEndpoints.refreshToken),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refreshToken': storedRefreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newAccessToken = data['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          await prefs.setString(_accessTokenKey, newAccessToken);
          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            await prefs.setString(_refreshTokenKey, newRefreshToken);
          }
          debugPrint('[TokenHandler] Silent refresh succeeded.');
          _refreshCompleter?.complete(true);
          _refreshCompleter = null;
          return true;
        }
      }

      debugPrint(
          '[TokenHandler] Silent refresh failed — status ${response.statusCode}');
      _refreshCompleter?.complete(false);
      _refreshCompleter = null;
      return false;
    } catch (e) {
      debugPrint('[TokenHandler] Silent refresh error: $e');
      _refreshCompleter?.complete(false);
      _refreshCompleter = null;
      return false;
    }
  }

  /// Handle token expiration by showing a beautifully redesigned premium dialog and redirecting to login.
  /// This is only called when the refresh token itself is invalid/expired.
  static Future<void> handleTokenExpiration([BuildContext? context]) async {
    // Clear stored tokens and user data
    await _clearUserData();

    // Use provided context or global context
    final ctx = context ?? GlobalContext.context;

    // Show token expiration dialog
    if (ctx != null && ctx.mounted) {
      HapticFeedback.heavyImpact();

      showGeneralDialog(
        context: ctx,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.6),
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
        transitionBuilder: (context, anim1, anim2, child) {
          final curveValue = Curves.easeInOutBack.transform(anim1.value);
          return Transform.scale(
            scale: 0.85 + (curveValue * 0.15),
            child: Opacity(
              opacity: anim1.value,
              child: WillPopScope(
                onWillPop: () async => false, // Prevent dismissing by back button
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBg, // rgba(0, 86, 78, 0.88)
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppTheme.stroke, width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withOpacity(0.35),
                                  blurRadius: 40,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ── Glowing Premium Warning Icon ──
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentLime.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.accentLime.withOpacity(0.4),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.accentLime.withOpacity(0.1),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.hourglass_disabled_rounded,
                                      color: AppTheme.accentLime,
                                      size: 36,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // ── Title ──
                                const Text(
                                  'Session Expired',
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),

                                // ── Description ──
                                const Text(
                                  'Your session has expired. Please login again to continue.',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),

                                // ── CTA Button ──
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.mediumImpact();
                                    Navigator.pushAndRemoveUntil(
                                      ctx,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentLime,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.accentLime.withOpacity(0.3),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Login Again',
                                        style: TextStyle(
                                          color: AppTheme.primaryDark,
                                          fontFamily: AppTheme.fontFamily,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  }

  /// Clear all user data from SharedPreferences
  static Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_successKey);
    await prefs.remove(_roleKey);
  }

  /// Check if response indicates token expiration
  static bool isTokenExpired(Map<String, dynamic> response) {
    if (response.containsKey('status') && response.containsKey('message')) {
      final status = response['status'];
      final message = response['message']?.toString().toLowerCase() ?? '';

      return status == false &&
          (message.contains('unauthorized') ||
              message.contains('invalid') ||
              message.contains('expired') ||
              message.contains('token'));
    }
    return false;
  }

  /// Check if response indicates token expiration from status code
  static bool isTokenExpiredFromStatusCode(int statusCode, String responseBody) {
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
