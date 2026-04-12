import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sumarg/apis/api_services.dart';
import 'package:sumarg/models/user_detail_response.dart';
import 'package:sumarg/utils/api_endpoints.dart';
import 'package:sumarg/models/api_response.dart';
import 'package:sumarg/models/login_response.dart';
import '../../models/for_all_response.dart';

class AuthController {
  final String loginUrl = ApiEndpoints.login;
  final String registerUrl = ApiEndpoints.register;
  final String verifyOtpUrl = ApiEndpoints.verifyOtp;
  final String resendOtpUrl = ApiEndpoints.resendOtp;
  final String registerNextStape = ApiEndpoints.registerNextStape;

  Future login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: json
            .encode({'emailOrPhone': email, 'password': password}),
      );
      if (kDebugMode) {
        print("loginresponse ${response.body}");
      }
      if (kDebugMode) {
        print("loginstatuscode ${response.statusCode}");
      }
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final loginResponse = LoginResponse.fromJson(responseData);
        await _saveLoginResponse(loginResponse);
        if (kDebugMode) {
          print("mylogindetail $loginResponse");
        }
        return loginResponse;
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        final loginResponse = ApiResponse.fromJson(responseData);
        return loginResponse;
      } else {
        return null;
      }
    } catch (error) {
      return null;
    }
  }

  Future<void> _saveLoginResponse(LoginResponse loginResponse) async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool('success', loginResponse.success);
    await prefs.setString('message', loginResponse.message);
    await prefs.setString('accessToken', loginResponse.accessToken);
    final userData = loginResponse.user;

    await prefs.setString('userId', userData.id);
    await prefs.setString('name', userData.name);
    await prefs.setString(
        'email', userData.email ?? ''); // Handle nullable email
    await prefs.setString('phone', userData.phone);
    await prefs.setString('address', userData.address);
    await prefs.setString('profilePicture', userData.profilePicture);
    await prefs.setString('gender', userData.gender);
    await prefs.setString('role', userData.role);
    await prefs.setBool('isVerified', userData.isVerified);
    await prefs.setString('status', userData.status);
    await prefs.setBool(
        'phoneVerified', userData.phoneVerified); // Add missing field
    await prefs.setString('referralCode', userData.referralCode);
    await prefs.setString('referredBy',
        userData.referredBy ?? ''); // Handle nullable referredBy
    await prefs.setInt('referralPoints', userData.referralPoints);
    await prefs.setInt('rewardPoints', userData.rewardPoints);
    await prefs.setInt('totalReferrals', userData.totalReferrals);
  }

  Future<void> clearLoginData() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();
    await prefs.remove('success');
    await prefs.remove('message');
    await prefs.remove('accessToken');
    await prefs.remove('userId');
    await prefs.remove('name');
    await prefs.remove('email');
    await prefs.remove('phone');
    await prefs.remove('address');
    await prefs.remove('profilePicture');
    await prefs.remove('gender');
    await prefs.remove('role');
    await prefs.remove('isVerified');
    await prefs.remove('status');
    await prefs.remove('phoneVerified');
    await prefs.remove('referralCode');
    await prefs.remove('referredBy');
    await prefs.remove('referralPoints');
    await prefs.remove('rewardPoints');
    await prefs.remove('totalReferrals');
    await prefs.remove('createdAt');
    await prefs.remove('updatedAt');
    await prefs.remove('v');
  }
  // Register

  Future registeer(String phnenumber, [String? referralCode]) async {
    try {
      final response = await http.post(
        Uri.parse(registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "phone": phnenumber,
        }),
      );
      print("register response: ${response.body}");
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final registerResponse =
            ForAllResponse.fromJson(responseData);
        return registerResponse;
      } else if (response.statusCode == 400) {
        final responseData = json.decode(response.body);
        final registerResponse =
            ForAllResponse.fromJson(responseData);
        return registerResponse;
      } else {
        return null;
      }
    } catch (error) {
      return null;
    }
  }

  Future registeerNextStape(data) async {
    try {
      final response = await http.post(
        Uri.parse(registerNextStape),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      if (kDebugMode) {
        print("register data ${response.body}");
      }
      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final registerResponse =
            ForAllResponse.fromJson(responseData);
        return registerResponse;
      } else if (response.statusCode == 400) {
        final responseData = json.decode(response.body);
        final registerResponse =
            ForAllResponse.fromJson(responseData);
        return registerResponse;
      } else {
        return null;
      }
    } catch (error) {
      return null;
    }
  }

// Otp Verification
  Future otpVerification(String phone, String otp) async {
    try {
      final response = await http.post(
        Uri.parse(verifyOtpUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"phone": phone, "otp": otp}),
      );
      print("otp verification response: ${response.body}");
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final otpResponse = ForAllResponse.fromJson(responseData);
        return otpResponse;
      } else if (response.statusCode == 400) {
        final responseData = json.decode(response.body);
        final otpResponse = ForAllResponse.fromJson(responseData);
        return otpResponse;
      } else {
        return null;
      }
    } catch (error) {
      return null;
    }
  }

