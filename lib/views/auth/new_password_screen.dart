import 'package:flutter/material.dart';
import 'package:sumarg/controllers/auth_controller/auth_controller.dart';
import 'package:sumarg/utils/app_theme.dart';
import 'package:sumarg/utils/toast_service.dart';
import 'package:sumarg/utils/dialog_service.dart';
import 'package:sumarg/widgets/custom_toast.dart';
import 'package:sumarg/views/auth/login_screen.dart';
import 'package:sumarg/widgets/auth_scaffold.dart';
import 'package:sumarg/widgets/custom_text_field.dart';
import 'package:sumarg/widgets/glass_card.dart';
import 'package:sumarg/widgets/primary_button.dart';

class NewPasswordScreen extends StatefulWidget {
  final String? email;
  final String? otp;
  const NewPasswordScreen({super.key, this.email, this.otp});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _submitNewPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authController = AuthController();
      final response = await authController.submitNewPassword(
        _passwordController.text.trim(),
        widget.otp,
        widget.email,
      );

      setState(() => _isLoading = false);

      if (response.status) {
        ToastService.showToast(
          context: context,
          type: ToastType.success,
          msg: response.message,
        );
      } else {
        DialogService.showCustomDialog(
          context: context,
          type: DialogType.error,
          title: "Update Failed",
          message: response.message,
          primaryButtonText: "Try Again",
          onPrimaryPressed: () {},
        );
      }

      if (response.status) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Back Button ──
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 8.0, bottom: 20.0),
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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    // ── Header ──
                    const Text(
                      'Create New Password',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Enter your new password and confirm it to proceed.',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 15,
                        height: 1.5,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    
                    const SizedBox(height: 48),

                    // ── Form Card ──
                    GlassCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: _passwordController,
                              hintText: 'New Password',
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                  color: AppTheme.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your new password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 20),
                            
                            CustomTextField(
                              controller: _confirmPasswordController,
                              hintText: 'Confirm Password',
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: _obscureConfirmPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                  color: AppTheme.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
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

                            const SizedBox(height: 32),

                            PrimaryButton(
                              text: 'Reset Password',
                              isLoading: _isLoading,
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                _submitNewPassword();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

