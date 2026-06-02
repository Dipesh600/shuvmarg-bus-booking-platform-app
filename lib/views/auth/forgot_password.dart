import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sumarg/utils/toast_service.dart';
import 'package:sumarg/utils/dialog_service.dart';
import 'package:sumarg/widgets/custom_toast.dart';
import 'package:sumarg/utils/app_theme.dart';
import 'package:sumarg/controllers/auth_controller/auth_controller.dart';
import 'package:sumarg/views/auth/otp_screen.dart';
import 'package:sumarg/widgets/auth_scaffold.dart';
import 'package:sumarg/widgets/glass_card.dart';
import 'package:sumarg/widgets/primary_button.dart';
import 'package:sumarg/widgets/custom_text_field.dart';
import 'package:sumarg/views/auth/login_screen.dart' as sumarg_login;

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final AuthController authController = AuthController();
      final phoneNumber = _phoneController.text.trim();
      final response = await authController.forgotPassword(phoneNumber);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response.status) {
          ToastService.showToast(
            context: context,
            type: ToastType.success,
            msg: response.message,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreenNew(phone: phoneNumber, datakey: true),
            ),
          );
        } else {
          DialogService.showCustomDialog(
            context: context,
            type: DialogType.error,
            title: "Request Failed",
            message: response.message,
            primaryButtonText: "Try Again",
            onPrimaryPressed: () {},
          );
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        DialogService.showCustomDialog(
          context: context,
          type: DialogType.error,
          title: "Connection Error",
          message: "Failed to send request. Please check your connection and try again.",
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
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacement(
                            // Fallback to login screen if there's no route to pop to
                            context,
                            MaterialPageRoute(
                              builder: (context) => const sumarg_login.LoginScreen(),
                            ),
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
                'Reset your password',
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
                          'Forgot Password?',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Enter your phone number and we'll send you a code to reset your password.",
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
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
                              return 'Please enter your mobile number';
                            }
                            if (!RegExp(r'^[9][0-9]{9}$').hasMatch(value)) {
                              return 'Enter a valid 10-digit mobile number';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        PrimaryButton(
                          text: 'Send OTP',
                          isLoading: _isLoading,
                          suffixIcon: Icons.arrow_forward,
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            _handleSubmit();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Security Info Footer ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: AppTheme.stroke,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.accentLime.withOpacity(0.5),
                          ),
                        ),
                        child: const Icon(
                          Icons.verified_user_outlined,
                          color: AppTheme.accentLime,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "We'll never share your number with anyone.",
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
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
