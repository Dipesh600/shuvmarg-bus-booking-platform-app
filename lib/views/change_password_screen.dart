import 'package:sumarg/utils/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:sumarg/utils/color_constants.dart';
import 'package:sumarg/controllers/auth_controller/auth_controller.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _hideOld = true;
  bool _hideNew = true;
  bool _hideConfirm = true;
  bool _submitting = false;

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    try {
      final controller = AuthController();
      final res = await controller.updatePass(
        oldPassword: _oldController.text.trim(),
        newPassword: _newController.text.trim(),
      );
      if (res.status == true) {
        ToastService.showToast(msg: res.message ?? 'Password updated successfully');
        _oldController.clear();
        _newController.clear();
        _confirmController.clear();
        if (mounted) Navigator.of(context).pop();
      } else {
        ToastService.showToast(msg: res.message ?? 'Failed to update password');
      }
    } catch (e) {
      ToastService.showToast(msg: 'Something went wrong');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  InputDecoration _decoration(String label, {required bool obscured, required VoidCallback onToggle}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primaryLight.withOpacity(0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
      suffixIcon: IconButton(
        onPressed: onToggle,
        icon: Icon(
          obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = Theme.of(context)
        .textTheme
        .titleLarge
        ?.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w700);
    final help = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: AppColors.text.withOpacity(0.75));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Secure your account', style: title),
              const SizedBox(height: 8),
              Text('Use a strong password with at least 8 characters.', style: help),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _oldController,
                      obscureText: _hideOld,
                      decoration: _decoration(
                        'Current password',
                        obscured: _hideOld,
                        onToggle: () => setState(() => _hideOld = !_hideOld),
                      ),
                      validator: (v) {
                        if ((v ?? '').isEmpty) return 'Enter current password';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _newController,
                      obscureText: _hideNew,
                      decoration: _decoration(
                        'New password',
                        obscured: _hideNew,
                        onToggle: () => setState(() => _hideNew = !_hideNew),
                      ),
                      validator: (v) {
                        final val = v ?? '';
                        if (val.isEmpty) return 'Enter new password';
                        if (val.length < 8) return 'Password must be at least 8 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: _hideConfirm,
                      decoration: _decoration(
                        'Confirm new password',
                        obscured: _hideConfirm,
                        onToggle: () => setState(() => _hideConfirm = !_hideConfirm),
                      ),
                      validator: (v) {
                        final val = v ?? '';
                        if (val.isEmpty) return 'Re-enter new password';
                        if (val.length < 8) return 'Password must be at least 8 characters';
                        if (val != _newController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _submitting ? null : _submit,
                        child: _submitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Update Password'),
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