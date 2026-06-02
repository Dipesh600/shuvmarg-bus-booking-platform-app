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
  // Validate Coupon — always reads the real JSON message from the server
  Future<CouponResponse> validateCoupon(data) async {
    debugPrint("Validating coupon: $data");
    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final String? token = preferences.getString("accessToken");

      final response = await http.post(
        Uri.parse(ApiEndpoints.validateCoupon),
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint("Coupon validate response [${response.statusCode}]: $responseBody");

      // success path (200)
      if (response.statusCode == 200 && responseBody['success'] == true) {
        return CouponResponse.fromJson(responseBody);
      }

      // error path — always use the server's message
      final serverMessage = (responseBody['message'] as String?) ??
          'Coupon validation failed';
      return CouponResponse(message: serverMessage, success: false);
    } catch (e) {
      debugPrint("Coupon validation error: $e");
      return CouponResponse(
          message: 'Could not reach server. Check your connection.',
          success: false);
    }
  }

  // Get all coupons (active only — for home carousel)
  Future<CouponResponse2> getAllCoupons() async {
    debugPrint("Fetching active coupons...");
    final ApiService apiService = ApiService();
    final String url = ApiEndpoints.getCoupons;
    try {
      final response = await apiService.getDataWithoutToken(url);
      final coupons = CouponResponse2.fromJson(response);
      debugPrint(
          "Get coupons response: success=${coupons.success} count=${coupons.data.length}");
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

  // Get ALL coupons including expired (for "See All" page)
  Future<CouponResponse2> getAllCouponsWithExpired() async {
    debugPrint("Fetching all coupons including expired...");
    final ApiService apiService = ApiService();
    final String url = ApiEndpoints.getAllCouponsWithExpired;
    try {
      final response = await apiService.getDataWithoutToken(url);
      final coupons = CouponResponse2.fromJson(response);
      debugPrint(
          "All coupons (incl. expired): success=${coupons.success} count=${coupons.data.length}");
      return coupons;
    } catch (error) {
      debugPrint("Get all coupons error: $error");
      return CouponResponse2(
        success: false,
        message: 'Failed to load offers',
        data: [],
      );
    }
  }

  // Get Reward History
  Future<RewardHistoryResponse> getRewardHistory() async {
    debugPrint("Fetching reward history...");
    final ApiService apiService = ApiService();
    final String url = ApiEndpoints.getRewardHistory;
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
