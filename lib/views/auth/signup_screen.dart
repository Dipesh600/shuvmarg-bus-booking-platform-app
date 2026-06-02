import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sumarg/utils/toast_service.dart';
import 'package:sumarg/utils/dialog_service.dart';
import 'package:sumarg/widgets/custom_toast.dart';
import 'package:sumarg/utils/app_theme.dart';
import 'package:sumarg/views/auth/login_screen.dart';
import 'package:sumarg/views/auth/otp_screen.dart';
import 'package:sumarg/widgets/auth_scaffold.dart';
import 'package:sumarg/widgets/primary_button.dart';
import 'package:sumarg/widgets/custom_text_field.dart';
import '../../controllers/auth_controller/auth_controller.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    final AuthController authController = AuthController();
    setState(() {
      _isLoading = true;
    });

    final phone = _phoneController.text.trim();
    final response = await authController.register(phone);
    
    setState(() {
      _isLoading = false;
    });
    
    try {
      if (response != null && response.status) {
        ToastService.showToast(
          context: context,
          type: ToastType.success,
          msg: response.message,
        );
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreenNew(phone: phone, datakey: false),
            ),
          );
        }
      } else {
        if (mounted) {
          DialogService.showCustomDialog(
            context: context,
            type: DialogType.error,
            title: "Sign Up Failed",
            message: response?.message ?? "Registration failed. Please try again.",
            primaryButtonText: "Try Again",
            onPrimaryPressed: () {},
            secondaryButtonText: "Log In Instead",
            onSecondaryPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          );
        }
      }
    } catch (e) {
      if (mounted) {
        DialogService.showCustomDialog(
          context: context,
          type: DialogType.error,
          title: "Connection Error",
          message: "Failed to Signup! Please check your connection and try again.",
          primaryButtonText: "Try Again",
          onPrimaryPressed: () {},
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Section: Back button + Logo + Tagline ──
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      // Back Button - left aligned
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.chevron_left,
                              color: AppTheme.textPrimary,
                              size: 28,
                            ),
                            onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        }
                      },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // "Shuv Marg" logo
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                          ),
                          children: [
                            TextSpan(
                              text: 'Shuv ',
                              style: TextStyle(color: AppTheme.textPrimary),
                            ),
                            TextSpan(
                              text: 'Marg',
                              style: TextStyle(color: AppTheme.accentLime),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Safe journeys, every time',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Hero Image — seamlessly blended ──
              const SizedBox(height: 16),
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black,
                      Colors.black,
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.05, 0.75, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  'assets/images/auth/signup_hero.png',
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),

              // ── Form Section (directly on background, no card) ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // "Get Started" heading
                      const Text(
                        'Get Started',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Enter your phone number to sign up',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Phone input field
                      CustomTextField(
                        controller: _phoneController,
                        hintText: 'Enter phone number',
                        keyboardType: TextInputType.phone,
                        prefixWidget: Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🇳🇵', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 6),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.white.withOpacity(0.15),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '+977',
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  color: AppTheme.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: AppTheme.textSecondary,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (!RegExp(r'^[9][0-9]{9}$').hasMatch(value)) {
                            return 'Enter a valid 10-digit mobile number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Send OTP Button
                      PrimaryButton(
                        text: 'Send OTP',
                        isLoading: _isLoading,
                        suffixIcon: Icons.arrow_forward,
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          if (_formKey.currentState!.validate()) {
                            _handleRegister();
                          }
                        },
                      ),

                      const SizedBox(height: 24),

                      // "or" divider
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or',
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 14,
                                color: AppTheme.textSecondary.withOpacity(0.6),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // "Have an account? Log In"
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Have an account? ',
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.accentLime,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
