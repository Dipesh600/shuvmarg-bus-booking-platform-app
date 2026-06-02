import 'package:flutter/material.dart';
import 'package:sumarg/utils/app_theme.dart';
import 'package:sumarg/utils/error_handler.dart';

class StatusStateWidget extends StatelessWidget {
  final bool isError;
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onRetry;
  final String? rawError;

  const StatusStateWidget({
    super.key,
    required this.isError,
    required this.title,
    this.subtitle,
    required this.icon,
    this.onRetry,
    this.rawError,
  });

  /// Factory for standard Empty States
  factory StatusStateWidget.empty({
    required String title,
    String? subtitle,
    required IconData icon,
  }) {
    return StatusStateWidget(
      isError: false,
      title: title,
      subtitle: subtitle,
      icon: icon,
    );
  }

  /// Factory for standard Error States
  factory StatusStateWidget.error({
    String? rawError,
    VoidCallback? onRetry,
  }) {
    return StatusStateWidget(
      isError: true,
      title: 'Oops, something went wrong',
      subtitle: rawError != null ? ErrorHandler.clean(rawError) : 'Could not load data. Please try again.',
      icon: Icons.error_outline_rounded,
      onRetry: onRetry,
      rawError: rawError,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine colors based on state
    final Color accentColor = isError ? const Color(0xFFFF4D4F) : AppTheme.accentLime;
    final Color bgAccentColor = isError ? const Color(0x1AFF4D4F) : AppTheme.accentLime.withValues(alpha: 0.1);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.stroke, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryDark.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Glowing Icon Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: bgAccentColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 24),
              
              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
              
              // Subtitle
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
              ],

              // Retry Button for Errors
              if (isError && onRetry != null) ...[
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: onRetry,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryDarker,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.stroke),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.refresh_rounded, color: AppTheme.accentLime, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Retry',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppTheme.fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
