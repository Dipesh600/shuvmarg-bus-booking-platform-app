class CouponResponse {
  final bool success;
  final String message;
  final CouponData? data;

  CouponResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CouponResponse.fromJson(Map<String, dynamic> json) {
    return CouponResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? CouponData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "message": message,
      "data": data?.toJson(),
    };
  }
}

class CouponData {
  final String couponCode;
  final String title;
  final String description;
  final String discountType;
  final double discountValue;
  final String originalAmount;
  final double discountAmount;
  final double finalAmount;
  final double savings;

  CouponData({
    required this.couponCode,
    required this.title,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.originalAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.savings,
  });

  factory CouponData.fromJson(Map<String, dynamic> json) {
    return CouponData(
      couponCode: json['couponCode'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      discountType: json['discountType'] ?? '',
      discountValue: (json['discountValue'] ?? 0).toDouble(),
      originalAmount: json['originalAmount'] ?? '0',
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      finalAmount: (json['finalAmount'] ?? 0).toDouble(),
      savings: (json['savings'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "couponCode": couponCode,
      "title": title,
      "description": description,
      "discountType": discountType,
      "discountValue": discountValue,
      "originalAmount": originalAmount,
      "discountAmount": discountAmount,
      "finalAmount": finalAmount,
      "savings": savings,
    };
  }
}
