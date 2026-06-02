import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:sumarg/apis/api_services.dart';
import 'package:sumarg/providers/profile_provider.dart';
import 'package:sumarg/utils/api_endpoints.dart';
import 'package:sumarg/utils/app_theme.dart';

enum WalletPinMode { setup, verify }

/// A premium bottom-sheet PIN entry widget.
///
/// - **Setup mode**: User creates a new 4-digit PIN (with confirm step).
/// - **Verify mode**: User enters their PIN before a wallet payment.
///
/// Returns `true` via Navigator.pop if the operation was successful.
class WalletPinSheet extends StatefulWidget {
  final WalletPinMode mode;

  const WalletPinSheet({super.key, required this.mode});

  /// Show the sheet and return:
  /// - **Setup mode**: `true` if the PIN was set successfully, `false` otherwise.
  /// - **Verify mode**: The 4-digit PIN `String` if entered, `null` otherwise.
  ///
  /// The verify flow no longer calls a separate /verify-pin endpoint.
  /// Instead the raw PIN is returned so the caller (e.g. checkout) can pass
  /// it to the backend for atomic server-side verification at the point of debit.
  static Future<dynamic> show(BuildContext context, {required WalletPinMode mode}) async {
    final result = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WalletPinSheet(mode: mode),
    );
    // Setup returns true/false, Verify returns String?/null
    if (mode == WalletPinMode.setup) {
      return result == true;
    }
    return result; // PIN string or null
  }

  @override
  State<WalletPinSheet> createState() => _WalletPinSheetState();
}

class _WalletPinSheetState extends State<WalletPinSheet>
    with SingleTickerProviderStateMixin {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();

  bool _isConfirmStep = false; // for setup mode (enter → confirm)
  String _firstPin = '';
  bool _isLoading = false;
  String? _errorText;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 12).chain(
      CurveTween(curve: Curves.elasticIn),
    ).animate(_shakeController);

    // Auto-focus after the bottom sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  // ── Setup Flow ──
  Future<void> _handleSetupComplete(String pin) async {
    if (!_isConfirmStep) {
      // First entry — move to confirm step
      _firstPin = pin;
      setState(() {
        _isConfirmStep = true;
        _errorText = null;
      });
      _pinController.clear();
      _focusNode.requestFocus();
      return;
    }

    // Confirm step — check match
    if (pin != _firstPin) {
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0);
      setState(() {
        _errorText = 'PINs do not match. Try again.';
        _isConfirmStep = false;
        _firstPin = '';
      });
      _pinController.clear();
      _focusNode.requestFocus();
      return;
    }

    // PINs match — call API
    setState(() => _isLoading = true);
    try {
      final endpoint = '${ApiEndpoints.baseUrl}/api/wallet/setup-pin';
      await ApiService().postDataWithToken(endpoint, {'pin': pin});

      HapticFeedback.mediumImpact();

      if (mounted) {
        // Update the provider so the profile card reflects the change
        Provider.of<ProfileProvider>(context, listen: false).markWalletEnabled();
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      if (!mounted) return;
      _shakeController.forward(from: 0);
      setState(() {
        _errorText = 'Failed to set PIN. Please try again.';
        _isLoading = false;
        _isConfirmStep = false;
        _firstPin = '';
      });
      _pinController.clear();
      _focusNode.requestFocus();
    }
  }

  // ── Verify Flow ──
  // Instead of calling /verify-pin (which is now redundant since the backend
  // confirmBooking verifies the PIN atomically), we return the raw PIN to
  // the caller so it can be included in the payment request.
  Future<void> _handleVerifyComplete(String pin) async {
    HapticFeedback.mediumImpact();
    if (mounted) {
      Navigator.of(context).pop(pin); // Return the PIN string to the caller
    }
  }

  String get _title {
    if (widget.mode == WalletPinMode.setup) {
      return _isConfirmStep ? 'Confirm Your PIN' : 'Create Wallet PIN';
    }
    return 'Enter Wallet PIN';
  }

  String get _subtitle {
    if (widget.mode == WalletPinMode.setup) {
      return _isConfirmStep
          ? 'Re-enter your 4-digit PIN to confirm'
          : 'Set a 4-digit PIN to secure your wallet';
    }
    return 'Enter your 4-digit PIN to authorize this payment';
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final defaultPinTheme = PinTheme(
      width: 64,
      height: 64,
      textStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
        fontFamily: AppTheme.fontFamily,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppTheme.accentLime, width: 2),
      borderRadius: BorderRadius.circular(18),
    );

    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppTheme.accentLime.withOpacity(0.5), width: 1.5),
      borderRadius: BorderRadius.circular(18),
    );

    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppTheme.error, width: 2),
      borderRadius: BorderRadius.circular(18),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.primaryDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Drag handle ──
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Icon ──
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accentLime.withOpacity(0.12),
                  ),
                  child: Icon(
                    widget.mode == WalletPinMode.setup
                        ? Icons.lock_outline_rounded
                        : Icons.shield_outlined,
                    color: AppTheme.accentLime,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Title ──
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    _title,
                    key: ValueKey(_title),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // ── Subtitle ──
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    _subtitle,
                    key: ValueKey(_subtitle),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary.withOpacity(0.8),
                      fontFamily: AppTheme.fontFamily,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // ── PIN Input ──
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        _shakeController.isAnimating
                            ? _shakeAnimation.value *
                                ((_shakeController.value * 10).toInt().isEven ? 1 : -1)
                            : 0,
                        0,
                      ),
                      child: child,
                    );
                  },
                  child: Pinput(
                    controller: _pinController,
                    focusNode: _focusNode,
                    length: 4,
                    obscureText: true,
                    obscuringCharacter: '●',
                    useNativeKeyboard: true,
                    hapticFeedbackType: HapticFeedbackType.lightImpact,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: _errorText != null ? errorPinTheme : submittedPinTheme,
                    errorPinTheme: errorPinTheme,
                    onCompleted: _isLoading
                        ? null
                        : (pin) {
                            if (widget.mode == WalletPinMode.setup) {
                              _handleSetupComplete(pin);
                            } else {
                              _handleVerifyComplete(pin);
                            }
                          },
                  ),
                ),

                // ── Error text ──
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: _errorText != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            _errorText!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.error,
                              fontFamily: AppTheme.fontFamily,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 28),

                // ── Loading indicator ──
                if (_isLoading)
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentLime),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
