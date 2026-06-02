import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:sumarg/controllers/auth_controller/auth_controller.dart';
import 'package:sumarg/utils/app_theme.dart';
import 'package:sumarg/utils/toast_service.dart';
import 'package:sumarg/utils/dialog_service.dart';
import 'package:sumarg/widgets/custom_toast.dart';
import 'package:sumarg/views/auth/signup_next_screen.dart';
import 'package:sumarg/views/auth/new_password_screen.dart';
import 'package:sumarg/views/auth/login_screen.dart' as sumarg_login;
import 'package:sumarg/widgets/auth_scaffold.dart';
import 'package:sumarg/widgets/glass_card.dart';
import 'package:sumarg/widgets/primary_button.dart';

class OtpScreenNew extends StatefulWidget {
  final String? phone;
  final bool? datakey; // false = Registration, true = Forgot Password
  const OtpScreenNew({
    super.key,
    this.phone,
    this.datakey,
  });

  @override
  _OtpScreenNewState createState() => _OtpScreenNewState();
}

class _OtpScreenNewState extends State<OtpScreenNew> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();
  String? _errorMessage;
  bool _isLoading = false;
  bool _canResend = false;
  int _resendCountdown = 45;
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (_resendCountdown > 0) {
            _resendCountdown--;
            _startResendTimer();
          } else {
            _canResend = true;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(String otp) async {
    if (otp.length == 6) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      widget.datakey == false
          ? await _verifyOtp(otp)
          : await _verifyOtpForPassReset(widget.phone!, otp);
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = 'Please enter a valid 6-digit OTP';
      });
      DialogService.showCustomDialog(
        context: context,
        type: DialogType.error,
        title: "Invalid Input",
        message: 'Please enter a valid 6-digit OTP.',
        primaryButtonText: "Okay",
        onPrimaryPressed: () {},
      );
    }
  }

  Future<void> _verifyOtpForPassReset(String phone, String otp) async {
    try {
      final response = await _authController.verifyOtpForResetPass(phone, otp);
      if (response != null && response.status) {
        ToastService.showToast(
          context: context,
          type: ToastType.success,
          msg: response.message,
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    NewPasswordScreen(email: phone, otp: otp)),
          );
        }
      } else {
        setState(() {
          _errorMessage = response.message;
        });
        DialogService.showCustomDialog(
          context: context,
          type: DialogType.error,
          title: "Verification Failed",
          message: response.message,
          primaryButtonText: "Try Again",
          onPrimaryPressed: () {},
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to verify OTP';
      });
      DialogService.showCustomDialog(
        context: context,
        type: DialogType.error,
        title: "Connection Error",
        message: 'Failed to verify OTP! Please check your connection.',
        primaryButtonText: "Okay",
        onPrimaryPressed: () {},
      );
    }
  }

  Future<void> _verifyOtp(String otp) async {
    try {
      final response = await _authController.otpVerification(widget.phone!, otp);
      if (response != null && response.status) {
        ToastService.showToast(
          context: context,
          type: ToastType.success,
          msg: response.message,
        );
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => SignUpNextScreen(
                      phone: widget.phone.toString(),
                    )),
          );
        }
      } else {
        setState(() {
          _errorMessage = response?.message ?? 'Invalid OTP';
        });
        DialogService.showCustomDialog(
          context: context,
          type: DialogType.error,
          title: "Verification Failed",
          message: response?.message ?? 'Invalid OTP',
          primaryButtonText: "Try Again",
          onPrimaryPressed: () {},
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to verify OTP';
      });
      DialogService.showCustomDialog(
        context: context,
        type: DialogType.error,
        title: "Connection Error",
        message: 'Failed to verify OTP! Please check your connection.',
        primaryButtonText: "Okay",
        onPrimaryPressed: () {},
      );
    }
  }

  Future<void> _resendOtp() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = widget.datakey == false
          ? await _authController.resendOtpForRegistration(widget.phone!)
          : await _authController.resendOtp(widget.phone!);

      setState(() {
        _isLoading = false;
      });

      if (response != null) {
        if (response.status) {
          ToastService.showToast(
            context: context,
            type: ToastType.otpSent,
            msg: response.message,
          );
        } else {
          DialogService.showCustomDialog(
            context: context,
            type: DialogType.error,
            title: "Failed to Send",
            message: response.message,
            primaryButtonText: "Okay",
            onPrimaryPressed: () {},
          );
        }

        if (response.status) {
          _otpController.clear();
          _otpFocusNode.requestFocus();
          setState(() {
            _canResend = false;
            _resendCountdown = 45;
          });
          _startResendTimer();
        }
      } else {
        DialogService.showCustomDialog(
          context: context,
          type: DialogType.error,
          title: "Failed",
          message: 'Failed to resend OTP',
          primaryButtonText: "Okay",
          onPrimaryPressed: () {},
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      DialogService.showCustomDialog(
        context: context,
        type: DialogType.error,
        title: "Connection Error",
        message: 'Failed to resend OTP',
        primaryButtonText: "Okay",
        onPrimaryPressed: () {},
      );
    }
  }

  Widget _buildGlowingIcon() {
    return Container(
      height: 140,
      width: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.accentLime.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Center(
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.accentLime.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Center(
            child: Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryDark.withOpacity(0.5),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentLime.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.smartphone_rounded,
                    color: AppTheme.accentLime,
                    size: 38,
                  ),
                  Positioned(
                    top: 2,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryDark,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.mark_chat_unread_rounded,
                        color: AppTheme.accentLime,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String get _formattedTime {
    final minutes = (_resendCountdown / 60).floor().toString().padLeft(2, '0');
    final seconds = (_resendCountdown % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: const TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        borderRadius: BorderRadius.circular(14),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppTheme.accentLime, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: AppTheme.accentLime.withOpacity(0.15),
          blurRadius: 14,
          spreadRadius: 2,
        ),
      ],
    );

    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Colors.redAccent, width: 1.5),
    );

    return AuthScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Back Button ──
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
                              builder: (context) => const sumarg_login.LoginScreen(),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── Glowing Hero Icon ──
              _buildGlowingIcon(),

              const SizedBox(height: 24),

              // ── Headers ──
              const Text(
                'OTP Sent!',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'We have sent a 6-digit OTP to',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '+977 ${widget.phone ?? ''}',
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accentLime,
                ),
              ),

              const SizedBox(height: 40),

              // ── Main OTP Form Card ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Enter OTP',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please enter the 6-digit code\nsent to your number',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 14,
                          height: 1.4,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // ── Pinput ──
                      Center(
                        child: Pinput(
                          controller: _otpController,
                          focusNode: _otpFocusNode,
                          length: 6,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: focusedPinTheme,
                          errorPinTheme: errorPinTheme,
                          showCursor: true,
                          cursor: Container(
                            width: 2,
                            height: 24,
                            color: AppTheme.accentLime,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _errorMessage = null;
                            });
                          },
                          onCompleted: (pin) => _handleSubmit(pin),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Center(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                color: Colors.redAccent,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 32),

                      // ── Resend Timer ──
                      Center(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Resend OTP in ',
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: (_canResend && !_isLoading) ? _resendOtp : null,
                                  child: Text(
                                    _canResend ? 'Now' : _formattedTime,
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: (_canResend && !_isLoading) 
                                          ? AppTheme.accentLime 
                                          : AppTheme.accentLime.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Verify Button ──
                      PrimaryButton(
                        text: 'Verify OTP',
                        isLoading: _isLoading,
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          _handleSubmit(_otpController.text);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Support Card ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: GlassCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryDark.withOpacity(0.5),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.accentLime.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.headset_mic_rounded,
                          color: AppTheme.accentLime,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Need help?',
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Contact our support team',
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
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

