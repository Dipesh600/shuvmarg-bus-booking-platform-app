import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sumarg/utils/toast_service.dart';
import 'package:sumarg/utils/dialog_service.dart';
import 'package:sumarg/widgets/custom_toast.dart';
import 'package:sumarg/utils/app_theme.dart';
import 'package:sumarg/utils/navigation_service.dart';
import 'package:sumarg/views/auth/signup_screen.dart';
import 'package:sumarg/views/auth/forgot_password.dart';
import 'package:sumarg/views/home/home_screen.dart';
import 'package:sumarg/widgets/auth_scaffold.dart';
import 'package:sumarg/widgets/glass_card.dart';
import 'package:sumarg/widgets/primary_button.dart';
import 'package:sumarg/widgets/custom_text_field.dart';
import '../../controllers/auth_controller/auth_controller.dart';
import '../../controllers/auth_controller/login_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool hidePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final AuthController authController = AuthController();
    setState(() {
      _isLoading = true;
    });

    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final response = await authController.login(phone, password);
    
    setState(() {
      _isLoading = false;
    });
    
    try {
      if (response != null && response.success) {
        await Provider.of<LoginProvider>(context, listen: false).login(phone, password);

        ToastService.showToast(
          context: context,
          type: ToastType.success,
          msg: response.message,
        );

        if (mounted) {
          await NavigationService.navigateAfterLogin(context);
        }
      } else {
        if (mounted) {
          DialogService.showCustomDialog(
            context: context,
            type: DialogType.error,
            title: "Login Failed",
            message: response?.message ?? "Incorrect phone number or password.",
            primaryButtonText: "Try Again",
            onPrimaryPressed: () {},
            secondaryButtonText: "Forgot Password?",
            onSecondaryPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ForgotPassword()),
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
          message: "Failed to login! Please check your connection and try again.",
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
                      onPressed: () async {
                        final hasRedirect = await NavigationService.hasRedirectData();
                        if (hasRedirect) {
                          await NavigationService.clearRedirectData();
                        }
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const HomeScreen())
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),

              // ── App Logo / Header ──
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
                'Welcome back!',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textSecondary,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // ── Glass Card Form ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: GlassCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Login',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Enter your details to continue',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        CustomTextField(
                          controller: _phoneController,
                          hintText: 'Phone number',
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
                        
                        const SizedBox(height: 12),
                        
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ForgotPassword()),
                              );
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accentLime,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        PrimaryButton(
                          text: 'Log In',
                          isLoading: _isLoading,
                          suffixIcon: Icons.arrow_forward,
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            if (_formKey.currentState!.validate()) {
                              _handleLogin();
                            }
                          },
                        ),

                        // "or" divider (optional, keeping consistent with reference's overall style if not skipping Google)
                        // Skipping Google means we just end the card here.
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
                    "Don't have an account? ",
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
                        MaterialPageRoute(builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: const Text(
                      'Sign Up',
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
              
              const SizedBox(height: 16),
              
              // ── Security Note ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user_outlined, color: AppTheme.secondary, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'Your data is safe and secure with us',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      color: AppTheme.secondary,
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

