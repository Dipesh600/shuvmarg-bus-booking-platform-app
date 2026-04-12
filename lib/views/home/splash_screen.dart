import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sumarg/apis/api_services.dart';
import 'package:sumarg/utils/api_endpoints.dart';
import '../../utils/color_constants.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    bool isLogin = prefs.getBool('success') ?? false;
    String role = prefs.getString('role') ?? "passenger";
    String accessToken = prefs.getString('accessToken') ?? "notoken";

    // Safely get FCM token to prevent startup crashes on unconfigured desktop platforms
    String? token;
    try {
      token = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint("Firebase Messaging skipped: App running in local/test environment");
    }

    if (token != null) {
      await getConfigData(token, role, accessToken, isLogin);
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        if (isFirstTime) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const OnboardingScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const HomeScreen()),
          );
        }
      }
    });
  }

  Future<void> getConfigData(String firebaseToken, String role,
      String accessToken, bool isLogin) async {
    Map<String, String> data;

    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      data = {
        "token": firebaseToken,
        "userType": role,
        "os": "android",
        "osVersion": androidInfo.version.release,
        "deviceModel": androidInfo.model,
        "manufacturer": androidInfo.manufacturer,
      };
    } else if (Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      data = {
        "os": "iOS",
        "osVersion": iosInfo.systemVersion,
        "deviceModel": iosInfo.model,
        "manufacturer": 'apple',
        "token": firebaseToken,
        "userType": role
      };
    } else {
      return;
    }
    storeDeviceinfo(data);
  }

  Future<void> storeDeviceinfo(data) async {
    final ApiService apiService = ApiService();
    const String storeurl = ApiEndpoints.storedeviceinfo;
    try {
      await apiService.postDataWithToken(storeurl, data,
          context: context);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Sumarg',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 100,
              height: 100,
              child: Lottie.asset(
                'assets/animations/loading.json',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
