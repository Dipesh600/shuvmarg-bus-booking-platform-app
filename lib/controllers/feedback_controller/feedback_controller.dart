import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:sumarg/apis/api_services.dart';
import 'package:sumarg/models/for_all_response.dart';
import 'package:sumarg/models/get_review_response.dart';
import 'package:sumarg/utils/api_endpoints.dart';

class FeedbackController {
  final ApiService _apiService = ApiService();

  // Submit review
  Future<ForAllResponse> submitReview({
    required String bookingId,
    required int rating,
    required String comment,
  }) async {
    debugPrint("Submitting review...");

    final Map<String, dynamic> requestBody = {
      "bookingId": bookingId,
      "rating": rating,
      "comment": comment,
      "title": "",
      "images": [],
      "isAnonymous": false,
    };
    print("minidatarev $requestBody");

    try {
      final response = await _apiService.postDataWithToken(
        ApiEndpoints.feedback,
        requestBody,
      );

      debugPrint("Review submission response: $response");
      return ForAllResponse.fromJson(response);
    } catch (error) {
      debugPrint("Review submission error: $error");
      final errorStr = error.toString();
      if (errorStr.contains('409')) {
        return ForAllResponse(
          message: 'You have already submitted a review for this booking.',
          status: false,
        );
      }
      return ForAllResponse(
        message: 'Failed to submit review. Please try again.',
        status: false,
      );
    }
  }

  // Get Feedback
  Future<GetReviewResponse> getFeedback({required String bussNo }) async {
    debugPrint("Getting review...");

    final Map<String, dynamic> requestBody = {"bussNo": bussNo};
    print("minidatarev $requestBody");

    try {
      final response = await _apiService.postDataWithToken(
        ApiEndpoints.getfeedback,
        requestBody,
      );

      debugPrint("Review submission response: $response");
      return GetReviewResponse.fromJson(response);
    } catch (error) {
      debugPrint("Review submission error: $error");
      final errorStr = error.toString();
     

      return GetReviewResponse(
        status: false,
      );
    }
  }
}
