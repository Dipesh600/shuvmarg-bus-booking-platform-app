import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller/login_provider.dart';
import '../controllers/seatas_controller/seats_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/app_state_provider.dart';
import '../providers/ticket_provider.dart';

/// Helper class for easy provider access throughout the app
class AppProviders {
  static LoginProvider loginProvider(BuildContext context) {
    return Provider.of<LoginProvider>(context, listen: false);
  }

  static NotificationProvider notificationProvider(
      BuildContext context) {
    return Provider.of<NotificationProvider>(context, listen: false);
  }

  static SeatSelectionProvider seatProvider(BuildContext context) {
    return Provider.of<SeatSelectionProvider>(context, listen: false);
  }

  static AppStateProvider appStateProvider(BuildContext context) {
    return Provider.of<AppStateProvider>(context, listen: false);
  }

  static TicketProvider ticketProvider(BuildContext context) {
    return Provider.of<TicketProvider>(context, listen: false);
  }

  // Listeners for UI updates
  static LoginProvider loginProviderListener(BuildContext context) {
    return Provider.of<LoginProvider>(context, listen: true);
  }

  static NotificationProvider notificationProviderListener(
      BuildContext context) {
    return Provider.of<NotificationProvider>(context, listen: true);
  }

  static SeatSelectionProvider seatProviderListener(
      BuildContext context) {
    return Provider.of<SeatSelectionProvider>(context, listen: true);
  }

  static AppStateProvider appStateProviderListener(
      BuildContext context) {
    return Provider.of<AppStateProvider>(context, listen: true);
  }

  static TicketProvider ticketProviderListener(BuildContext context) {
    return Provider.of<TicketProvider>(context, listen: true);
  }

  // Helper methods for common operations
  static bool isLoggedIn(BuildContext context) {
    return loginProviderListener(context).isLoggedIn;
  }

  static bool isOnline(BuildContext context) {
    return appStateProviderListener(context).isOnline;
  }

  static bool isLoading(BuildContext context) {
    final appState = appStateProviderListener(context);
    final login = loginProviderListener(context);
    final tickets = ticketProviderListener(context);
    final notifications = notificationProviderListener(context);

    return appState.isLoading ||
        login.isLoading ||
        tickets.isLoading ||
        notifications.isLoading;
  }

  static String? getCurrentError(BuildContext context) {
    final appState = appStateProviderListener(context);
    final login = loginProviderListener(context);
    final tickets = ticketProviderListener(context);
    final notifications = notificationProviderListener(context);

    if (appState.error.isNotEmpty) return appState.error;
    if (login.error.isNotEmpty) return login.error;
    if (tickets.error.isNotEmpty) return tickets.error;
    if (notifications.error.isNotEmpty) return notifications.error;

    return null;
  }

  static void clearAllErrors(BuildContext context) {
    appStateProvider(context).clearError();
    loginProvider(context).clearError();
    ticketProvider(context).clearError();
    notificationProvider(context).clearError();
  }

  static Future<void> logout(BuildContext context) async {
    await loginProvider(context).logout();
    ticketProvider(context).clearData();
    notificationProvider(context).clearError();
  }
}
