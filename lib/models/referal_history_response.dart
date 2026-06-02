/// Referral History V2 — Per-Referral Unlock Timeline
///
/// Maps to the V2 backend response from GET /api/referral/history
/// which returns each referral with their journey-by-journey unlock progress.

class ReferalHistory {
  final bool status;
  final String message;
  final List<ReferalHistoryEntry> data;

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
              ?.map((e) => ReferalHistoryEntry.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ReferalHistoryEntry {
  final String id;
  final ReferredUser referredUser;
  final String status;
  final int journeysCompleted;
  final double totalUnlocked;
  final double lockedRemaining;
  final List<UnlockHistoryItem> unlockHistory;
  final DateTime? expiresAt;
  final DateTime createdAt;

  ReferalHistoryEntry({
    required this.id,
    required this.referredUser,
    required this.status,
    required this.journeysCompleted,
    required this.totalUnlocked,
    required this.lockedRemaining,
    required this.unlockHistory,
    this.expiresAt,
    required this.createdAt,
  });

  factory ReferalHistoryEntry.fromJson(Map<String, dynamic> json) {
    return ReferalHistoryEntry(
      id: json['id'] ?? '',
      referredUser: ReferredUser.fromJson(json['referredUser'] ?? {}),
      status: json['status'] ?? 'ACTIVE',
      journeysCompleted: json['journeysCompleted'] ?? 0,
      totalUnlocked: (json['totalUnlocked'] ?? 0).toDouble(),
      lockedRemaining: (json['lockedRemaining'] ?? 0).toDouble(),
      unlockHistory: (json['unlockHistory'] as List<dynamic>?)
              ?.map((e) => UnlockHistoryItem.fromJson(e))
              .toList() ??
          [],
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'])
          : null,
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

  /// Progress fraction (0.0 - 1.0) for UI progress bars
  double get progress => journeysCompleted / 5.0;
}

class UnlockHistoryItem {
  final int journeyNumber;
  final double amountUnlocked;
  final DateTime unlockedAt;

  UnlockHistoryItem({
    required this.journeyNumber,
    required this.amountUnlocked,
    required this.unlockedAt,
  });

  factory UnlockHistoryItem.fromJson(Map<String, dynamic> json) {
    return UnlockHistoryItem(
      journeyNumber: json['journeyNumber'] ?? 0,
      amountUnlocked: (json['amountUnlocked'] ?? 0).toDouble(),
      unlockedAt:
          DateTime.tryParse(json['unlockedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class ReferredUser {
  final String name;
  final String? phone;
  final DateTime? joinedAt;

  ReferredUser({
    required this.name,
    this.phone,
    this.joinedAt,
  });

  factory ReferredUser.fromJson(Map<String, dynamic> json) {
    return ReferredUser(
      name: json['name'] ?? 'User',
      phone: json['phone'],
      joinedAt: json['joinedAt'] != null
          ? DateTime.tryParse(json['joinedAt'])
          : null,
    );
  }
}
