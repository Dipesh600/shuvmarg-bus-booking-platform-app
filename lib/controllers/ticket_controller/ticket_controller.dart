import 'package:dio/dio.dart';
import 'package:sumarg/apis/api_services.dart';
import 'package:sumarg/models/for_all_response.dart';
import 'package:sumarg/models/prepare_booking_response.dart';
import 'package:sumarg/models/ticket_booking_response.dart';
import 'package:sumarg/models/ticket_history_response.dart';
import 'package:sumarg/models/trip_response.dart';
import 'package:sumarg/models/yatra_points_response.dart';
import 'package:sumarg/utils/api_endpoints.dart';
import 'package:sumarg/utils/connectivity_service.dart';
import 'package:sumarg/utils/local_storage_service.dart';

class TicketController {
// Search ticket
  Future<TripResponse> searchTicket(data) async {
    final ApiService apiService = ApiService();
    const String searchTicketUrl = ApiEndpoints.searchTicket;
    try {
      final response = await apiService.postData(searchTicketUrl, data);
      final searchResponse = TripResponse.fromJson(response);
      print("searchres ${response}");
      return searchResponse;
    } on DioException catch (e) {
      // Extract the server's response message on 400/error responses
      String errorMessage = 'No trips found for the selected date';
      if (e.response?.data != null) {
        try {
          final responseData = e.response!.data;
          if (responseData is Map<String, dynamic> &&
              responseData['message'] != null) {
            errorMessage = responseData['message'];
          }
        } catch (_) {}
      }
      return TripResponse(
        success: false,
        message: errorMessage,
        results: 0,
        data: [],
      );
    } catch (error) {
      return TripResponse(
        success: false,
        message: 'Failed to search buses. Please try again.',
        results: 0,
        data: [],
      );
    }
  }

  // Booking Controller
  Future<TicketBookingResponse> bookTicket(data) async {
    final ApiService apiService = ApiService();
    const String bookingUrl = ApiEndpoints.bookTicket;
    try {
      final response = await apiService.postDataWithToken(bookingUrl, data);
      final searchResponse = TicketBookingResponse.fromJson(response);
      return searchResponse;
    } catch (error) {
      return TicketBookingResponse(
          status: false, message: 'Faild to Book Ticket: $error', ticketId: "");
    }
  }

  /// prepareBooking — Step 1 of the two-phase atomic booking.
  ///
  /// Locks seats temporarily and returns the server-validated paymentAmount.
  /// The returned paymentAmount MUST be passed to eSewa SDK instead of the
  /// locally-calculated price to prevent amount manipulation.
  ///
  /// On success, also returns tempBookingId which ties the seat lock to
  /// the subsequent confirmBooking call.
  Future<PrepareBookingResponse> prepareBooking(Map<String, dynamic> data) async {
    final ApiService apiService = ApiService();
    const String url = ApiEndpoints.prepareBooking;
    try {
      final response = await apiService.postDataWithToken(url, data);
      return PrepareBookingResponse.fromJson(
          response is Map<String, dynamic> ? response : {});
    } catch (error) {
      return PrepareBookingResponse(
        status:  false,
        message: 'Failed to prepare booking: $error',
      );
    }
  }

  // Get Ticket History with offline support
  Future<TicketHistoryResponse> ticketHistory(data) async {
    final connectivityService = ConnectivityService();
    final hasInternet = await connectivityService.hasInternetAccess();

    if (hasInternet) {
      // Try to fetch from API
      try {
        final ApiService apiService = ApiService();
        const String bookHistoryUrl = ApiEndpoints.bookingHistory;

        final response = await apiService.getDataWithToken(bookHistoryUrl);
        final searchResponse = TicketHistoryResponse.fromJson(response);

        // Save to local storage for offline use
        await LocalStorageService.saveTicketHistory(searchResponse);

        return searchResponse;
      } catch (error) {
        // If API fails, try to get from local storage
        final localData = await LocalStorageService.getTicketHistory();
        if (localData != null) {
          return localData;
        }
        throw Exception('Failed to fetch ticket history: $error');
      }
    } else {
      // No internet connection, try to get from local storage
      final localData = await LocalStorageService.getTicketHistory();
      if (localData != null) {
        return localData;
      } else {
        throw Exception('No internet connection and no local data available');
      }
    }
  }

  // Get ticket history with offline indicator
  Future<Map<String, dynamic>> ticketHistoryWithStatus(data) async {
    final connectivityService = ConnectivityService();
    final hasInternet = await connectivityService.hasInternetAccess();

    try {
      if (hasInternet) {
        // Try to fetch from API
        final ApiService apiService = ApiService();
        const String bookHistoryUrl = ApiEndpoints.bookingHistory;

        final response = await apiService.getDataWithToken(bookHistoryUrl);
        final searchResponse = TicketHistoryResponse.fromJson(response);

        // Save to local storage for offline use
        await LocalStorageService.saveTicketHistory(searchResponse);

        return {
          'data': searchResponse,
          'isOffline': false,
          'lastUpdated': DateTime.now(),
        };
      } else {
        // No internet connection, get from local storage
        final localData = await LocalStorageService.getTicketHistory();
        if (localData != null) {
          final lastUpdated = await LocalStorageService.getLastUpdated();
          return {
            'data': localData,
            'isOffline': true,
            'lastUpdated': lastUpdated,
          };
        } else {
          throw Exception('No internet connection and no local data available');
        }
      }
    } catch (error) {
      // If API fails, try to get from local storage
      final localData = await LocalStorageService.getTicketHistory();
      if (localData != null) {
        final lastUpdated = await LocalStorageService.getLastUpdated();
        return {
          'data': localData,
          'isOffline': true,
          'lastUpdated': lastUpdated,
        };
      }
      throw Exception('Failed to fetch ticket history: $error');
    }
  }

// Validate yatra points
  Future<YatraPointsResponse> validateYatraPoints(data) async {
    final ApiService apiService = ApiService();
    const String validateYatraPointsUrl = ApiEndpoints.validateYatraPoints;
    try {
      final response =
          await apiService.postDataWithToken(validateYatraPointsUrl, data);
      final validateYatraPointsResponse =
          YatraPointsResponse.fromJson(response);
      return validateYatraPointsResponse;
    } catch (error) {
      return YatraPointsResponse(
          status: false, message: 'Failed to validate yatra points: $error');
    }
  }

  // Cancel ticket
  Future<ForAllResponse> cancelTicket(data) async {
    final ApiService apiService = ApiService();
    const String cancelTicketUrl = ApiEndpoints.cancelticket;
    try {
      final response =
          await apiService.postDataWithToken(cancelTicketUrl, data);
      final validateYatraPointsResponse = ForAllResponse.fromJson(response);
      return validateYatraPointsResponse;
    } catch (error) {
      return ForAllResponse(
          status: false, message: 'Failed to cancel ticket: $error');
    }
  }
}
