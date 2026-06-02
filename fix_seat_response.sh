cat << 'INNER_EOF' > /Users/dipeshchaudhary/Downloads/Shuvmarg/sumarg-buss-bookin-app/lib/models/seat_response.dart
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
      status: json['status'] == true || json['status'] == 'true',
      message: json['message']?.toString() ?? '',
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
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int v;

  SeatData({
    required this.id,
    required this.tripId,
    required this.seata,
    required this.seatb,
    required this.seatc,
    this.createdAt,
    this.updatedAt,
    required this.v,
  });

  factory SeatData.fromJson(Map<String, dynamic> json) {
    return SeatData(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      tripId: json['tripId']?.toString() ?? '',
      seata: (json['seata'] as List?)
              ?.where((item) => item != null)
              .map((item) => Seat.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      seatb: (json['seatb'] as List?)
              ?.where((item) => item != null)
              .map((item) => Seat.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      seatc: (json['seatc'] as List?)
              ?.where((item) => item != null)
              .map((item) => Seat.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
      v: (json['__v'] ?? 0) is num ? (json['__v'] as num).toInt() : int.tryParse(json['__v']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'tripId': tripId,
      'seata': seata.map((item) => item.toJson()).toList(),
      'seatb': seatb.map((item) => item.toJson()).toList(),
      'seatc': seatc.map((item) => item.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
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
      seatNo: json['seatNo']?.toString() ?? '',
      booked: json['booked'] == true || json['booked'] == 'true',
      bookedBy: json['bookedBy']?.toString(),
      bookedAt: json['bookedAt'] != null
          ? DateTime.tryParse(json['bookedAt'].toString())
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
INNER_EOF
