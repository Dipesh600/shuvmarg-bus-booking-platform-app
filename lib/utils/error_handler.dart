import 'package:dio/dio.dart';

class ErrorHandler {
  /// Cleans up raw Dart exceptions, DioExceptions, and nested stack strings
  /// to return a user-friendly error message.
  static String clean(dynamic error) {
    if (error == null) return "An unknown error occurred.";
    
    // If it's a DioException, directly use the clean message we parsed in the interceptor
    if (error is DioException) {
      if (error.message != null && error.message!.isNotEmpty) {
        return error.message!;
      }
      if (error.error != null && error.error.toString().isNotEmpty) {
        return error.error.toString();
      }
    }

    String errStr = error.toString();
    
    // Direct matches for common backend/network errors
    if (errStr.contains("No internet connection") || errStr.contains("SocketException")) {
      return "No internet connection. Please check your network and try again.";
    }
    if (errStr.contains("Connection refused") || errStr.contains("connection error")) {
      return "Could not connect to the server. Please try again later.";
    }
    if (errStr.contains("Timeout")) {
      return "The connection timed out. Please try again.";
    }
    if (errStr.contains("401") || errStr.contains("Unauthorized")) {
      return "Session expired. Please log in again.";
    }
    if (errStr.contains("404")) {
      return "Requested data not found.";
    }
    if (errStr.contains("500") || errStr.contains("Internal Server Error")) {
      return "Our servers are experiencing issues. We're working on it.";
    }

    // Heuristics to clean up nested Exception tags
    // e.g. "Exception: Failed to load tickets: Exception: API failed: Something went wrong"
    // We want to extract the final meaningful sentence.
    List<String> parts = errStr.split(RegExp(r'(Exception:|Error loading|Failed to|DioException|\[.*?\]:)'));
    
    // Find the last part that has meaningful text
    String meaningful = "";
    for (int i = parts.length - 1; i >= 0; i--) {
      String part = parts[i].trim();
      // Remove leading colons or hyphens that might be left over
      part = part.replaceAll(RegExp(r'^[:\-]+'), '').trim();
      if (part.length > 5) { // Needs to be an actual word/phrase
        meaningful = part;
        break;
      }
    }

    if (meaningful.isNotEmpty) {
      // Capitalize first letter
      return meaningful[0].toUpperCase() + meaningful.substring(1);
    }

    // Fallback if we couldn't parse
    return "Something went wrong. Please try again.";
  }
}
