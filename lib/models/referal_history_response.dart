class ReferalHistory {
  final bool status;
  final String message;
  final List<ReferalData> data;

  ReferalHistory({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ReferalHistory.fromJson(Map<String, dynamic> json) {
    return ReferalHistory(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => ReferalData.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class ReferalData {
  final String id;
  final ReferredUser referredUser;
  final int referrerPointsEarned;
  final int referredUserPoints;
  final String status;
  final String referralCodeUsed;
  final String rewardType;
  final DateTime date;

  ReferalData({
    required this.id,
    required this.referredUser,
    required this.referrerPointsEarned,
    required this.referredUserPoints,
    required this.status,
    required this.referralCodeUsed,
    required this.rewardType,
    required this.date,
  });

  factory ReferalData.fromJson(Map<String, dynamic> json) {
    return ReferalData(
      id: json['id'] ?? '',
      referredUser: ReferredUser.fromJson(json['referredUser'] ?? {}),
      referrerPointsEarned: json['referrerPointsEarned'] ?? 0,
      referredUserPoints: json['referredUserPoints'] ?? 0,
      status: json['status'] ?? '',
      referralCodeUsed: json['referralCodeUsed'] ?? '',
      rewardType: json['rewardType'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referredUser': referredUser.toJson(),
      'referrerPointsEarned': referrerPointsEarned,
      'referredUserPoints': referredUserPoints,
      'status': status,
      'referralCodeUsed': referralCodeUsed,
      'rewardType': rewardType,
      'date': date.toIso8601String(),
    };
  }
}

class ReferredUser {
  final String name;
  // final String email;
  // final String phone;

  ReferredUser({
    required this.name,
    // required this.email,
    // required this.phone,
  });

  factory ReferredUser.fromJson(Map<String, dynamic> json) {
    return ReferredUser(
      name: json['name'] ?? '',
      // email: json['email'] ?? '',
      // phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      // 'email': email,
      // 'phone': phone,
    };
  }
}
