/// Response model for the prepareBooking API call.
///
/// prepareBooking:
///   1. Locks seats temporarily (atomically) to prevent double booking
///   2. Returns a server-validated paymentAmount (= gatewayAmount) for eSewa
///   3. Returns a tempBookingId that ties the seat lock to the final confirmBooking
///   4. Returns SM Money split-payment breakdown (balance, applied, max allowed)
///
/// The Flutter flow is:
///   prepareBooking → get server paymentAmount + SM Money breakdown
///   → launch eSewa SDK with gatewayAmount (or skip if zero-gateway)
///   → onPaymentSuccess: call confirmBooking with refId + tempBookingId

class PrepareBookingResponse {
  final bool status;
  final String message;
  final String? tempBookingId;
  final String? scheduleId;
  final int? paymentAmount;

  // SM Money split-payment fields
  final int smMoneyBalance;      // User's current spendable balance
  final int smMoneyApplied;      // Server-computed amount after 80% cap
  final int maxSmMoneyAllowed;   // Max SM Money allowed by cap rules
  final int gatewayAmount;       // Amount to charge at payment gateway

  // Coupon
  final double couponDiscount;

  PrepareBookingResponse({
    required this.status,
    required this.message,
    this.tempBookingId,
    this.scheduleId,
    this.paymentAmount,
    this.smMoneyBalance = 0,
    this.smMoneyApplied = 0,
    this.maxSmMoneyAllowed = 0,
    this.gatewayAmount = 0,
    this.couponDiscount = 0,
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
      // SM Money split fields
      smMoneyBalance:    _toInt(data?['smMoneyBalance']),
      smMoneyApplied:    _toInt(data?['smMoneyApplied']),
      maxSmMoneyAllowed: _toInt(data?['maxSmMoneyAllowed']),
      gatewayAmount:     _toInt(data?['gatewayAmount']),
      couponDiscount:    _toDouble(data?['couponDiscount']),
    );
  }

  /// Safe int conversion from dynamic (handles null, int, double, String)
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Safe double conversion from dynamic
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
