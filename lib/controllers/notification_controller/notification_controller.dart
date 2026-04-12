import 'package:sumarg/apis/api_services.dart';
import 'package:sumarg/models/api_response.dart';
import 'package:sumarg/models/local_notification_response.dart';
import 'package:sumarg/utils/api_endpoints.dart';

class NotificationController {
  final String mylocalnotificationsurl =
      ApiEndpoints.mylocalnotifications;
  final String markNotificationAsReadurl =
      ApiEndpoints.markNotificationAsRead;
  final ApiService apiService = ApiService();

//
  Future<LocalNotificationResponse> getNotifications() async {
    try {
      final response =
          await apiService.getDataWithToken(mylocalnotificationsurl);
      print("response4 ${response}");

      final seatsResponse =
          LocalNotificationResponse.fromJson(response);
      print("seatsResponse ${seatsResponse}");
      return seatsResponse;
    } catch (error) {
      return LocalNotificationResponse(
        status: false,
        notifications: [],
      );
    }
  }

  Future<ApiResponse> markNotificationAsRead(String id) async {
    try {
      final response =
          await apiService.patchdata(markNotificationAsReadurl, id);
      print("markNotificationAsRead response: ${response}");

      final apiResponse = ApiResponse.fromJson(response);
      print("apiResponse: ${apiResponse}");
      return apiResponse;
    } catch (error) {
      print("Error marking notification as read: $error");
      return ApiResponse(
        message: 'Failed to mark notification as read',
        success: false,
      );
    }
  }
  // Delete notification 
  Future<ApiResponse> deleteNotification(String id) async {
    try {
     final response = await apiService.deleteData('${ApiEndpoints.deleteNotification}/$id');

      print("delete noti response: ${response}");

      final apiResponse = ApiResponse.fromJson(response);
      print("apiResponse: ${apiResponse}");
      return apiResponse;
    } catch (error) {
      print("Error delete notification: $error");
      return ApiResponse(
        message: 'Failed to delete notification',
        success: false,
      );
    }
  }
}
