import 'dart:io';
import 'dart:math' as math;
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
  late Animation<double> _busAnimation;
  late Animation<double> _glowPulseAnimation;
  
  bool _isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200), // Slightly longer to appreciate the bus detail
    );

    // Laser text reveal sweep
    _textRevealAnimation = Tween<double>(begin: -0.1, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );

    // Speed Controlled Bus Route (ease in/out cubic slows it perfectly in the middle)
    _busAnimation = Tween<double>(begin: -1.2, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.90, curve: Curves.easeInOutCubic),
      ),
    );

    // Final screen pulse lock-in
    _glowPulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 0.90, curve: Curves.easeOut),
      ),
    );

    _startBootSequence();
  }

  Future<void> _startBootSequence() async {
    _controller.forward();
    await _fetchInitialData();
    
    if (!_controller.isCompleted) {
      await _controller.forward(); 
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
    final String storeurl = ApiEndpoints.storedeviceinfo;
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
                  height: 140,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // PHASE 1: KINETIC LASER REVEAL (Typography)
                      // Shifted slightly up so the bus fits nicely underneath
                      Positioned(
                        top: 20,
                        child: ShaderMask(
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
                              fontSize: 54,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 2.5,
                              color: Colors.white, 
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
                      ),

                      // PHASE 2: ANIMATED LUXURY BUS
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Align(
                          alignment: Alignment(_busAnimation.value, 0.0),
                          child: Opacity(
                            opacity: _busAnimation.value > -1.1 && _busAnimation.value < 1.1 ? 1.0 : 0.0,
                            child: _DetailedAnimatedBus(animationProgress: _busAnimation.value),
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

/// A highly detailed, custom-painted Bus widget entirely built in Flutter.
/// Includes chassis profiling, windows, and independently rotating wheels based on velocity.
class _DetailedAnimatedBus extends StatelessWidget {
  final double animationProgress;
  const _DetailedAnimatedBus({required this.animationProgress});

  @override
  Widget build(BuildContext context) {
    // Ground shadow scales slightly off the animation curve
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // BUS CHASSIS
            Container(
              height: 38,
              width: 120,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(4),
                  topRight: Radius.circular(20), // Aerodynamic front
                  bottomRight: Radius.circular(6),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Windows / Glass Panel
                  Positioned(
                    top: 6,
                    left: 20, // Leave some trunk space
                    right: 6, // Windshield curve
                    child: Container(
                      height: 14,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryDarker, // Dark tinted glass
                        borderRadius: BorderRadius.only(
                           topLeft: Radius.circular(2),
                           topRight: Radius.circular(8),
                           bottomRight: Radius.circular(2),
                           bottomLeft: Radius.circular(2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (index) {
                          return Container(
                            width: 2,
                            color: AppColors.secondary.withValues(alpha: 0.5), // Window dividers matching chassis
                          );
                        }),
                      ),
                    ),
                  ),
                  // Headlight Glow
                  Positioned(
                    right: 0,
                    bottom: 8,
                    child: Container(
                      width: 6,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
                        boxShadow: [
                           BoxShadow(color: Colors.white.withValues(alpha: 0.8), blurRadius: 8, spreadRadius: 2, offset: const Offset(4, 0))
                        ]
                      ),
                    ),
                  )
                ],
              ),
            ),
            
            // BACK WHEEL
            Positioned(
              bottom: -6,
              left: 20,
              child: _SpinningWheel(rotationAngle: animationProgress * math.pi * 12),
            ),

            // FRONT WHEEL
            Positioned(
              bottom: -6,
              right: 25,
              child: _SpinningWheel(rotationAngle: animationProgress * math.pi * 12),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        // GROUND SHADOW
        Container(
          height: 4,
          width: 100,
          decoration: BoxDecoration(
             color: Colors.black.withValues(alpha: 0.4),
             borderRadius: BorderRadius.circular(100),
             boxShadow: [
               BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6, spreadRadius: 4)
             ]
          ),
        )
      ],
    );
  }
}

/// Individual wheel widget wrapped in a native Transform.rotate
class _SpinningWheel extends StatelessWidget {
  final double rotationAngle;
  const _SpinningWheel({required this.rotationAngle});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotationAngle,
      child: Container(
        height: 16,
        width: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF222222), // Dark tire
          border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5), // Inner Rim
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Center Cap
            Container(height: 4, width: 4, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
            // Spokes
            Container(width: 14, height: 1.5, color: Colors.white.withValues(alpha: 0.4)),
            Container(height: 14, width: 1.5, color: Colors.white.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }
}
