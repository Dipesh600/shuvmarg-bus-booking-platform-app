import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../views/seats_screen.dart';
import '../views/buss_search_result_screen.dart';
import '../views/home_screen.dart';
import '../views/user_profile_screen.dart';
import '../models/trip_response.dart';

/// Service to handle smart navigation after login
class NavigationService {
  static const String _redirectKey = 'login_redirect_data';
  static const String _redirectTypeKey = 'login_redirect_type';

  /// Types of redirects
  static const String redirectTypeSeatBooking = 'seat_booking';
  static const String redirectTypeSearchResults = 'search_results';
  static const String redirectTypeHome = 'home';
  static const String redirectTypeProfile = 'profile';
  static const String redirectTypeTicketDetail = 'ticket_detail';

  /// Store redirect information before going to login
  static Future<void> storeRedirectData({
    required String redirectType,
    Map<String, dynamic>? data,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_redirectTypeKey, redirectType);
    if (data != null) {
      await prefs.setString(_redirectKey, _encodeData(data));
    }
  }

  /// Get stored redirect information
  static Future<Map<String, dynamic>?> getRedirectData() async {
    final prefs = await SharedPreferences.getInstance();
    final redirectType = prefs.getString(_redirectTypeKey);
    final redirectData = prefs.getString(_redirectKey);

    if (redirectType != null) {
      return {
        'type': redirectType,
        'data': redirectData != null ? _decodeData(redirectData) : null,
      };
    }
    return null;
  }

  /// Clear stored redirect information
  static Future<void> clearRedirectData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_redirectTypeKey);
    await prefs.remove(_redirectKey);
  }

  /// Navigate based on stored redirect data
  static Future<void> navigateAfterLogin(BuildContext context) async {
    final redirectInfo = await getRedirectData();

    if (redirectInfo != null) {
      final redirectType = redirectInfo['type'] as String;
      final data = redirectInfo['data'] as Map<String, dynamic>?;

      // Clear the stored data
      await clearRedirectData();

      // Navigate based on type
      switch (redirectType) {
        case redirectTypeSeatBooking:
          _navigateToSeatBooking(context, data);
          break;
        case redirectTypeSearchResults:
          _navigateToSearchResults(context, data);
          break;
        case redirectTypeProfile:
          _navigateToProfile(context);
          break;
        case redirectTypeTicketDetail:
          _navigateToTicketDetail(context, data);
          break;
        case redirectTypeHome:
        default:
          _navigateToHome(context);
          break;
      }
    } else {
      // No redirect data, go to home
      _navigateToHome(context);
    }
  }

  /// Navigate to seat booking screen
  static void _navigateToSeatBooking(
      BuildContext context, Map<String, dynamic>? data) {
    if (data != null) {
      // Reconstruct TripData from stored data
      final busDetail = BusDetail(
        id: data['busId'] ?? '',
        busName: data['busName'] ?? '',
        busNumber: data['busNo'] ?? '',
        busType: data['busType'] ?? '',
        vehicleType: data['vehicleType'] ?? '',
        totalSeats: data['totalSeats'] ?? 0,
        seatLayout: data['seatLayout'] ?? '',
        amenities: List<String>.from(data['amenities'] ?? []),
      );

      final routeDetail = RouteDetail(
        id: data['routeId'] ?? '',
        routeName: data['routeName'] ?? '',
        from: data['from'] ?? '',
        to: data['to'] ?? '',
        distance: data['distance'] ?? '',
        duration: data['duration'] ?? '',
      );

      final busData = TripData(
        id: data['busId'] ?? '',
        tripId: data['tripId'] ?? '',
        tripDate: data['date'] ?? '',
        departureTime: data['departureTime'] ?? '',
        arrivalTime: data['arrivalTime'] ?? '',
        tripFare: data['price'] ?? 0,
        shift: data['shift'] ?? '',
        busDetail: busDetail,
        routeDetail: routeDetail,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SeatSelectionScreen(busData: busData),
        ),
      );
    } else {
      _navigateToHome(context);
    }
  }

  /// Navigate to search results screen
  static void _navigateToSearchResults(
      BuildContext context, Map<String, dynamic>? data) {
    if (data != null && data['searchData'] != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              BusResultsScreen(searchData: data['searchData']),
        ),
      );
    } else {
      _navigateToHome(context);
    }
  }

  /// Navigate to profile screen
  static void _navigateToProfile(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const UserProfileScreen(),
      ),
    );
  }

  /// Navigate to ticket detail screen
  static void _navigateToTicketDetail(
      BuildContext context, Map<String, dynamic>? data) {
    if (data != null) {
      // For now, navigate to home since we need TripData object
      // In a real implementation, you would need to reconstruct TripData from stored data
      _navigateToHome(context);
    } else {
      _navigateToHome(context);
    }
  }

  /// Navigate to home screen
  static void _navigateToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  /// Helper method to encode data to string
  static String _encodeData(Map<String, dynamic> data) {
    return jsonEncode(data);
  }

  /// Helper method to decode data from string
  static Map<String, dynamic> _decodeData(String encodedData) {
    try {
      return jsonDecode(encodedData) as Map<String, dynamic>;
    } catch (e) {
      return {'error': 'Failed to decode data: $e'};
    }
  }

  /// Check if user should be redirected after login
  static Future<bool> hasRedirectData() async {
    final redirectInfo = await getRedirectData();
    return redirectInfo != null;
  }

  /// Get redirect type without clearing data
  static Future<String?> getRedirectType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_redirectTypeKey);
  }
}
