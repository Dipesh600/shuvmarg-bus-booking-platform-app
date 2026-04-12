import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastService {
  /// Safely shows a toast message on supported platforms,
  /// skipping platforms like Desktop where the plugin is missing.
  static void showToast({required String msg}) {
    if (kIsWeb) {
      Fluttertoast.showToast(msg: msg);
      return;
    }
    
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        Fluttertoast.showToast(msg: msg);
      } else {
        debugPrint("Toast (simulated for Desktop): $msg");
      }
    } catch (e) {
      debugPrint("Toast failed to display safely: $e");
    }
  }
}
