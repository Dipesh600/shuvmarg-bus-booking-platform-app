class UserDetailResponse {
  final bool status;
  final String message;
  final UserData? data;

  UserDetailResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory UserDetailResponse.fromJson(Map<String, dynamic> json) {
    return UserDetailResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? UserData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "message": message,
      "data": data?.toJson(),
    };
  }
}

class UserData {
  final String? referredBy;
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String profilePicture;
  final String gender;
  final String role;
  final bool isVerified;
  final String status;
  final double yatrapoints;
  final String referralCode;
  final int referralPoints;
  final int totalReferrals;
  final bool phoneVerified;

  UserData({
    this.referredBy,
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.profilePicture,
    required this.gender,
    required this.role,
    required this.isVerified,
    required this.status,
    required this.yatrapoints,
    required this.referralCode,
    required this.referralPoints,
    required this.totalReferrals,
    required this.phoneVerified,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      referredBy: json['referredBy'],
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      gender: json['gender'] ?? '',
      role: json['role'] ?? '',
      isVerified: json['isVerified'] ?? false,
      status: json['status'] ?? '',
      yatrapoints: json['yatrapoints'] ?? 0,
      referralCode: json['referralCode'] ?? '',
      referralPoints: json['referralPoints'] ?? 0,
      totalReferrals: json['totalReferrals'] ?? 0,
      phoneVerified: json['phoneVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "referredBy": referredBy,
      "_id": id,
      "name": name,
      "email": email,
      "phone": phone,
      "address": address,
      "profilePicture": profilePicture,
      "gender": gender,
      "role": role,
      "isVerified": isVerified,
      "status": status,
      "yatrapoints": yatrapoints,
      "referralCode": referralCode,
      "referralPoints": referralPoints,
      "totalReferrals": totalReferrals,
      "phoneVerified": phoneVerified,
    };
  }
}
