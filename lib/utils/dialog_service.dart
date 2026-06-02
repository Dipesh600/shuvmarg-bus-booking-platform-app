import 'package:flutter/material.dart';
import 'package:sumarg/utils/app_theme.dart';
import 'package:sumarg/utils/global_context.dart';
import 'package:sumarg/widgets/custom_dialog.dart';

enum DialogType {
  error,
  success,
  info,
  warning
}

class DialogService {
  static void showCustomDialog({
    BuildContext? context,
    required DialogType type,
    required String title,
    required String message,
    required String primaryButtonText,
    required VoidCallback onPrimaryPressed,
    String? secondaryButtonText,
    VoidCallback? onSecondaryPressed,
    IconData? customPrimaryIcon,
    IconData? customSecondaryIcon,
  }) {
    final effectiveContext = context ?? GlobalContext.context;
    if (effectiveContext == null || !effectiveContext.mounted) return;

    Color iconColor;
    IconData defaultPrimaryIcon;
    IconData? defaultSecondaryIcon;

    switch (type) {
      case DialogType.error:
        iconColor = AppTheme.error;
        defaultPrimaryIcon = Icons.person_outline_rounded;
        defaultSecondaryIcon = Icons.close_rounded;
        break;
      case DialogType.success:
        iconColor = AppTheme.success;
        defaultPrimaryIcon = Icons.shield_outlined;
        defaultSecondaryIcon = Icons.check_rounded;
        break;
      case DialogType.info:
        iconColor = AppTheme.info;
        defaultPrimaryIcon = Icons.info_outline_rounded;
        defaultSecondaryIcon = null;
        break;
      case DialogType.warning:
        iconColor = AppTheme.warning;
        defaultPrimaryIcon = Icons.access_time_rounded;
        defaultSecondaryIcon = null;
        break;
    }

    showDialog(
      context: effectiveContext,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext ctx) {
        return CustomDialog(
          primaryIcon: customPrimaryIcon ?? defaultPrimaryIcon,
          secondaryIcon: customSecondaryIcon ?? defaultSecondaryIcon,
          iconColor: iconColor,
          title: title,
          message: message,
          primaryButtonText: primaryButtonText,
          onPrimaryPressed: () {
            Navigator.pop(ctx);
            onPrimaryPressed();
          },
          secondaryButtonText: secondaryButtonText,
          onSecondaryPressed: onSecondaryPressed != null
              ? () {
                  Navigator.pop(ctx);
                  onSecondaryPressed();
                }
              : null,
        );
      },
    );
  }
}
