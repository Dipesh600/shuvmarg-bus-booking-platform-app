class CouponResponse2 {
  final bool success;
  final String message;
  final List<Coupon> data;

  CouponResponse2({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CouponResponse2.fromJson(Map<String, dynamic> json) {
    return CouponResponse2(
      success: json['success'],
      message: json['message'],
      data: List<Coupon>.from(
          json['data'].map((x) => Coupon.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': List<dynamic>.from(data.map((x) => x.toJson())),
    };
  }
}

class Coupon {
  final String id;
  final String couponCode;
  final String title;
  final String description;
  final String discountType;
  final num discountValue;
  final num minOrderAmount;
  final num maxDiscountAmount;
  final DateTime validFrom;
  final DateTime validTo;
  final int perUserLimit;

  Coupon({
    required this.id,
    required this.couponCode,
    required this.title,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.minOrderAmount,
    required this.maxDiscountAmount,
    required this.validFrom,
    required this.validTo,
    required this.perUserLimit,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['_id'],
      couponCode: json['couponCode'],
      title: json['title'],
      description: json['description'],
      discountType: json['discountType'],
      discountValue: json['discountValue'],
      minOrderAmount: json['minOrderAmount'],
      maxDiscountAmount: json['maxDiscountAmount'],
      validFrom: DateTime.parse(json['validFrom']),
      validTo: DateTime.parse(json['validTo']),
      perUserLimit: json['perUserLimit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'couponCode': couponCode,
      'title': title,
      'description': description,
      'discountType': discountType,
      'discountValue': discountValue,
      'minOrderAmount': minOrderAmount,
      'maxDiscountAmount': maxDiscountAmount,
      'validFrom': validFrom.toIso8601String(),
      'validTo': validTo.toIso8601String(),
      'perUserLimit': perUserLimit,
    };
  }
}
