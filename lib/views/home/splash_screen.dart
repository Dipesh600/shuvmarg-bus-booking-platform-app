import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sumarg/apis/api_services.dart';
import 'package:sumarg/utils/api_endpoints.dart';
import '../../utils/color_constants.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _textRevealAnimation;
  late Animation<double> _streakAnimation;
  late Animation<double> _glowPulseAnimation;
  
  bool _isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Laser text reveal sweep
    _textRevealAnimation = Tween<double>(begin: -0.1, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );

    // Bus velocity streak zooming across
    _streakAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 0.65, curve: Curves.easeInOutBack),
      ),
    );

    // Final screen pulse lock-in
    _glowPulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 0.85, curve: Curves.easeOut),
      ),
    );

    _startBootSequence();
  }

  Future<void> _startBootSequence() async {
    // Fire the animation and background API network requests concurrently
    _controller.forward();
    await _fetchInitialData();
    
    // Safety lock: ensuring the animation fully complete before redirecting
    if (!_controller.isCompleted) {
      await _controller.forward(); // blocks until 2500ms is perfectly reached
    }
    
    if (mounted) {
      if (_isFirstTime) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const OnboardingScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    }
  }

  Future<void> _fetchInitialData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isFirstTime = prefs.getBool('isFirstTime') ?? true;
    bool isLogin = prefs.getBool('success') ?? false;
    String role = prefs.getString('role') ?? "passenger";
    String accessToken = prefs.getString('accessToken') ?? "notoken";

    String? token;
    try {
      token = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint("Firebase Messaging skipped: App running in local/test environment");
    }

    if (token != null) {
      await getConfigData(token, role, accessToken, isLogin);
    }
  }

  Future<void> getConfigData(String firebaseToken, String role, String accessToken, bool isLogin) async {
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
      await apiService.postDataWithToken(storeurl, data, context: context);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // Dark Teal (#005248)
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 120,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // PHASE 1: KINETIC LASER REVEAL (Typography)
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: const [
                              AppColors.secondary, // Vibrant Orange Glow
                              AppColors.secondary,
                              Colors.transparent,
                            ],
                            stops: [
                              0.0,
                              _textRevealAnimation.value,
                              _textRevealAnimation.value + 0.1,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.srcIn,
                        child: Text(
                          'shuvmarg',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 2.5,
                            color: Colors.white, // Base color overwritten by shader mask
                            shadows: [
                              Shadow(
                                color: AppColors.secondary.withValues(alpha: _glowPulseAnimation.value * 0.8),
                                blurRadius: 25 * _glowPulseAnimation.value,
                                offset: const Offset(0, 0),
                              ),
                            ]
                          ),
                        ),
                      ),

                      // PHASE 2: VELOCITY STREAK (Bus laser zoom)
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Align(
                          alignment: Alignment(_streakAnimation.value, 0.0),
                          child: Opacity(
                            opacity: _streakAnimation.value > -0.9 && _streakAnimation.value < 0.9 ? 1.0 : 0.0,
                            child: Container(
                              height: 4,
                              width: 90, // Aerodynamic bus length
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.secondary.withValues(alpha: 0.9),
                                    blurRadius: 15,
                                    spreadRadius: 3,
                                  ),
                                  BoxShadow(
                                    color: AppColors.secondary.withValues(alpha: 0.4),
                                    blurRadius: 25,
                                    spreadRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
