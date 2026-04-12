import 'package:sumarg/utils/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:sumarg/utils/color_constants.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sumarg/controllers/auth_controller/auth_controller.dart';

class ChangeProfilePicture extends StatefulWidget {
  final String profilePic;
  final String name;
  const ChangeProfilePicture({
    super.key,
    required this.profilePic,
    required this.name,
  });

  @override
  State<ChangeProfilePicture> createState() =>
      _ChangeProfilePictureState();
}

class _ChangeProfilePictureState extends State<ChangeProfilePicture> {
  late TextEditingController nameController;
  late TextEditingController addressController;
  final _formKey = GlobalKey<FormState>();
  File? _pickedImage;
  String gender = 'female';
  String? phone;
  String? email;
  final AuthController _authController = AuthController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    addressController = TextEditingController();
    _loadUserContact();
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserContact() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        phone = prefs.getString('phone');
        email = prefs.getString('email');
      });
    } catch (_) {}
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.of(context).pop();
                try {
                  final pickedFile = await picker.pickImage(
                      source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _pickedImage = File(pickedFile.path);
                    });
                  }
                } catch (e) {
                  ToastService.showToast(
                    msg: 'Failed to pick image: $e',
                    toastLength: Toast.LENGTH_SHORT,
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.of(context).pop();
                try {
                  final pickedFile = await picker.pickImage(
                      source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() {
                      _pickedImage = File(pickedFile.path);
                    });
                  }
                } catch (e) {
                  ToastService.showToast(
                    msg: 'Failed to pick image: $e',
                    toastLength: Toast.LENGTH_SHORT,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      
      setState(() {
        _isSubmitting = true;
      });

      try {
        final response = await _authController.updateProfile(
          name: nameController.text.trim(),
          address: addressController.text.trim(),
          gender: gender,
          profilePic: _pickedImage,
          context: context,
        );

        if (!mounted) return;

        if (response.status) {
          // Update SharedPreferences with new name
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('name', nameController.text.trim());

          ToastService.showToast(
            msg: response.message.isNotEmpty ? response.message : 'Profile updated successfully!',
            toastLength: Toast.LENGTH_SHORT,
          );
          if (mounted) {
            Navigator.pop(context, true);
          }
        } else {
          ToastService.showToast(
            msg: response.message.isNotEmpty ? response.message : 'Failed to update profile',
            toastLength: Toast.LENGTH_SHORT,
          );
        }
      } catch (e) {
        if (!mounted) return;
        ToastService.showToast(
          msg: 'Error updating profile: $e',
          toastLength: Toast.LENGTH_SHORT,
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  InputDecoration _inputDecoration(String label, String hint,
      {Widget? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
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
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal information'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 24.0, vertical: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 80,
                          backgroundImage: _pickedImage != null
                              ? FileImage(_pickedImage!)
                              : NetworkImage(widget.profilePic)
                                  as ImageProvider,
                          backgroundColor: Colors.grey[200],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextFormField(
                      controller: nameController,
                      decoration: _inputDecoration(
                          'Edit Name', 'Enter your name',
                          prefixIcon: const Icon(Icons.person)),
                      style: const TextStyle(fontSize: 16),
                      validator: (value) {
                        // Optional field: allow empty
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Phone (read-only)
                  if (phone != null && phone!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextFormField(
                        initialValue: phone,
                        enabled: false,
                        decoration: _inputDecoration(
                          'Phone number', 'Your phone number',
                          prefixIcon: const Icon(Icons.phone),
                        ),
                        style: const TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ),
                  const SizedBox(height: 12),
                  // Email (read-only)
                  if (email != null && email!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextFormField(
                        initialValue: email,
                        enabled: false,
                        decoration: _inputDecoration(
                          'Email', 'Your email address',
                          prefixIcon: const Icon(Icons.email),
                        ),
                        style: const TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Address
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextFormField(
                      controller: addressController,
                      decoration: _inputDecoration(
                        'Address', 'Enter your address',
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                      style: const TextStyle(fontSize: 16),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        // Optional field: allow empty
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Gender radios
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Gender', style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                value: 'female',
                                groupValue: gender,
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Female'),
                                activeColor: AppColors.primary,
                                onChanged: (v) {
                                  setState(() { gender = v!; });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                value: 'male',
                                groupValue: gender,
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Male'),
                                activeColor: AppColors.primary,
                                onChanged: (v) {
                                  setState(() { gender = v!; });
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        elevation: 2,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Submit'),
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
}
