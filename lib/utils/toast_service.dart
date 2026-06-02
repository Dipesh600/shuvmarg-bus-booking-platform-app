import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sumarg/utils/global_context.dart';
import 'package:sumarg/widgets/custom_toast.dart';

class ToastService {
  /// Safely shows a toast message. If a Custom ToastType is provided, it attempts
  /// to render the new rich UI using FToast (requires context).
  static Future<bool?> showToast({
    required String msg,
    String? title,
    ToastType? type,
    BuildContext? context,
    Toast? toastLength,
    int timeInSecForIosWeb = 2,
    double? fontSize,
    ToastGravity? gravity,
    Color? backgroundColor,
    Color? textColor,
    bool webShowClose = false,
    dynamic webBgColor = "linear-gradient(to right, #00b09b, #96c93d)",
    dynamic webPosition = "right",
  }) async {
    final effectiveContext = context ?? GlobalContext.context;

    // 1. If we have a custom type and context, render the rich CustomToast
    if (type != null && effectiveContext != null && effectiveContext.mounted) {
      final fToast = FToast();
      fToast.init(effectiveContext);

      // Default titles based on type if none provided
      String effectiveTitle = title ?? "Notification";
      if (title == null) {
        switch (type) {
          case ToastType.success: effectiveTitle = "Success!"; break;
          case ToastType.error: effectiveTitle = "Error!"; break;
          case ToastType.info: effectiveTitle = "Info"; break;
          case ToastType.warning: effectiveTitle = "Oops!"; break;
          case ToastType.otpSent: effectiveTitle = "OTP Sent!"; break;
          case ToastType.noConnection: effectiveTitle = "No Connection"; break;
        }
      }

      fToast.showToast(
        child: CustomToast(
          type: type,
          title: effectiveTitle,
          message: msg,
          onClose: () => fToast.removeCustomToast(),
        ),
        gravity: gravity ?? ToastGravity.TOP,
        toastDuration: Duration(seconds: timeInSecForIosWeb),
      );
      return true;
    }

    // 2. Fallback to native toasts
    if (kIsWeb) {
      return Fluttertoast.showToast(
        msg: msg,
        toastLength: toastLength,
        timeInSecForIosWeb: timeInSecForIosWeb,
        fontSize: fontSize,
        gravity: gravity,
        backgroundColor: backgroundColor,
        textColor: textColor,
        webShowClose: webShowClose,
        webBgColor: webBgColor,
        webPosition: webPosition,
      );
    }
    
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        return Fluttertoast.showToast(
          msg: msg,
          toastLength: toastLength,
          timeInSecForIosWeb: timeInSecForIosWeb,
          fontSize: fontSize,
          gravity: gravity,
          backgroundColor: backgroundColor,
          textColor: textColor,
          webShowClose: webShowClose,
          webBgColor: webBgColor,
          webPosition: webPosition,
        );
      } else {
        // Desktop/unsupported: use FToast with CustomToast widget
        if (effectiveContext != null && effectiveContext.mounted) {
          final fToast = FToast();
          fToast.init(effectiveContext);

          String effectiveTitle = title ?? "Notification";
          ToastType effectiveType = type ?? ToastType.info;
          if (title == null) {
            if (backgroundColor == Colors.red) {
              effectiveTitle = "Error!";
              effectiveType = ToastType.error;
            } else if (backgroundColor == Colors.green) {
              effectiveTitle = "Success!";
              effectiveType = ToastType.success;
            }
          }

          fToast.showToast(
            child: CustomToast(
              type: effectiveType,
              title: effectiveTitle,
              message: msg,
              onClose: () => fToast.removeCustomToast(),
            ),
            gravity: gravity ?? ToastGravity.TOP,
            toastDuration: Duration(seconds: timeInSecForIosWeb),
          );
        }
        debugPrint("Toast: $msg");
        return true;
      }
    } catch (e) {
      debugPrint("Toast failed to display safely: $e");
      return false;
    }
  }
}

