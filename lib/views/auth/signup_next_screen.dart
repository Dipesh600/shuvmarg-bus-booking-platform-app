import 'package:flutter/material.dart';
import 'package:sumarg/utils/toast_service.dart';
import 'package:sumarg/utils/dialog_service.dart';
import 'package:sumarg/widgets/custom_toast.dart';
import 'package:sumarg/views/auth/login_screen.dart';
import 'package:sumarg/views/home/home_screen.dart';
import 'package:sumarg/controllers/auth_controller/auth_controller.dart';
import 'package:sumarg/utils/app_theme.dart';
import 'package:sumarg/widgets/auth_scaffold.dart';
import 'package:sumarg/widgets/glass_card.dart';
import 'package:sumarg/widgets/primary_button.dart';
import 'package:sumarg/widgets/custom_text_field.dart';

class SignUpNextScreen extends StatefulWidget {
  final String phone;
  const SignUpNextScreen({super.key, required this.phone});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpNextScreenState createState() => _SignUpNextScreenState();
}

class _SignUpNextScreenState extends State<SignUpNextScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _refralController = TextEditingController();

  bool agreeToTerms = false;
  bool showAgreementError = false;
  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _refralController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    final AuthController authController = AuthController();
    setState(() {
      _isLoading = true;
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final referralCode = _refralController.text.trim();
    Map<String, dynamic> data = {
      "name": name,
      "phone": widget.phone,
      "address": "kathmandu",
      "password": password,
      "gender": "male",
      if (email.isNotEmpty) "email": email,
      if (referralCode.isNotEmpty) "referralCode": referralCode,
    };
    final response = await authController.registeerNextStape(data);
    print("day res ${response.status}");
    setState(() {
      _isLoading = false;
    });
    try {
      if (response.status) {
        ToastService.showToast(
          context: context,
          type: ToastType.success,
          msg: response.message,
        );
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } else {
        DialogService.showCustomDialog(
          context: context,
          type: DialogType.error,
          title: "Setup Failed",
          message: response.message,
          primaryButtonText: "Try Again",
          onPrimaryPressed: () {},
        );
      }
    } catch (e) {
      DialogService.showCustomDialog(
        context: context,
        type: DialogType.error,
        title: "Connection Error",
        message: "Failed to create account. Please check your connection and try again.",
        primaryButtonText: "Try Again",
        onPrimaryPressed: () {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Top Section: Back button ──
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 8.0, bottom: 20.0),
                child: Align(
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
                                builder: (context) => const HomeScreen()),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),

              // ── Headers ──
              const Text(
                'Complete Your\nRegistration',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Join us today',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // ── Glass Card Form ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: GlassCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          controller: _nameController,
                          hintText: 'Full Name',
                          prefixIcon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _emailController,
                          hintText: 'Email (Optional)',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Enter a valid email';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          obscureText: hidePassword,
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppTheme.textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                hidePassword = !hidePassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _confirmPasswordController,
                          hintText: 'Confirm Password',
                          obscureText: hideConfirmPassword,
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              hideConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppTheme.textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                hideConfirmPassword = !hideConfirmPassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _refralController,
                          hintText: 'Referral Code (Optional)',
                          prefixIcon: Icons.group_add_outlined,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 12, top: 6),
                          child: Text(
                            'This field is optional - you can skip it',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 12,
                              color: AppTheme.textSecondary.withOpacity(0.7),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: agreeToTerms,
                              onChanged: (value) {
                                setState(() {
                                  agreeToTerms = value!;
                                  if (value == true) {
                                    showAgreementError = false;
                                  }
                                });
                              },
                              activeColor: AppTheme.accentLime,
                              checkColor: AppTheme.primaryDark,
                              side: const BorderSide(color: AppTheme.textSecondary, width: 1.5),
                            ),
                            Expanded(
                              child: Wrap(
                                children: [
                                  const Text(
                                    'I agree with your ',
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontFamily,
                                      color: AppTheme.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: const Text(
                                      'Terms of Service',
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontFamily,
                                        color: AppTheme.accentLime,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    ' and ',
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontFamily,
                                      color: AppTheme.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: const Text(
                                      'Privacy Policy',
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontFamily,
                                        color: AppTheme.accentLime,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (showAgreementError && !agreeToTerms)
                          const Padding(
                            padding: EdgeInsets.only(left: 12, top: 4),
                            child: Text(
                              'You must agree to the terms to continue',
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                color: Colors.redAccent,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          text: 'Complete Setup',
                          isLoading: _isLoading,
                          suffixIcon: Icons.check_circle_outline,
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            final isValid = _formKey.currentState!.validate();
                            setState(() {
                              showAgreementError = !agreeToTerms;
                            });
                            if (isValid && agreeToTerms) {
                              _handleRegister();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Footer ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Have an account? ",
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
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
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
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
