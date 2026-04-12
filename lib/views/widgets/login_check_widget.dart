import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sumarg/controllers/auth_controller/login_provider.dart';
import 'package:sumarg/utils/navigation_service.dart';
import 'package:sumarg/views/auth/login_screen.dart';

/// Widget to handle login checks and redirects
class LoginCheckWidget extends StatelessWidget {
  final Widget child;
  final String redirectType;
  final Map<String, dynamic>? redirectData;
  final String? fallbackRoute;

  const LoginCheckWidget({
    super.key,
    required this.child,
    required this.redirectType,
    this.redirectData,
    this.fallbackRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginProvider>(
      builder: (context, loginProvider, _) {
        if (loginProvider.isLoggedIn) {
          return child;
        } else {
          // Store redirect information before going to login
          _storeRedirectInfo();

          // Navigate to login screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          });

          // Show loading or placeholder while redirecting
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  void _storeRedirectInfo() {
    NavigationService.storeRedirectData(
      redirectType: redirectType,
      data: redirectData,
    );
  }
}

/// Extension to add login check functionality to any widget
extension LoginCheckExtension on Widget {
  Widget requireLogin({
    required String redirectType,
    Map<String, dynamic>? redirectData,
    String? fallbackRoute,
  }) {
    return LoginCheckWidget(
      redirectType: redirectType,
      redirectData: redirectData,
      fallbackRoute: fallbackRoute,
      child: this,
    );
  }
}

/// Helper class for common login check scenarios
class LoginCheckHelper {
  /// Check if user is logged in and redirect to login if not
  static Future<bool> checkLoginAndRedirect(
    BuildContext context, {
    required String redirectType,
    Map<String, dynamic>? redirectData,
  }) async {
    final loginProvider =
        Provider.of<LoginProvider>(context, listen: false);

    if (loginProvider.isLoggedIn) {
      return true;
    } else {
      // Store redirect information
      await NavigationService.storeRedirectData(
        redirectType: redirectType,
        data: redirectData,
      );

      // Navigate to login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );

      return false;
    }
  }

  /// Check login status without redirecting
  static bool isLoggedIn(BuildContext context) {
    return Provider.of<LoginProvider>(context, listen: false)
        .isLoggedIn;
  }

  /// Store redirect data for later use
  static Future<void> storeRedirect({
    required String redirectType,
    Map<String, dynamic>? redirectData,
  }) async {
    await NavigationService.storeRedirectData(
      redirectType: redirectType,
      data: redirectData,
    );
  }
}
