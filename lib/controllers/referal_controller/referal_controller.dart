import 'package:sumarg/apis/api_services.dart';
import 'package:sumarg/models/referal_dashboard_response.dart';
import 'package:sumarg/models/referal_history_response.dart';
import 'package:sumarg/utils/api_endpoints.dart';

class ReferalController {
  final ApiService apiService = ApiService();

//
  Future<ReferralDashboard> getReferalDashboard() async {
    try {
      final response =
          await apiService.getDataWithToken(ApiEndpoints.refralDashboard);
      print("response4 ${response}");

      final seatsResponse =
          ReferralDashboard.fromJson(response);
      print("seatsResponse ${seatsResponse}");
      return seatsResponse;
    } catch (error) {
      return ReferralDashboard(
        status: false, 
        message: 'Failed to fetch referral dashboard: $error', 
        data: ReferralData(
          referralCode: '',
          totalUsersUsedCode: 0,
          totalReferralPoints: 0,
          pointsBalance: 0.0,
          completedReferrals: 0,
          pendingReferrals: 0,
          hasMoreReferrals: false,
        ),
      );
    }
  }
// Get Referal history 
 Future<ReferalHistory> getReferalHistory() async {
    try {
      final response =
          await apiService.getDataWithToken(ApiEndpoints.referalHistory);
      print("response4 ${response}");

      final historyResponse = ReferalHistory.fromJson(response);
      print("historyResponse ${historyResponse}");
      return historyResponse;
    } catch (error) {
      return ReferalHistory(
        status: false,
        message: 'Failed to fetch referral history: $error',
        data: [],
      );
    }
  }
}
