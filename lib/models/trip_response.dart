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
  final String? status;
  final BusDetail busDetail;
  final RouteDetail routeDetail;
  final int availableSeats;

  TripData({
    required this.id,
    required this.tripId,
    required this.tripDate,
    required this.departureTime,
    required this.arrivalTime,
    required this.tripFare,
    required this.shift,
    this.status,
    required this.busDetail,
    required this.routeDetail,
    required this.availableSeats,
  });

  factory TripData.fromJson(Map<String, dynamic> json) {
    return TripData(
      id: json['_id'],
      tripId: json['tripId'],
      tripDate: json['tripDate'],
      departureTime: json['departureTime'],
      arrivalTime: json['arrivalTime'],
      tripFare: (json['tripFare'] ?? 0) is int ? json['tripFare'] ?? 0 : (json['tripFare'] as num).toInt(),
      shift: json['shift'],
      status: json['status'],
      busDetail: BusDetail.fromJson(json['busDetail']),
      routeDetail: RouteDetail.fromJson(json['routeDetail']),
      availableSeats: json['availableSeats'] ?? 0,
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
  final List<String> fleetImages;
  final double averageRating;
  final int totalReviews;
  final List<StopPoint> boardingPoints;
  final List<StopPoint> droppingPoints;

  BusDetail({
    required this.id,
    required this.busName,
    required this.busNumber,
    required this.busType,
    required this.vehicleType,
    required this.totalSeats,
    required this.seatLayout,
    required this.amenities,
    required this.fleetImages,
    required this.averageRating,
    required this.totalReviews,
    required this.boardingPoints,
    required this.droppingPoints,
  });

  factory BusDetail.fromJson(Map<String, dynamic> json) {
    return BusDetail(
      id: json['_id'],
      busName: json['busName'] ?? '',
      busNumber: json['busNumber'] ?? '',
      busType: json['busType'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
      totalSeats: json['totalSeats'] ?? 0,
      seatLayout: json['seatLayout'] ?? '',
      amenities: json['amenities'] != null
          ? List<String>.from(json['amenities'])
          : [],
      fleetImages: json['fleetImages'] != null
          ? List<String>.from(json['fleetImages'])
          : [],
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      boardingPoints: json['boardingPoints'] != null
          ? (json['boardingPoints'] as List).map((e) => StopPoint.fromJson(e)).toList()
          : [],
      droppingPoints: json['droppingPoints'] != null
          ? (json['droppingPoints'] as List).map((e) => StopPoint.fromJson(e)).toList()
          : [],
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
      routeName: json['routeName'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      distance: json['distance'] ?? '',
      duration: json['duration'] ?? '',
    );
  }
}

/// Shared model for both boarding and dropping points
class StopPoint {
  final String pointName;
  final String? landmark;
  final String time;
  final double? lat;
  final double? lng;
  final String? contactNumber;

  StopPoint({
    required this.pointName,
    this.landmark,
    required this.time,
    this.lat,
    this.lng,
    this.contactNumber,
  });

  factory StopPoint.fromJson(Map<String, dynamic> json) {
    return StopPoint(
      pointName: json['pointName'] ?? '',
      landmark: json['landmark'],
      time: json['time'] ?? '',
      lat: json['coordinates'] != null ? (json['coordinates']['lat'] as num?)?.toDouble() : null,
      lng: json['coordinates'] != null ? (json['coordinates']['lng'] as num?)?.toDouble() : null,
      contactNumber: json['contactNumber'],
    );
  }
}