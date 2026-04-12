class YatraPointsResponse {
  final bool status;
  final String message;
  final YatraPointsData? data;

  YatraPointsResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory YatraPointsResponse.fromJson(Map<String, dynamic> json) {
    return YatraPointsResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? YatraPointsData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class YatraPointsData {
  final int finalAmount;

  YatraPointsData({required this.finalAmount});

  factory YatraPointsData.fromJson(Map<String, dynamic> json) {
    return YatraPointsData(
      finalAmount: json['finalAmount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'finalAmount': finalAmount,
    };
  }
}
