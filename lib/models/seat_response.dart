class SeatResponse {
  final bool status;
  final String message;
  final SeatData? data;

  SeatResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory SeatResponse.fromJson(Map<String, dynamic> json) {
    return SeatResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: json['data'] != null ? SeatData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class SeatData {
  final String id;
  final String tripId;
  final List<Seat> seata;
  final List<Seat> seatb;
  final List<Seat> seatc;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  SeatData({
    required this.id,
    required this.tripId,
    required this.seata,
    required this.seatb,
    required this.seatc,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory SeatData.fromJson(Map<String, dynamic> json) {
    return SeatData(
      id: json['_id'] as String,
      tripId: json['tripId'] as String,
      seata: (json['seata'] as List?)
              ?.map((item) => Seat.fromJson(item))
              .toList() ??
          [],
      seatb: (json['seatb'] as List?)
              ?.map((item) => Seat.fromJson(item))
              .toList() ??
          [],
      seatc: (json['seatc'] as List?)
              ?.map((item) => Seat.fromJson(item))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      v: json['__v'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'tripId': tripId,
      'seata': seata.map((item) => item.toJson()).toList(),
      'seatb': seatb.map((item) => item.toJson()).toList(),
      'seatc': seatc.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}

class Seat {
  final String seatNo;
  final bool booked;
  final String? bookedBy;
  final DateTime? bookedAt;

  Seat({
    required this.seatNo,
    required this.booked,
    this.bookedBy,
    this.bookedAt,
  });

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      seatNo: json['seatNo'] as String,
      booked: json['booked'] as bool,
      bookedBy: json['bookedBy'] as String?,
      bookedAt: json['bookedAt'] != null
          ? DateTime.parse(json['bookedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seatNo': seatNo,
      'booked': booked,
      'bookedBy': bookedBy,
      'bookedAt': bookedAt?.toIso8601String(),
    };
  }
}
