import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sumarg/apis/api_services.dart';
import 'package:sumarg/models/for_all_response.dart';
import 'package:sumarg/models/get_review_response.dart';
import 'package:sumarg/utils/api_endpoints.dart';

class FeedbackController {
  final ApiService _apiService = ApiService();

  // Submit review — sends fleetId as required by backend
  Future<ForAllResponse> submitReview({
    required String bookingId,
    required String fleetId,
    required int rating,
    required String comment,
  }) async {
    debugPrint("═══ [REVIEW] Submitting review ═══");
    debugPrint("[REVIEW] bookingId: $bookingId");
    debugPrint("[REVIEW] fleetId: $fleetId");
    debugPrint("[REVIEW] rating: $rating");

    final Map<String, dynamic> requestBody = {
      "bookingId": bookingId,
      "fleetId": fleetId,
      "rating": rating,
      "comment": comment,
      "title": "",
      "images": [],
      "isAnonymous": false,
    };
    debugPrint("[REVIEW] Full payload: $requestBody");

    try {
      final response = await _apiService.postDataWithToken(
        ApiEndpoints.feedback,
        requestBody,
      );

      debugPrint("[REVIEW] Success response: $response");
      return ForAllResponse.fromJson(response);
    } catch (error) {
      debugPrint("[REVIEW] ❌ Error type: ${error.runtimeType}");
      debugPrint("[REVIEW] ❌ Error: $error");

      // Extract the server's error message from the Dio chain
      String message = 'Failed to submit review. Please try again.';

      if (error is DioException) {
        message = error.message ?? message;
        final responseData = error.response?.data;
        if (responseData is Map && responseData['message'] != null) {
          message = responseData['message'];
        }
        debugPrint("[REVIEW] DioException status: ${error.response?.statusCode}");
        debugPrint("[REVIEW] DioException data: ${error.response?.data}");
      } else {
        final errorStr = error.toString();
        debugPrint("[REVIEW] Parsing non-DioException error: $errorStr");

        // The ApiService wraps DioExceptions in Exception('Error in fetching data: DioException...')
        if (errorStr.contains('DioException')) {
          // 1. Try splitting by typical DioException [type]: Message
          if (errorStr.contains(']:')) {
            final parts = errorStr.split(']:');
            if (parts.length > 1) {
              message = parts.last.trim();
            }
          } 
          // 2. Try JSON message matcher
          else {
            final msgMatch = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(errorStr);
            if (msgMatch != null) {
              message = msgMatch.group(1)!;
            } else {
              // 3. Fallback: match after "Error in fetching data: "
              final dataMatch = RegExp(r'Error in fetching data:\s*(.+)').firstMatch(errorStr);
              if (dataMatch != null) {
                message = dataMatch.group(1)!.trim();
              }
            }
          }
        } else {
          // If it's a generic Exception with a colon, get the message part
          if (errorStr.contains(':')) {
            message = errorStr.split(':').last.trim();
          } else {
            message = errorStr;
          }
        }

        // Clean up any trailing brackets/exception prefixes
        if (message.endsWith('}')) {
          final cleanMatch = RegExp(r'message:\s*([^,}]+)').firstMatch(message);
          if (cleanMatch != null) {
            message = cleanMatch.group(1)!.trim();
          }
        }

        // Handle duplicate review (409)
        if (errorStr.contains('409') || errorStr.contains('already reviewed') || errorStr.contains('11000')) {
          message = 'You have already submitted a review for this booking.';
        }
      }

      // Final sanitization of the string to present nicely
      message = message.replaceAll('Exception:', '').replaceAll('Exception', '').trim();

      return ForAllResponse(
        message: message,
        status: false,
      );
    }
  }

  // Get reviews for a fleet (bus) by fleetId — uses GET endpoint
  Future<GetReviewResponse> getFeedback({required String fleetId}) async {
    debugPrint("[REVIEW] Getting reviews for fleet: $fleetId");

    try {
      final response = await _apiService.getDataWithToken(
        ApiEndpoints.getFleetReviews(fleetId),
      );

      debugPrint("[REVIEW] Fleet reviews response status: ${response['status']}");
      return GetReviewResponse.fromJson(response);
    } catch (error) {
      debugPrint("[REVIEW] ❌ Get reviews error: $error");
      return GetReviewResponse(
        status: false,
      );
    }
  }
}
