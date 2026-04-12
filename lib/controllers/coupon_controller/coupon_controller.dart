import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sumarg/apis/api_services.dart';
import 'package:sumarg/models/coupon_response_model.dart';
import 'package:sumarg/models/get_coupn_respnse_model.dart';
import 'package:sumarg/models/reward_history_model.dart';
import 'package:sumarg/utils/api_endpoints.dart';

class CouponController {
// Validate Coupon
  Future<CouponResponse> validateCoupon(data) async {
    debugPrint("Validating coupon...");
    final ApiService apiService = ApiService();
    const String validateCouponUrl = ApiEndpoints.validateCoupon;
    print("miniurl $validateCouponUrl");
    try {
      final response =
          await apiService.postDataWithToken(validateCouponUrl, data);
      final couponResponse = CouponResponse.fromJson(response);
      debugPrint("Coupon validation response: $response");
      return couponResponse;
    } catch (error) {
      debugPrint("Coupon validation error: $error");
      
      // Try to extract meaningful error message from the exception
      String errorMessage = 'Failed to validate coupon';
      
      // The error comes as: "Exception: Error in fetching data: Exception: Failed to load data: 400 Bad Request"
      // But the actual server response is in the API service print statement
      // We need to handle this differently by making a direct API call with better error handling
      
      try {
        // Extract the HTTP status code from error message to determine the type of error
        String errorString = error.toString();
        if (errorString.contains('400 Bad Request')) {
          // For 400 errors, it's likely a validation error like expired coupon
          // We'll make a direct HTTP call to get the actual response
          
          // Get token for the request
          SharedPreferences preferences = await SharedPreferences.getInstance();
          final String? token = preferences.getString("accessToken");
          
          if (token != null && token.isNotEmpty) {
            try {
              final response = await http.post(
                Uri.parse(ApiEndpoints.validateCoupon),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': "Bearer $token",
                },
                body: jsonEncode(data),
              );
              
              // Parse the response body to get the actual error message
              if (response.statusCode == 400) {
                final responseBody = jsonDecode(response.body);
                if (responseBody is Map<String, dynamic> && 
                    responseBody.containsKey('message')) {
                  errorMessage = responseBody['message'];
                }
              }
            } catch (directCallError) {
              // If direct call fails, keep the default message
              debugPrint("Direct API call error: $directCallError");
            }
          }
        }
      } catch (parseError) {
        debugPrint("Error parsing exception: $parseError");
      }
      
      return CouponResponse(
          message: errorMessage, success: false);
    }
  }

  // Get all coupons
  Future<CouponResponse2> getAllCoupons() async {
    debugPrint("Fetching all coupons...");
    final ApiService apiService = ApiService();
    const String url = ApiEndpoints.getCoupons;
    try {
      final response = await apiService.getDataWithoutToken(url);
      final coupons = CouponResponse2.fromJson(response);
      debugPrint(
          "Get coupons response received: success=${coupons.success} count=${coupons.data}");
      return coupons;
    } catch (error) {
      debugPrint("Get coupons error: $error");
      return CouponResponse2(
        success: false,
        message: 'No coupons Found',
        data: [],
      );
    }
  }

  // Get Reward History
  Future<RewardHistoryResponse> getRewardHistory() async {
    debugPrint("Fetching reward history...");
    final ApiService apiService = ApiService();
    const String url = ApiEndpoints.getRewardHistory;
    try {
      final response = await apiService.getDataWithToken(url);
      final rewards = RewardHistoryResponse.fromJson(response);
      debugPrint(
          "Reward history received: status=${rewards.status} count=${rewards.data.length}");
      return rewards;
    } catch (error) {
      debugPrint("Get reward history error: $error");
      return RewardHistoryResponse(
        status: false,
        message: 'Failed to fetch reward history',
        data: [],
      );
    }
  }
}
