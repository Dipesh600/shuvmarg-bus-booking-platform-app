import 'package:flutter/foundation.dart';
import 'package:sumarg/controllers/notification_controller/notification_controller.dart';
import 'package:sumarg/models/local_notification_response.dart';
import 'package:sumarg/models/api_response.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationController _notificationController =
      NotificationController();

  List<NotificationItem> _notifications = [];
  bool _isLoading = false;
  String _error = '';
  String _selectedCategory = 'All';

  // Getters
  List<NotificationItem> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get selectedCategory => _selectedCategory;

  // Get filtered notifications based on selected category
  List<NotificationItem> get filteredNotifications {
    if (_selectedCategory == 'All') {
      return _notifications;
    }
    return _notifications
        .where(
            (n) => _getCategoryFromType(n.type) == _selectedCategory)
        .toList();
  }

  // Get unread count
  int get unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  // Set selected category
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Load notifications from API
  Future<void> loadNotifications({bool forceRefresh = false}) async {
    // If not a force refresh and we already have data, skip.
    if (_notifications.isNotEmpty && !forceRefresh) return;

    // Show loading only if we have no data yet.
    if (_notifications.isEmpty) {
      _isLoading = true;
      _error = '';
      notifyListeners();
    }

    try {
      final response =
          await _notificationController.getNotifications();
      if (response.status) {
        _notifications = response.notifications;
        _error = '';
      } else {
        if (_notifications.isEmpty) {
          _error = 'Failed to load notifications';
        }
      }
    } catch (e) {
      if (_notifications.isEmpty) {
        _error = 'Error loading notifications: $e';
      }
    } finally {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      } else if (forceRefresh) {
        notifyListeners();
      }
    }
  }

  // Mark notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final result = await _notificationController
          .markNotificationAsRead(notificationId);

      if (result.success) {
        // Update local state without reloading
        final index =
            _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          // Create a new notification item with updated isRead status
          final notification = _notifications[index];
          final updatedNotification = NotificationItem(
            id: notification.id,
            user: notification.user,
            type: notification.type,
            title: notification.title,
            message: notification.message,
            isRead: true, // Mark as read
            meta: notification.meta,
            createdAt: notification.createdAt,
            v: notification.v,
          );

          // Update the list
          _notifications[index] = updatedNotification;

          // Notify listeners to update UI
          notifyListeners();
        }
        return true;
      } else {
        _error = result.message.isNotEmpty
            ? result.message
            : 'Failed to mark as read';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error marking notification as read: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final result = await _notificationController
          .deleteNotification(notificationId);

      if (result.success) {
        // Remove from local state without reloading
        _notifications.removeWhere((n) => n.id == notificationId);
        
        // Notify listeners to update UI
        notifyListeners();
        return true;
      } else {
        _error = result.message.isNotEmpty
            ? result.message
            : 'Failed to delete notification';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error deleting notification: $e';
      notifyListeners();
      return false;
    }
  }

  // Refresh notifications (pull to refresh)
  Future<void> refreshNotifications() async {
    await loadNotifications();
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Helper method to get category from type
  String _getCategoryFromType(String type) {
    switch (type.toLowerCase()) {
      case 'booking':
      case 'trip':
        return 'Bookings';
      case 'offer':
      case 'discount':
        return 'Offers';
      case 'system':
      case 'update':
        return 'System';
      default:
        return 'System';
    }
  }
}