// Resend OTP
  Future resendOtp(String emailOrPhone) async {
    try {
      final response = await http.post(
        Uri.parse(resendOtpUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"emailOrPhone": emailOrPhone}),
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final otpResponse = ForAllResponse.fromJson(responseData);
        return otpResponse;
      } else if (response.statusCode == 404) {
        final responseData = json.decode(response.body);
        final otpResponse = ForAllResponse.fromJson(responseData);
        return otpResponse;
      } else {
        return null;
      }
    } catch (error) {
      return null;
    }
  }

  // Resend OTP for registration (calls register endpoint again)
  Future resendOtpForRegistration(String phone,
      [String? referralCode]) async {
    try {
      final response = await http.post(
        Uri.parse(registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "phone": phone,
          if (referralCode != null && referralCode.isNotEmpty)
            "referralCode": referralCode,
          "gender": "male"
        }),
      );
      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final registerResponse =
            ForAllResponse.fromJson(responseData);
        return registerResponse;
      } else if (response.statusCode == 400) {
        final responseData = json.decode(response.body);
        final registerResponse =
            ForAllResponse.fromJson(responseData);
        return registerResponse;
      } else {
        return null;
      }
    } catch (error) {
      return null;
    }
  }

// Forgot Password
  Future<ForAllResponse> forgotPassword(String phoneNumber) async {
    final ApiService apiService = ApiService();
    const String forgotPasswordUrl = ApiEndpoints.passwordReset;

    try {
      final data = {'emailOrPhone': phoneNumber};
      final response =
          await apiService.postData(forgotPasswordUrl, data);
      print("forgot password responset: ${response}");
      final otpResponse = ForAllResponse.fromJson(response);
      return otpResponse;
    } catch (error) {
      return ForAllResponse(
        status: false,
        message: 'Failed to send password reset request: $error',
      );
    }
  }

// verify otp for reset password
  Future<ForAllResponse> verifyOtpForResetPass(
      String email, otp) async {
    final ApiService apiService = ApiService();
    const String verifyOtpForPassUrl = ApiEndpoints.verifyOtpForPass;
    try {
      final data = {"emailOrPhone": email, "otp": otp};
      final response =
          await apiService.postData(verifyOtpForPassUrl, data);

      final otpResponse = ForAllResponse.fromJson(response);
      return otpResponse;
    } catch (error) {
      return ForAllResponse(
        status: false,
        message: 'Failed to send password reset request: $error',
      );
    }
  }

// Submit New Password
  Future<ForAllResponse> submitNewPassword(
    pass,
    otp,
    email,
  ) async {
    final ApiService apiService = ApiService();
    const String resetPasswordUrl = ApiEndpoints.resetPassword;
    try {
      final data = {
        "emailOrPhone": email,
        "otp": otp,
        "newPassword": pass
      };
      final response =
          await apiService.postData(resetPasswordUrl, data);

      final otpResponse = ForAllResponse.fromJson(response);
      return otpResponse;
    } catch (error) {
      return ForAllResponse(
        status: false,
        message: 'Failed to send password reset request: $error',
      );
    }
  }

  // Get user details
  Future<UserDetailResponse> getUserDetails() async {
    final ApiService apiService = ApiService();
    const String getUserDetailsUrl = ApiEndpoints.getUserDetails;
    try {
      final response =
          await apiService.getDataWithToken(getUserDetailsUrl);
          print("user details response: ${response}");

      final otpResponse = UserDetailResponse.fromJson(response);
      return otpResponse;
    } catch (error) {
      return UserDetailResponse(
        status: false,
        message: 'Failed to get user details: $error',
      );
    }
  }

  // Update profile detail
  Future<ForAllResponse> updateProfile({
    required String name,
    required String address,
    required String gender,
    File? profilePic,
    BuildContext? context,
  }) async {
    final ApiService apiService = ApiService();
    const String updateProfileUrl = ApiEndpoints.updateProfileDetail;
    
    try {
      Map<String, String> fields = {
        'gender': gender,
      };
      if (name.trim().isNotEmpty) {
        fields['name'] = name.trim();
      }
      if (address.trim().isNotEmpty) {
        fields['address'] = address.trim();
      }

      final response = await apiService.postMultipartWithToken(
        updateProfileUrl,
        fields,
        imageFile: profilePic,
        imageFieldName: 'profilePic',
        context: context,
      );

      final updateResponse = ForAllResponse.fromJson(response);
      return updateResponse;
    } catch (error) {
      return ForAllResponse(
        status: false,
        message: 'Failed to update profile: $error',
      );
    }
  }

    // Update profile detail
  Future<ForAllResponse> updatePass({
    required String oldPassword,
    required String newPassword,
  }) async {
    final ApiService apiService = ApiService();
    const String updateProfileUrl = ApiEndpoints.updateProfileDetail;

    try {
      Map<String, String> bodyData = {
       "oldPassword": oldPassword,
        "newPassword": newPassword,
      };
      final response = await apiService.putDataWithToken(ApiEndpoints.updatepassword,bodyData);

      final updateResponse = ForAllResponse.fromJson(response);
      return updateResponse;
    } catch (error) {
      return ForAllResponse(
        status: false,
        message: 'Failed to update profile: $error',
      );
    }
  }

}
