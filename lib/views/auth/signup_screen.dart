import 'package:sumarg/utils/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  @override
  void initState() {
    super.initState();
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
