import 'package:sumarg/utils/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pinput.dart';
import 'package:sumarg/controllers/auth_controller/auth_controller.dart';
import 'package:sumarg/utils/color_constants.dart';
import 'package:sumarg/views/auth/signup_next_screen.dart';
import 'package:sumarg/views/auth/new_password_screen.dart';

class OtpScreenNew extends StatefulWidget {
  final String? phone;
  final bool? datakey;
  const OtpScreenNew({
    super.key,
    this.phone,
    this.datakey,
  });

  @override
  // ignore: library_private_types_in_public_api
  _OtpScreenNewState createState() => _OtpScreenNewState();
}

class _OtpScreenNewState extends State<OtpScreenNew> {
  final TextEditingController _otpController =
      TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();
  String? _errorMessage;
  bool _isLoading = false;
  bool _canResend = true;
  int _resendCountdown = 30;
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
    if (otp.length == 4) {
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
        _errorMessage = 'Please enter a valid 4-digit OTP';
      });
      ToastService.showToast(
        msg: 'Please enter a valid 4-digit OTP',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> _verifyOtpForPassReset(
      String email, String otp) async {
    try {
      final response = await _authController.verifyOtpForResetPass(
          widget.phone!, otp);
      if (response != null && response.status) {
        ToastService.showToast(
          msg: response.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    NewPasswordScreen(email: widget.phone, otp: otp)),
          );
        }
      } else {
        setState(() {
          _errorMessage = response.message;
        });
        ToastService.showToast(
          msg: response.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to verify OTP';
      });
      ToastService.showToast(
        msg: 'Failed to verify OTP!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> _resendOtp() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Use different resend method based on context
      final response = widget.datakey == false
          ? await _authController
              .resendOtpForRegistration(widget.phone!)
          : await _authController.resendOtp(widget.phone!);

      setState(() {
        _isLoading = false;
      });

      if (response != null) {
        ToastService.showToast(
          msg: response.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor:
              response.status ? Colors.black : Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        if (response.status) {
          // Clear OTP field and show success message
          _otpController.clear();
          _otpFocusNode.requestFocus();

          // Reset countdown timer
          setState(() {
            _canResend = false;
            _resendCountdown = 30;
          });
          _startResendTimer();
        }
      } else {
        ToastService.showToast(
          msg: 'Failed to resend OTP',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ToastService.showToast(
        msg: 'Failed to resend OTP',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> _verifyOtp(String otp) async {
    try {
      final response =
          await _authController.otpVerification(widget.phone!, otp);
      if (response != null && response.status) {
        ToastService.showToast(
          msg: response.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
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
        ToastService.showToast(
          msg: response?.message ?? 'Invalid OTP',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to verify OTP';
      });
      ToastService.showToast(
        msg: 'Failed to verify OTP!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define Pinput themes
    final defaultPinTheme = PinTheme(
      width: 70,
      height: 70,
      textStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color(0xFF0A4F45), width: 2),
    );

    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Colors.red, width: 2),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F4),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0A4F45), Color(0xFF147E70)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(80),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Sumarg',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    const Text(
                      'Verify Your Phone Number',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the 4-digit code sent to your Phone Number',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        widget.phone ?? 'No email provided',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: Pinput(
                        controller: _otpController,
                        focusNode: _otpFocusNode,
                        length: 4,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        errorPinTheme: errorPinTheme,
                        showCursor: true,
                        onChanged: (value) {
                          setState(() {
                            _errorMessage =
                                null; // Clear error on input
                          });
                        },
                        onCompleted: (pin) => _handleSubmit(pin),
                        errorText: _errorMessage,
                        errorTextStyle:
                            const TextStyle(color: Colors.red),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Didn't receive code? ",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: (_canResend && !_isLoading)
                                    ? _resendOtp
                                    : null,
                                child: Text(
                                  _canResend
                                      ? 'Resend code'
                                      : 'Resend code in $_resendCountdown seconds',
                                  style: TextStyle(
                                    color: (_canResend && !_isLoading)
                                        ? const Color(0xFF0A4F45)
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      onPressed: _isLoading
                          ? null
                          : () => _handleSubmit(_otpController.text),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white)
                          : const Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
