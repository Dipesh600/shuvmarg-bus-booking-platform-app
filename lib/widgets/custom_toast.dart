import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sumarg/utils/app_theme.dart';

enum ToastType {
  success,
  error,
  info,
  warning,
  otpSent,
  noConnection,
}

class CustomToast extends StatefulWidget {
  final ToastType type;
  final String title;
  final String message;
  final VoidCallback? onClose;
  final Duration duration;

  const CustomToast({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.onClose,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<CustomToast> createState() => _CustomToastState();
}

class _CustomToastState extends State<CustomToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Color get _accentColor {
    switch (widget.type) {
      case ToastType.success:
      case ToastType.otpSent:
        return const Color(0xFF00C9A7); // Teal green
      case ToastType.error:
      case ToastType.noConnection:
        return const Color(0xFFFF5C5C); // Coral red
      case ToastType.info:
        return const Color(0xFF4DA6FF); // Sky blue
      case ToastType.warning:
        return AppTheme.accentLime;
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case ToastType.success:
        return Icons.check_circle_rounded;
      case ToastType.error:
        return Icons.error_rounded;
      case ToastType.info:
        return Icons.info_rounded;
      case ToastType.warning:
        return Icons.warning_rounded;
      case ToastType.otpSent:
        return Icons.mark_email_read_rounded;
      case ToastType.noConnection:
        return Icons.wifi_off_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _accentColor;

    return Container(
      width: MediaQuery.of(context).size.width - 32,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // Ambient colored glow
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.18),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF003D38).withOpacity(0.92),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.07),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Left accent bar
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 14, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon with glowing background
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: color.withOpacity(0.25),
                            width: 1,
                          ),
                        ),
                        child: Icon(_icon, color: color, size: 20),
                      ),
                      const SizedBox(width: 14),
                      // Text column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.message,
                              style: const TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Close Button
                      if (widget.onClose != null)
                        GestureDetector(
                          onTap: widget.onClose,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.close_rounded,
                              color: AppTheme.textSecondary.withOpacity(0.6),
                              size: 18,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Animated bottom progress drain bar
                Positioned(
                  bottom: 0,
                  left: 4,
                  right: 0,
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, _) {
                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 1.0 - _progressController.value,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.7),
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(2),
                            ),
                          ),
                        ),
                      );
                    },
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
