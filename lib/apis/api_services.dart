import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sumarg/utils/token_handler.dart';

class ApiService {
  final Dio _dio = Dio();

  ApiService() {
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    // Identify this app as the passenger client to the backend.
    // Used for cross-role detection (e.g., a bus owner logging into the
    // passenger app). Never used for authorization — only role enrichment.
    _dio.options.headers['X-App-Source'] = 'passenger';
    
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, handler) async {
        String friendlyMessage = "Network error. Please check your connection.";
        
        // 1. Try to extract the specific error message from the server response (e.g., 400 Bad Request)
        if (e.response != null && e.response!.data is Map) {
          final serverMsg = e.response!.data['message'] ?? e.response!.data['statusMessage'];
          if (serverMsg != null && serverMsg.toString().isNotEmpty) {
            friendlyMessage = serverMsg.toString();
          }
        } 
        
        // ── 401 — Attempt silent refresh before logging out ──
        if (e.response != null && e.response!.statusCode == 401) {
          // Try to silently refresh the access token
          final refreshed = await TokenHandler.attemptSilentRefresh();

          if (refreshed) {
            // Refresh succeeded — retry the original request with the new token
            try {
              final retryResponse = await _retryRequest(e.requestOptions);
              return handler.resolve(retryResponse);
            } catch (retryError) {
              // Retry failed — fall through to normal error handling
            }
          }

          // Refresh failed — force logout
          if (TokenHandler.isTokenExpiredFromStatusCode(
              e.response!.statusCode ?? 401, e.response!.data.toString())) {
            await TokenHandler.handleTokenExpiration();
            friendlyMessage = "Session expired. Please login again.";
          }
        }
        // 2. Handle specific connection-level failures
        else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
          friendlyMessage = "Connection timed out. Your internet might be slow.";
        } else if (e.type == DioExceptionType.connectionError) {
          friendlyMessage = "No internet connection. Please reconnect.";
        } 
        // 3. Handle 500-level routing/server crashes
        else if (e.response != null && e.response!.statusCode! >= 500) {
          friendlyMessage = "Server routing error. Please try again later.";
        }

        // Inject the human-readable text into the exception for the UI catch blocks
        final parsedError = DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: e.type,
          error: friendlyMessage,
          message: friendlyMessage,
        );
        return handler.next(parsedError);
      }
    ));

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));
    }
  }

  /// Retry a failed request with the freshly refreshed access token.
  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final prefs = await SharedPreferences.getInstance();
    final newToken = prefs.getString('accessToken');

    // Update the Authorization header with the new token
    if (newToken != null && newToken.isNotEmpty) {
      requestOptions.headers['Authorization'] = 'Bearer $newToken';
    }

    return _dio.fetch(requestOptions);
  }

  // Post Data
  Future postData(String endpoint, data) async {
    if (kDebugMode) {
      print("test123");
    }
    try {
      final response = await _dio.post(
        endpoint,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: data,
      );
      if (kDebugMode) {
        print("seardjdjdj ${response.statusCode}");
      }
      if (kDebugMode) {
        print("seardjdjdj ${response.data}");
      }
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Failed to load data: ${response.statusCode} ${response.statusMessage}');
      }
    } on DioException {
      rethrow;
    } catch (error) {
      throw Exception('Error in fetching data: $error');
    }
  }

// Post data with token
  Future postDataWithToken(String endpoint, data,
      {BuildContext? context}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? token = preferences.getString("accessToken");
    if (token == null || token.isEmpty) {
      throw Exception("Token not found. Please log in again.");
    }
    Map<String, String> requestHeader = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer $token",
    };

    try {
      final response = await _dio.post(
        endpoint,
        options: Options(headers: requestHeader),
        data: data,
      );
      if (kDebugMode) {
        print("Response status: ${response.data}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(
            'Failed to load data: ${response.statusCode} ${response.statusMessage}');
      }
    } catch (error) {
      throw Exception('Error in fetching data: $error');
    }
  }

