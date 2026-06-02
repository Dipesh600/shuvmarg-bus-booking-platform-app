import 'package:sumarg/apis/api_services.dart';
import 'package:sumarg/models/referal_dashboard_response.dart';
import 'package:sumarg/models/referal_history_response.dart';
import 'package:sumarg/utils/api_endpoints.dart';

/// Referral Controller V2 — Progressive Unlock
///
/// Handles API communication for the referral system.
/// Backend returns per-referral journey progress instead of flat points.
class ReferalController {
  final ApiService apiService = ApiService();

  /// Fetch the referral dashboard with summary stats + per-referral breakdown.
  Future<ReferralDashboard> getReferalDashboard() async {
    try {
      final response =
          await apiService.getDataWithToken(ApiEndpoints.refralDashboard);

      return ReferralDashboard.fromJson(response);
    } catch (error) {
      return ReferralDashboard(
        status: false,
        message: 'Failed to fetch referral dashboard: $error',
        data: ReferralDashboardData(
          referralCode: '',
          summary: ReferralSummary(
            totalReferrals: 0,
            activeReferrals: 0,
            fullyUnlocked: 0,
            expiredReferrals: 0,
            totalEarned: 0,
            totalLocked: 0,
          ),
          referrals: [],
        ),
      );
    }
  }

  /// Fetch referral history with per-referral unlock timeline.
  Future<ReferalHistory> getReferalHistory() async {
    try {
      final response =
          await apiService.getDataWithToken(ApiEndpoints.referalHistory);

      return ReferalHistory.fromJson(response);
    } catch (error) {
      return ReferalHistory(
        status: false,
        message: 'Failed to fetch referral history: $error',
        data: [],
      );
    }
  }
}
