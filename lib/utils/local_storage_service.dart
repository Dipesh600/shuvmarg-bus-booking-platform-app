import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ticket_history_response.dart';

class LocalStorageService {
  static const String _ticketHistoryKey = 'ticket_history_data';
  static const String _lastUpdatedKey = 'ticket_history_last_updated';

  // Save ticket history data locally
  static Future<void> saveTicketHistory(
      TicketHistoryResponse data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(data.toJson());
      await prefs.setString(_ticketHistoryKey, jsonString);
      await prefs.setString(
          _lastUpdatedKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Error saving ticket history to local storage: $e');
    }
  }

  // Get ticket history data from local storage
  static Future<TicketHistoryResponse?> getTicketHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_ticketHistoryKey);
      if (jsonString != null) {
        final jsonData = jsonDecode(jsonString);
        return TicketHistoryResponse.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      print('Error reading ticket history from local storage: $e');
      return null;
    }
  }

  // Check if local data exists
  static Future<bool> hasLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_ticketHistoryKey) != null;
    } catch (e) {
      return false;
    }
  }

  // Get last updated timestamp
  static Future<DateTime?> getLastUpdated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getString(_lastUpdatedKey);
      if (timestamp != null) {
        return DateTime.parse(timestamp);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Clear local data
  static Future<void> clearLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_ticketHistoryKey);
      await prefs.remove(_lastUpdatedKey);
    } catch (e) {
      print('Error clearing local data: $e');
    }
  }

  // Check if local data is stale (older than 24 hours)
  static Future<bool> isLocalDataStale() async {
    try {
      final lastUpdated = await getLastUpdated();
      if (lastUpdated == null) return true;

      final now = DateTime.now();
      final difference = now.difference(lastUpdated);
      return difference.inHours > 24;
    } catch (e) {
      return true;
    }
  }
}
