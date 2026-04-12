import 'package:sumarg/apis/api_services.dart';
import 'package:sumarg/models/seat_response.dart';
import 'package:sumarg/utils/api_endpoints.dart';

class SeatsController {
  final String seatsUrl = ApiEndpoints.getseats;
  final ApiService apiService = ApiService();

//
  Future<SeatResponse> getSeatsById({required String tripId}) async {
    try {
      final data = {"tripId": tripId};
      final response = await apiService.postDataWithToken(seatsUrl, data);

      final seatsResponse = SeatResponse.fromJson(response);
      return seatsResponse;
    } catch (error) {
      String errorMessage = 'Failed to fetch seats';
      final errorString = error.toString();

      if (errorString.contains('Seats Not Found!')) {
        errorMessage = 'Seats Not Found!';
      } else if (errorString.contains('404')) {
        errorMessage = 'Seats Not Found!';
      }

      return SeatResponse(
        status: false,
        message: errorMessage,
        data: null,
      );
    }
  }
}
