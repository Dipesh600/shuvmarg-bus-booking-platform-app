class ReferralDashboard {
  final bool status;
  final String message;
  final ReferralData data;

  ReferralDashboard({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ReferralDashboard.fromJson(Map<String, dynamic> json) {
    return ReferralDashboard(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: ReferralData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class ReferralData {
  final String referralCode;
  final int totalUsersUsedCode;
  final int totalReferralPoints;
  final double pointsBalance;
  final int completedReferrals;
  final int pendingReferrals;
  final bool hasMoreReferrals;

  ReferralData({
    required this.referralCode,
    required this.totalUsersUsedCode,
    required this.totalReferralPoints,
    required this.pointsBalance,
    required this.completedReferrals,
    required this.pendingReferrals,
    required this.hasMoreReferrals,
  });

  factory ReferralData.fromJson(Map<String, dynamic> json) {
    return ReferralData(
      referralCode: json['referralCode'] ?? '',
      totalUsersUsedCode: json['totalUsersUsedCode'] ?? 0,
      totalReferralPoints: json['totalReferralPoints'] ?? 0,
      pointsBalance: (json['pointsBalance'] ?? 0).toDouble(),
      completedReferrals: json['completedReferrals'] ?? 0,
      pendingReferrals: json['pendingReferrals'] ?? 0,
      hasMoreReferrals: json['hasMoreReferrals'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'referralCode': referralCode,
      'totalUsersUsedCode': totalUsersUsedCode,
      'totalReferralPoints': totalReferralPoints,
      'pointsBalance': pointsBalance,
      'completedReferrals': completedReferrals,
      'pendingReferrals': pendingReferrals,
      'hasMoreReferrals': hasMoreReferrals,
    };
  }
}
