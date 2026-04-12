class TripResponse {
  final bool success;
  final String message;
  final int results;
  final List<TripData> data;

  TripResponse({
    required this.success,
    required this.message,
    required this.results,
    required this.data,
  });

  factory TripResponse.fromJson(Map<String, dynamic> json) {
    return TripResponse(
      success: json['success'],
      message: json['message'],
      results: json['results'],
      data: (json['data'] as List)
          .map((e) => TripData.fromJson(e))
          .toList(),
    );
  }
}

class TripData {
  final String id;
  final String tripId;
  final String tripDate;
  final String departureTime;
  final String arrivalTime;
  final int tripFare;
  final String shift;
  final BusDetail busDetail;
  final RouteDetail routeDetail;

  TripData({
    required this.id,
    required this.tripId,
    required this.tripDate,
    required this.departureTime,
    required this.arrivalTime,
    required this.tripFare,
    required this.shift,
    required this.busDetail,
    required this.routeDetail,
  });

  factory TripData.fromJson(Map<String, dynamic> json) {
    return TripData(
      id: json['_id'],
      tripId: json['tripId'],
      tripDate: json['tripDate'],
      departureTime: json['departureTime'],
      arrivalTime: json['arrivalTime'],
      tripFare: json['tripFare'],
      shift: json['shift'],
      busDetail: BusDetail.fromJson(json['busDetail']),
      routeDetail: RouteDetail.fromJson(json['routeDetail']),
    );
  }
}

class BusDetail {
  final String id;
  final String busName;
  final String busNumber;
  final String busType;
  final String vehicleType;
  final int totalSeats;
  final String seatLayout;
  final List<String> amenities;

  BusDetail({
    required this.id,
    required this.busName,
    required this.busNumber,
    required this.busType,
    required this.vehicleType,
    required this.totalSeats,
    required this.seatLayout,
    required this.amenities,
  });

  factory BusDetail.fromJson(Map<String, dynamic> json) {
    return BusDetail(
      id: json['_id'],
      busName: json['busName'],
      busNumber: json['busNumber'],
      busType: json['busType'],
      vehicleType: json['vehicleType'],
      totalSeats: json['totalSeats'],
      seatLayout: json['seatLayout'],
      amenities: List<String>.from(json['amenities']),
    );
  }
}

class RouteDetail {
  final String id;
  final String routeName;
  final String from;
  final String to;
  final String distance;
  final String duration;

  RouteDetail({
    required this.id,
    required this.routeName,
    required this.from,
    required this.to,
    required this.distance,
    required this.duration,
  });

  factory RouteDetail.fromJson(Map<String, dynamic> json) {
    return RouteDetail(
      id: json['_id'],
      routeName: json['routeName'],
      from: json['from'],
      to: json['to'],
      distance: json['distance'],
      duration: json['duration'],
    );
  }
}