class ForAllResponse {
  final bool status;
  final String message;

  ForAllResponse({
    required this.status,
    required this.message,
  });

  factory ForAllResponse.fromJson(Map<String, dynamic> json) {
    return ForAllResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
    };
  }
}
