/// Referral Dashboard V2 — Progressive Unlock
///
/// Maps to the V2 backend response from GET /api/referral/dashboard
/// which returns per-referral journey progress instead of flat points.

class ReferralDashboard {
  final bool status;
  final String message;
  final ReferralDashboardData data;

  ReferralDashboard({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ReferralDashboard.fromJson(Map<String, dynamic> json) {
    return ReferralDashboard(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: ReferralDashboardData.fromJson(json['data'] ?? {}),
    );
  }
}

class ReferralDashboardData {
  final String referralCode;
  final ReferralSummary summary;
  final List<ReferralEntry> referrals;

  ReferralDashboardData({
    required this.referralCode,
    required this.summary,
    required this.referrals,
  });

  factory ReferralDashboardData.fromJson(Map<String, dynamic> json) {
    return ReferralDashboardData(
      referralCode: json['referralCode'] ?? '',
      summary: ReferralSummary.fromJson(json['summary'] ?? {}),
      referrals: (json['referrals'] as List<dynamic>?)
              ?.map((e) => ReferralEntry.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ReferralSummary {
  final int totalReferrals;
  final int activeReferrals;
  final int fullyUnlocked;
  final int expiredReferrals;
  final double totalEarned;
  final double totalLocked;

  ReferralSummary({
    required this.totalReferrals,
    required this.activeReferrals,
    required this.fullyUnlocked,
    required this.expiredReferrals,
    required this.totalEarned,
    required this.totalLocked,
  });

  factory ReferralSummary.fromJson(Map<String, dynamic> json) {
    return ReferralSummary(
      totalReferrals: json['totalReferrals'] ?? 0,
      activeReferrals: json['activeReferrals'] ?? 0,
      fullyUnlocked: json['fullyUnlocked'] ?? 0,
      expiredReferrals: json['expiredReferrals'] ?? 0,
      totalEarned: (json['totalEarned'] ?? 0).toDouble(),
      totalLocked: (json['totalLocked'] ?? 0).toDouble(),
    );
  }
}

class ReferralEntry {
  final String id;
  final ReferredUserInfo referredUser;
  final String status;
  final int journeysCompleted;
  final double totalUnlocked;
  final double lockedRemaining;
  final DateTime? expiresAt;
  final bool flaggedForReview;
  final List<UnlockEvent> unlockHistory;
  final DateTime createdAt;

  ReferralEntry({
    required this.id,
    required this.referredUser,
    required this.status,
    required this.journeysCompleted,
    required this.totalUnlocked,
    required this.lockedRemaining,
    this.expiresAt,
    required this.flaggedForReview,
    required this.unlockHistory,
    required this.createdAt,
  });

  factory ReferralEntry.fromJson(Map<String, dynamic> json) {
    return ReferralEntry(
      id: json['id'] ?? '',
      referredUser: ReferredUserInfo.fromJson(json['referredUser'] ?? {}),
      status: json['status'] ?? 'ACTIVE',
      journeysCompleted: json['journeysCompleted'] ?? 0,
      totalUnlocked: (json['totalUnlocked'] ?? 0).toDouble(),
      lockedRemaining: (json['lockedRemaining'] ?? 0).toDouble(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'])
          : null,
      flaggedForReview: json['flaggedForReview'] ?? false,
      unlockHistory: (json['unlockHistory'] as List<dynamic>?)
              ?.map((e) => UnlockEvent.fromJson(e))
              .toList() ??
          [],
      createdAt:
          DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// Human-readable status label
  String get statusLabel {
    switch (status) {
      case 'ACTIVE':
        return 'Active';
      case 'PARTIALLY_UNLOCKED':
        return 'In Progress';
      case 'FULLY_UNLOCKED':
        return 'Completed';
      case 'EXPIRED':
        return 'Expired';
      case 'VOIDED':
        return 'Voided';
      default:
        return status;
    }
  }

  /// Progress percentage (0.0 - 1.0)
  double get progress => journeysCompleted / 5.0;
}

class ReferredUserInfo {
  final String name;
  final String? phone;
  final DateTime? joinedAt;

  ReferredUserInfo({
    required this.name,
    this.phone,
    this.joinedAt,
  });

  factory ReferredUserInfo.fromJson(Map<String, dynamic> json) {
    return ReferredUserInfo(
      name: json['name'] ?? 'User',
      phone: json['phone'],
      joinedAt: json['joinedAt'] != null
          ? DateTime.tryParse(json['joinedAt'])
          : null,
    );
  }
}

class UnlockEvent {
  final int journeyNumber;
  final double amountUnlocked;
  final DateTime unlockedAt;

  UnlockEvent({
    required this.journeyNumber,
    required this.amountUnlocked,
    required this.unlockedAt,
  });

  factory UnlockEvent.fromJson(Map<String, dynamic> json) {
    return UnlockEvent(
      journeyNumber: json['journeyNumber'] ?? 0,
      amountUnlocked: (json['amountUnlocked'] ?? 0).toDouble(),
      unlockedAt:
          DateTime.tryParse(json['unlockedAt'] ?? '') ?? DateTime.now(),
    );
  }
}
