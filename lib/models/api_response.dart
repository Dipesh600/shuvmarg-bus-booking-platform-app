class ApiResponse {
  bool success;
  String message;
  String? errorCode;
  String? reason;
  Map<String, dynamic>? contact;

  ApiResponse({
    required this.success,
    required this.message,
    this.errorCode,
    this.reason,
    this.contact,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      errorCode: json['errorCode'] as String?,
      reason: json['reason'] as String?,
      contact: json['contact'] != null
          ? Map<String, dynamic>.from(json['contact'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      if (errorCode != null) 'errorCode': errorCode,
      if (reason != null) 'reason': reason,
      if (contact != null) 'contact': contact,
    };
  }

  /// Whether this is a ban/suspend enforcement response
  bool get isAccountRestricted =>
      errorCode == 'ACCOUNT_BANNED' ||
      errorCode == 'ACCOUNT_SUSPENDED' ||
      errorCode == 'ACCOUNT_DELETED';
}
