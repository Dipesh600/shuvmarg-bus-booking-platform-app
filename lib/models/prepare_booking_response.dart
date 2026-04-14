/// Response model for the prepareBooking API call.
///
/// prepareBooking:
///   1. Locks seats temporarily (atomically) to prevent double booking
///   2. Returns a server-validated paymentAmount that MUST be used for eSewa
///   3. Returns a tempBookingId that ties the seat lock to the final confirmBooking
///
/// The Flutter flow is:
///   prepareBooking → get server paymentAmount → launch eSewa SDK with that amount
///   → onPaymentSuccess: call confirmBooking with refId + tempBookingId

class PrepareBookingResponse {
  final bool status;
  final String message;
  final String? tempBookingId;
  final String? scheduleId;
  final int? paymentAmount;

  PrepareBookingResponse({
    required this.status,
    required this.message,
    this.tempBookingId,
    this.scheduleId,
    this.paymentAmount,
  });

  factory PrepareBookingResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return PrepareBookingResponse(
      status:        json['success'] == true || json['status'] == true,
      message:       json['message']?.toString() ?? '',
      tempBookingId: data?['tempBookingId']?.toString(),
      scheduleId:    data?['scheduleId']?.toString(),
      paymentAmount: data?['paymentAmount'] != null
          ? (data!['paymentAmount'] as num).toInt()
          : null,
    );
  }
}
