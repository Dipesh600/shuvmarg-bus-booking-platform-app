import 'package:sumarg/utils/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sumarg/views/home_screen.dart';
import 'package:sumarg/views/otp_screen.dart';
import '../../controllers/auth_controller/auth_controller.dart';
import '../../utils/color_constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  // final _nameController = TextEditingController();
  // final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  // final _passwordController = TextEditingController();
  // final _confirmPasswordController = TextEditingController();

  bool agreeToTerms = false;
  bool showAgreementError = false;
  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool _isLoading = false;
  bool _hasAutoFetched = false;
  bool _isFetchingPhone = false;

  @override
  void initState() {
    super.initState();
    // Auto-fetch phone number when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoFetchOnLoad();
    });
  }

  @override
  void dispose() {
    // _nameController.dispose();
    // _emailController.dispose();
    _phoneController.dispose();
    // _passwordController.dispose();
    // _confirmPasswordController.dispose();
    super.dispose();
  }

  // Auto-fetch on screen load (only once)
  Future<void> _autoFetchOnLoad() async {
    if (_hasAutoFetched) return;
    _hasAutoFetched = true;
    await _fetchPhoneNumber();
  }

  // Manual fetch when button is clicked (always works)
  Future<void> _autoFetchPhoneNumber() async {
    await _fetchPhoneNumber();
  }

  // Common phone number fetching logic
  Future<void> _fetchPhoneNumber() async {
    if (_isFetchingPhone)
      return; // Prevent multiple simultaneous requests

    setState(() {
      _isFetchingPhone = true;
    });

    try {
      debugPrint('Starting phone number fetch...');

      // Request phone permission first
      bool hasPermission = await _requestPhonePermission();
      debugPrint('Permission granted: $hasPermission');

      if (hasPermission) {
        // Try to get the actual phone number from SIM
        String? phoneNumber = await _getSimPhoneNumber();
        debugPrint('Raw phone number from SIM: $phoneNumber');

        if (phoneNumber != null && phoneNumber.isNotEmpty) {
          // Process the phone number
          String processedNumber = _processPhoneNumber(phoneNumber);
          debugPrint('Processed phone number: $processedNumber');

          if (processedNumber.isNotEmpty) {
            _showPhoneNumberPopup(processedNumber);
            return;
          }
        }
      }

      // If we can't get the phone number, show input dialog
      debugPrint('Falling back to manual input dialog');
      _showPhoneNumberInputDialog();
    } catch (e) {
      debugPrint('Fetch phone number failed: $e');
      _showPhoneNumberInputDialog();
    } finally {
      setState(() {
        _isFetchingPhone = false;
      });
    }
  }

  Future<bool> _requestPhonePermission() async {
    try {
      var status = await Permission.phone.status;
      debugPrint('Current permission status: $status');

      if (status.isGranted) {
        debugPrint('Permission already granted');
        return true;
      }

      if (status.isDenied) {
        debugPrint('Requesting permission...');
        status = await Permission.phone.request();
        debugPrint('Permission request result: $status');
        return status.isGranted;
      }

      if (status.isPermanentlyDenied) {
        debugPrint('Permission permanently denied');
        _showPermissionDeniedDialog();
        return false;
      }

      debugPrint('Unknown permission status: $status');
      return false;
    } catch (e) {
      debugPrint('Permission request failed: $e');
      return false;
    }
  }

  Future<String?> _getSimPhoneNumber() async {
    try {
      debugPrint('Calling platform channel...');
      const platform = MethodChannel('phone_number_channel');
      final String? phoneNumber =
          await platform.invokeMethod('getPhoneNumber');
      debugPrint('Platform channel returned: $phoneNumber');
      return phoneNumber;
    } on PlatformException catch (e) {
      debugPrint('PlatformException: ${e.message}');
      debugPrint('Error code: ${e.code}');
      debugPrint('Error details: ${e.details}');
      return null;
    } catch (e) {
      debugPrint('General error: $e');
      return null;
    }
  }

  String _processPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Handle different formats
    if (cleanNumber.startsWith('977')) {
      // Remove country code
      cleanNumber = cleanNumber.substring(3);
    } else if (cleanNumber.startsWith('0')) {
      // Remove leading zero
      cleanNumber = cleanNumber.substring(1);
    }

    // Ensure it's 10 digits and starts with 98
    if (cleanNumber.length == 10 && cleanNumber.startsWith('98')) {
      return cleanNumber;
    }

    return '';
  }

  void _showPhoneNumberPopup(String phoneNumber) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      title: '+977 $phoneNumber',
      desc: 'Would you like to use this number for signup?',
      btnOkText: 'Yes',
      btnCancelText: 'No',
      btnOkOnPress: () {
        _phoneController.text = phoneNumber;
      },
      btnCancelOnPress: () {
        // _showPhoneNumberInputDialog();
      },
      btnOkColor: AppColors.primary,
      btnCancelColor: Colors.grey,
      dismissOnTouchOutside: false,
    ).show();
  }

  void _showPermissionDeniedDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: 'Permission Required',
      desc:
          'To automatically detect your phone number, we need permission to read your phone state. Please grant permission in settings.',
      btnOkText: 'Open Settings',
      btnCancelText: 'Enter Manually',
      btnOkOnPress: () {
        openAppSettings();
      },
      btnCancelOnPress: () {
        _showPhoneNumberInputDialog();
      },
      btnOkColor: AppColors.primary,
      btnCancelColor: Colors.grey,
      dismissOnTouchOutside: false,
    ).show();
  }

  void _showPhoneNumberInputDialog() {
    TextEditingController dialogController = TextEditingController();

    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.bottomSlide,
      title: 'Enter Your Phone Number',
      desc: 'Please enter your 10-digit phone number for signup:',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: dialogController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          decoration: InputDecoration(
            hintText: '98XXXXXXXX',
            prefixText: '+977 ',
            prefixStyle: TextStyle(fontSize: 16, color: Colors.black),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            counterText: '',
          ),
        ),
      ),
      btnOkText: 'Yes',
      btnCancelText: 'Cancel',
      btnOkOnPress: () {
        String phoneNumber = dialogController.text.trim();
        if (phoneNumber.length == 10 &&
            phoneNumber.startsWith('98')) {
          _phoneController.text = phoneNumber;
        } else {
          ToastService.showToast(
            msg:
                "Please enter a valid 10-digit phone number starting with 98",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      },
      btnCancelOnPress: () {
        // User cancelled, do nothing
      },
      btnOkColor: AppColors.primary,
      btnCancelColor: Colors.grey,
      dismissOnTouchOutside: false,
    ).show();
  }

  void _handleRegister() async {
    final AuthController authController = AuthController();
    setState(() {
      _isLoading = true;
    });

    // final name = _nameController.text.trim();
    // final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    // final password = _passwordController.text.trim();
    final response = await authController.registeer(phone);
    setState(() {
      _isLoading = false;
    });
    try {
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
        // ignore: use_build_context_synchronously
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    OtpScreenNew(phone: phone, datakey: false)));
      } else {
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
      ToastService.showToast(
        msg: "Faild to Signup!",
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F4),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_outlined,
                color: Colors.white),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const HomeScreen()))),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      const Text(
                        'OTP Verification',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join us today',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // TextFormField(
                      //   controller: _nameController,
                      //   decoration: _inputDecoration(
                      //     'Name',
                      //     'Enter name',
                      //     const Icon(Icons.person_outline),
                      //   ),
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'Please enter your name';
                      //     }
                      //     return null;
                      //   },
                      // ),
                      // const SizedBox(height: 16),
                      // TextFormField(
                      //   controller: _emailController,
                      //   decoration: _inputDecoration(
                      //     'Email',
                      //     'Enter email',
                      //     const Icon(Icons.email_outlined),
                      //   ),
                      //   keyboardType: TextInputType.emailAddress,
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'Please enter your email';
                      //     }
                      //     if (!RegExp(
                      //             r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                      //         .hasMatch(value)) {
                      //       return 'Enter a valid email';
                      //     }
                      //     return null;
                      //   },
                      // ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: _inputDecoration(
                                'Phone number',
                                'Enter phone number',
                                '+977 ',
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          // SizedBox(
                          //   height: 56,
                          //   child: ElevatedButton.icon(
                          //     onPressed: _isFetchingPhone
                          //         ? null
                          //         : _autoFetchPhoneNumber,
                          //     icon: _isFetchingPhone
                          //         ? const SizedBox(
                          //             width: 18,
                          //             height: 18,
                          //             child:
                          //                 CircularProgressIndicator(
                          //               strokeWidth: 2,
                          //               valueColor:
                          //                   AlwaysStoppedAnimation<
                          //                       Color>(Colors.white),
                          //             ),
                          //           )
                          //         : const Icon(Icons.phone_android,
                          //             color: Colors.white, size: 18),
                          //     label: Text(_isFetchingPhone
                          //         ? 'Getting...'
                          //         : 'Get'),
                          //     style: ElevatedButton.styleFrom(
                          //       backgroundColor: AppColors.primary,
                          //       foregroundColor: Colors.white,
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius:
                          //             BorderRadius.circular(12),
                          //       ),
                          //       elevation: 2,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),

                      // TextFormField(
                      //   controller: _passwordController,
                      //   obscureText: hidePassword,
                      //   decoration: _inputDecoration(
                      //     'Password',
                      //     'Enter Password',
                      //     const Icon(Icons.lock_outline),
                      //     suffixIcon: IconButton(
                      //       icon: Icon(
                      //         hidePassword
                      //             ? Icons.visibility_off
                      //             : Icons.visibility,
                      //         color: Colors.grey[600],
                      //       ),
                      //       onPressed: () {
                      //         setState(() {
                      //           hidePassword = !hidePassword;
                      //         });
                      //       },
                      //     ),
                      //   ),
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'Please enter your password';
                      //     }
                      //     if (value.length < 6) {
                      //       return 'Password must be at least 6 characters';
                      //     }
                      //     return null;
                      //   },
                      // ),
                      // const SizedBox(height: 16),
                      // TextFormField(
                      //   controller: _confirmPasswordController,
                      //   obscureText: hideConfirmPassword,
                      //   decoration: _inputDecoration(
                      //     'Confirm Password',
                      //     'Re-enter your password',
                      //     const Icon(Icons.lock_outline),
                      //     suffixIcon: IconButton(
                      //       icon: Icon(
                      //         hideConfirmPassword
                      //             ? Icons.visibility_off
                      //             : Icons.visibility,
                      //         color: Colors.grey[600],
                      //       ),
                      //       onPressed: () {
                      //         setState(() {
                      //           hideConfirmPassword =
                      //               !hideConfirmPassword;
                      //         });
                      //       },
                      //     ),
                      //   ),
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'Please confirm your password';
                      //     }
                      //     if (value != _passwordController.text) {
                      //       return 'Passwords do not match';
                      //     }
                      //     return null;
                      //   },
                      // ),
                      // const SizedBox(height: 16),
                      // Row(
                      //   crossAxisAlignment: CrossAxisAlignment.center,
                      //   children: [
                      //     Checkbox(
                      //       value: agreeToTerms,
                      //       onChanged: (value) {
                      //         setState(() {
                      //           agreeToTerms = value!;
                      //           if (value == true) {
                      //             showAgreementError = false;
                      //           }
                      //         });
                      //       },
                      //       activeColor: const Color(0xFF0A4F45),
                      //     ),
                      //     Expanded(
                      //       child: Wrap(
                      //         children: [
                      //           const Text(
                      //             'I agree with your ',
                      //             style: TextStyle(
                      //                 color: Colors.black54),
                      //           ),
                      //           GestureDetector(
                      //             onTap: () {},
                      //             child: const Text(
                      //               'Terms of Service',
                      //               style: TextStyle(
                      //                 color: Color(0xFF0A4F45),
                      //                 fontWeight: FontWeight.bold,
                      //               ),
                      //             ),
                      //           ),
                      //           const Text(
                      //             ' and ',
                      //             style: TextStyle(
                      //                 color: Colors.black54),
                      //           ),
                      //           GestureDetector(
                      //             onTap: () {},
                      //             child: const Text(
                      //               'Privacy Policy',
                      //               style: TextStyle(
                      //                 color: Color(0xFF0A4F45),
                      //                 fontWeight: FontWeight.bold,
                      //               ),
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // if (showAgreementError && !agreeToTerms)
                      //   const Padding(
                      //     padding: EdgeInsets.only(left: 12, top: 4),
                      //     child: Text(
                      //       'You must agree to the terms to continue',
                      //       style: TextStyle(color: Colors.red),
                      //     ),
                      //   ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize:
                              const Size(double.infinity, 56),
                          backgroundColor: const Color(0xFF0A4F45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        onPressed: _isLoading
                            ? null
                            : () async {
                                FocusScope.of(context).unfocus();

                                final isValid =
                                    _formKey.currentState!.validate();
                                if (isValid) {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  setState(() {
                                    _isLoading = false;
                                  });

                                  _handleRegister();
                                }
                              },
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Text.rich(
                            TextSpan(
                              text: 'Have an account? ',
                              style: TextStyle(color: Colors.black54),
                              children: [
                                TextSpan(
                                  text: 'Log In',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0A4F45),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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

  InputDecoration _inputDecoration(
    String label,
    String hint,
    String ctcode,
  ) {
    return InputDecoration(
      // labelText: label,
      hintText: hint,
      prefixText: ctcode,
      prefixStyle: TextStyle(fontSize: 16, color: Colors.black),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
    );
  }
}
