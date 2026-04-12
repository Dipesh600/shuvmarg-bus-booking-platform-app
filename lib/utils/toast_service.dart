import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastService {
  /// Safely shows a toast message on supported platforms,
  /// skipping platforms like Desktop where the plugin is missing.
  static Future<bool?> showToast({
    required String msg,
    Toast? toastLength,
    int timeInSecForIosWeb = 1,
    double? fontSize,
    ToastGravity? gravity,
    Color? backgroundColor,
    Color? textColor,
    bool webShowClose = false,
    dynamic webBgColor = "linear-gradient(to right, #00b09b, #96c93d)",
    dynamic webPosition = "right",
  }) async {
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
        debugPrint("Toast (simulated for Desktop): $msg");
        return true;
      }
    } catch (e) {
      debugPrint("Toast failed to display safely: $e");
      return false;
    }
  }
}
