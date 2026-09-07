import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../apis/api_services.dart';
import '../models/esewa_checkout.dart';
import '../models/ticket_booking_response.dart';
import '../utils/api_endpoints.dart';

class EsewaCheckoutService {
  final ApiService _api;
  EsewaCheckoutService({ApiService? api}) : _api = api ?? ApiService();
  Future<String> _key(SharedPreferences prefs) async {
    final phone = prefs.getString('phone');
    if (phone == null || phone.isEmpty) throw StateError('Please sign in again.');
    return 'pending_esewa:${ApiEndpoints.baseUrl}:$phone';
  }
  Future<String?> pendingReference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(await _key(prefs));
  }
  Future<String?> discoverPendingReference() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _key(prefs);
    final saved = prefs.getString(key);
    if (saved != null) return saved;
    final response = await _api.getDataWithToken('${ApiEndpoints.baseUrl}/api/ticket/esewa/pending');
    final attempts = response['data']['attempts'] as List;
    if (attempts.isEmpty) return null;
    final reference = attempts.first['transactionUuid'] as String;
    if (!RegExp(r'^[A-Za-z0-9_-]{1,128}$').hasMatch(reference)) {
      throw const FormatException('Invalid payment recovery reference');
    }
    if (!await prefs.setString(key, reference)) throw StateError('Could not save payment recovery reference.');
    return reference;
  }
  Future<EsewaCheckout> initiate(Map<String, dynamic> input) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _key(prefs);
    if (await discoverPendingReference() != null) throw StateError('Check your existing payment first.');
    final response = await _api.postDataWithToken('${ApiEndpoints.baseUrl}/api/ticket/esewa/initiate', input);
    final checkout = EsewaCheckout.fromJson(Map<String, dynamic>.from(response['data']));
    // Never store PINs, signed forms or gateway credentials locally.
    if (!await prefs.setString(key, checkout.reference)) throw StateError('Could not save payment recovery reference.');
    return checkout;
  }
  Future<TicketBookingResponse> finalize(String reference, {String? responseData}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _key(prefs);
    Map<String, dynamic> result;
    try {
      result = Map<String, dynamic>.from(await _api.postDataWithToken(
        '${ApiEndpoints.baseUrl}/api/ticket/esewa/finalize',
        {'transactionUuid': reference, if (responseData != null) 'responseData': responseData}));
    } on DioException catch (error) {
      if (error.response?.data is! Map) rethrow;
      result = Map<String, dynamic>.from(error.response!.data);
    }
    final booking = TicketBookingResponse.fromJson(result);
    final terminal = booking.status || ['PAYMENT_CLOSED', 'PAYMENT_RECEIVED_BOOKING_DISPUTED']
        .contains(result['errorCode']);
    if (terminal && prefs.getString(key) == reference) await prefs.remove(key);
    return booking;
  }
}
