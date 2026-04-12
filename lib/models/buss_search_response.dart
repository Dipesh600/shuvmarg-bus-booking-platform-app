class BusSearchResponse {
  final bool status;
  final String message;
  final int results;
  final List<BusData> data;

  BusSearchResponse({
    required this.status,
    required this.message,
    required this.results,
    required this.data,
  });

  factory BusSearchResponse.fromJson(Map<String, dynamic> json) {
    return BusSearchResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      results: json['results'] ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => BusData.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'results': results,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class BusData {
  final RouteInfo route;
  final String id;
  final String operatorName;
  final String operatorId;
  final String operatorRole;
  final String bussName;
  final String bussNo;
  final String vehicleType;
  final String departureTime;
  final String arrivalTime;
  final String date;
  final int price;
  final int yatrapoints;
  final int totalSeats;
  final String totalTimeTaken;
  final String shift;
  final String? thumbnail;
  final List<String> boardingPoints;
  final List<String> amenities;
  final String createdAt;
  final String updatedAt;
  final int v;

  BusData({
    required this.route,
    required this.id,
    required this.operatorName,
    required this.operatorId,
    required this.operatorRole,
    required this.bussName,
    required this.bussNo,
    required this.vehicleType,
    required this.departureTime,
    required this.arrivalTime,
    required this.date,
    required this.price,
    required this.yatrapoints,
    required this.totalSeats,
    required this.totalTimeTaken,
    required this.shift,
    this.thumbnail,
    required this.boardingPoints,
    required this.amenities,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory BusData.fromJson(Map<String, dynamic> json) {
    return BusData(
      route: RouteInfo.fromJson(json['route']),
      id: json['_id'] ?? '',
      operatorName: json['operatorName'] ?? '',
      operatorId: json['operatorId'] ?? '',
      operatorRole: json['operatorRole'] ?? '',
      bussName: json['bussName'] ?? '',
      bussNo: json['bussNo'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
      departureTime: json['departureTime'] ?? '',
      arrivalTime: json['arrivalTime'] ?? '',
      date: json['date'] ?? '',
      price: json['price'] ?? 0,
      yatrapoints: json['yatrapoints'] ?? 0,
      totalSeats: json['totalSeats'] ?? 0,
      totalTimeTaken: json['totalTimeTaken'] ?? '',
      shift: json['shift'] ?? '',
      thumbnail: json['thumbnail'],
      boardingPoints: List<String>.from(json['boardingPoints'] ?? []),
      amenities: List<String>.from(json['amenities'] ?? []),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'route': route.toJson(),
      '_id': id,
      'operatorName': operatorName,
      'operatorId': operatorId,
      'operatorRole': operatorRole,
      'bussName': bussName,
      'bussNo': bussNo,
      'vehicleType': vehicleType,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'date': date,
      'price': price,
      'yatrapoints': yatrapoints,
      'totalSeats': totalSeats,
      'totalTimeTaken': totalTimeTaken,
      'shift': shift,
      'thumbnail': thumbnail,
      'boardingPoints': boardingPoints,
      'amenities': amenities,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}

class RouteInfo {
  final String from;
  final String to;

  RouteInfo({
    required this.from,
    required this.to,
  });

  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    return RouteInfo(
      from: json['from'] ?? '',
      to: json['to'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
    };
  }
}
