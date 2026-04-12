class LoginResponse {
  final bool success;
  final String message;
  final User user;
  final String accessToken;

  LoginResponse({
    required this.success,
    required this.message,
    required this.user,
    required this.accessToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      user: User.fromJson(json['user']),
      accessToken: json['accessToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'user': user.toJson(),
      'accessToken': accessToken,
    };
  }
}

class User {
  final String id;
  final String name;
  final String? email;
  final String phone;
  final String address;
  final String profilePicture;
  final String gender;
  final String role;
  final bool isVerified;
  final String status;
  final bool phoneVerified;
  final int rewardPoints;
  final String referralCode;
  final String? referredBy;
  final int referralPoints;
  final int totalReferrals;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  User({
    required this.id,
    required this.name,
    this.email,
    required this.phone,
    required this.address,
    required this.profilePicture,
    required this.gender,
    required this.role,
    required this.isVerified,
    required this.status,
    required this.phoneVerified,
    required this.rewardPoints,
    required this.referralCode,
    this.referredBy,
    required this.referralPoints,
    required this.totalReferrals,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      gender: json['gender'] ?? '',
      role: json['role'] ?? '',
      isVerified: json['isVerified'] ?? false,
      status: json['status'] ?? '',
      phoneVerified: json['phoneVerified'] ?? false,
      rewardPoints: json['rewardPoints'] ?? 0,
      referralCode: json['referralCode'] ?? '',
      referredBy: json['referredBy'],
      referralPoints: json['referralPoints'] ?? 0,
      totalReferrals: json['totalReferrals'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'profilePicture': profilePicture,
      'gender': gender,
      'role': role,
      'isVerified': isVerified,
      'status': status,
      'phoneVerified': phoneVerified,
      'rewardPoints': rewardPoints,
      'referralCode': referralCode,
      'referredBy': referredBy,
      'referralPoints': referralPoints,
      'totalReferrals': totalReferrals,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}