// Get Data with token
  Future getDataWithToken(String endpoint, {BuildContext? context}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? token = preferences.getString("accessToken");
    if (token == null || token.isEmpty) {
      throw Exception("Token not found. Please log in again.");
    }
    Map<String, String> requestHeader = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer $token",
    };

    try {
      final response = await _dio.get(
        endpoint,
        options: Options(headers: requestHeader),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Failed to load data: ${response.statusCode} ${response.statusMessage}');
      }
    } catch (error) {
      throw Exception('Error in fetching data: $error');
    }
  }

  // Get Data without token
  Future getDataWithoutToken(String endpoint, {BuildContext? context}) async {
    try {
      final response = await _dio.get(
        endpoint,
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Failed to load data: ${response.statusCode} ${response.statusMessage}');
      }
    } catch (error) {
      throw Exception('Error in fetching data: $error');
    }
  }

  // Patch Data
  Future patchdata(String endpoint, data, {BuildContext? context}) async {
    if (kDebugMode) {
      print("test123");
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? token = preferences.getString("accessToken");
    if (token == null || token.isEmpty) {
      throw Exception("Token not found. Please log in again.");
    }
    Map<String, String> requestHeader = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer $token",
    };
    try {
      final response = await _dio.patch(
        "$endpoint/$data",
        options: Options(headers: requestHeader),
      );
      print("markasreadurl $endpoint/$data");
      if (kDebugMode) {
        print("markasread ${response.statusCode}");
      }
      if (kDebugMode) {
        print("markasread ${response.data}");
        print("markasread ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Failed to load data: ${response.statusCode} ${response.statusMessage}');
      }
    } catch (error) {
      throw Exception('Error in fetching data: $error');
    }
  }

  // Patch data with token
  Future putDataWithToken(String endpoint, data,
      {BuildContext? context}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? token = preferences.getString("accessToken");
    if (token == null || token.isEmpty) {
      throw Exception("Token not found. Please log in again.");
    }
    Map<String, String> requestHeader = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer $token",
    };
    print("miniminiurl $endpoint");

    try {
      final response = await _dio.put(
        endpoint,
        options: Options(headers: requestHeader),
        data: data,
      );
      if (kDebugMode) {
        print("Response status: ${response.data}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(
            'Failed to load data: ${response.statusCode} ${response.statusMessage}');
      }
    } catch (error) {
      throw Exception('Error in fetching data: $error');
    }
  }

  // Post multipart data with token
  Future postMultipartWithToken(String endpoint, Map<String, String> fields,
      {File? imageFile, String? imageFieldName, BuildContext? context}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? token = preferences.getString("accessToken");
    if (token == null || token.isEmpty) {
      throw Exception("Token not found. Please log in again.");
    }

    FormData formData = FormData.fromMap(fields);

    // Add image file if provided
    if (imageFile != null && imageFieldName != null) {
      final path = imageFile.path;
      final mime = lookupMimeType(path) ?? 'image/jpeg';
      const allowed = {
        'image/jpeg',
        'image/png',
        'image/gif',
        'image/webp',
      };

      if (allowed.contains(mime)) {
        formData.files.add(MapEntry(
          imageFieldName,
          await MultipartFile.fromFile(
            path,
            filename: path.split('/').last,
          ),
        ));
      } else {
        // Transcode unsupported formats (e.g., HEIC/HEIF) to JPEG
        try {
          final bytes = await imageFile.readAsBytes();
          final decoded = img.decodeImage(bytes);
          if (decoded != null) {
            final jpgBytes = img.encodeJpg(decoded, quality: 90);
            final filenameBase = path.split('/').last.split('.').first;
            formData.files.add(MapEntry(
              imageFieldName,
              MultipartFile.fromBytes(
                jpgBytes,
                filename: '$filenameBase.jpg',
              ),
            ));
          } else {
            // Fallback: send as-is
            formData.files.add(MapEntry(
              imageFieldName,
              await MultipartFile.fromFile(
                path,
                filename: path.split('/').last,
              ),
            ));
          }
        } catch (e) {
          // Fallback if transcode fails
          formData.files.add(MapEntry(
            imageFieldName,
            await MultipartFile.fromFile(
              path,
              filename: path.split('/').last,
            ),
          ));
        }
      }
    }

    if (kDebugMode) {
      print("Multipart request: $endpoint");
      print("Fields: $fields");
    }

    try {
      var response = await _dio.patch(
        endpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': "Bearer $token",
          },
        ),
      );

      if (kDebugMode) {
        print("Multipart response status: ${response.statusCode}");
        print("Multipart response body: ${response.data}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(
            'Failed to load data: ${response.statusCode} ${response.statusMessage}');
      }
    } catch (error) {
      throw Exception('Error in posting multipart data: $error');
    }
  }

  // Delete data with token
  Future deleteData(String endpoint, {BuildContext? context}) async {
    if (kDebugMode) {
      print("test123");
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? token = preferences.getString("accessToken");
    if (token == null || token.isEmpty) {
      throw Exception("Token not found. Please log in again.");
    }
    Map<String, String> requestHeader = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer $token",
    };
    try {
      final response = await _dio.delete(
        endpoint,
        options: Options(headers: requestHeader),
      );
      print("markasreadurl $endpoint");
      if (kDebugMode) {
        print("markasread ${response.statusCode}");
      }
      if (kDebugMode) {
        print("markasread ${response.data}");
        print("markasread ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Failed to load data: ${response.statusCode} ${response.statusMessage}');
      }
    } catch (error) {
      throw Exception('Error in fetching data: $error');
    }
  }
}
