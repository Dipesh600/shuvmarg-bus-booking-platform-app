class TicketHistoryResponse {
  final bool status;
  final String message;
  final List<TicketHistoryData> data;

  TicketHistoryResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory TicketHistoryResponse.fromJson(Map<String, dynamic> json) {
    return TicketHistoryResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => TicketHistoryData.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class TicketHistoryData {
  final Booking booking;
  final Trip? trip;
  final Payment? payment;
  final RefundInfo? refund;

  TicketHistoryData({
    required this.booking,
    this.trip,
    this.payment,
    this.refund,
  });

  factory TicketHistoryData.fromJson(Map<String, dynamic> json) {
    return TicketHistoryData(
      booking: Booking.fromJson(json['booking']),
      trip: json['trip'] != null ? Trip.fromJson(json['trip']) : null,
      payment: json['payment'] != null ? Payment.fromJson(json['payment']) : null,
      refund: json['refund'] != null ? RefundInfo.fromJson(json['refund']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking': booking.toJson(),
      'trip': trip?.toJson(),
      'payment': payment?.toJson(),
      'refund': refund?.toJson(),
    };
  }
}

class Booking {
  final List<String> seats;
  final int totalAmount;
  final String status;
  final String refundStatus;
  final int refundAmount;
  final String ticketId;
  final String bookingId;
  final bool review;
  final String id;

  Booking({
    required this.seats,
    required this.totalAmount,
    required this.status,
    required this.refundStatus,
    required this.refundAmount,
    required this.ticketId,
    required this.bookingId,
    required this.review,
    required this.id,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      seats: List<String>.from(json['seats'] ?? []),
      totalAmount: json['totalAmount'] ?? 0,
      status: json['status'] ?? '',
      refundStatus: json['refundStatus'] ?? '',
      refundAmount: json['refundAmount'] ?? 0,
      ticketId: json['ticketId'] ?? '',
      bookingId: json['bookingId'] ?? '',
      review: json['review'] ?? false,
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seats': seats,
      'totalAmount': totalAmount,
      'status': status,
      'refundStatus': refundStatus,
      'refundAmount': refundAmount,
      'ticketId': ticketId,
      'bookingId': bookingId,
      'review': review,
      '_id': id,
    };
  }
}

class Trip {
  final String id;
  final String tripId;
  final BusId busId;
  final String tripDate;
  final String departureTime;
  final String arrivalTime;
  final int tripFare;
  final String status;
  final RouteDetail routeDetail;

  Trip({
    required this.id,
    required this.tripId,
    required this.busId,
    required this.tripDate,
    required this.departureTime,
    required this.arrivalTime,
    required this.tripFare,
    required this.status,
    required this.routeDetail,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['_id'] ?? '',
      tripId: json['tripId'] ?? '',
      busId: BusId.fromJson(json['busId']),
      tripDate: json['tripDate'] ?? '',
      departureTime: json['departureTime'] ?? '',
      arrivalTime: json['arrivalTime'] ?? '',
      tripFare: json['tripFare'] ?? 0,
      status: json['status'] ?? '',
      routeDetail: RouteDetail.fromJson(json['routeDetail']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'tripId': tripId,
      'busId': busId.toJson(),
      'tripDate': tripDate,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'tripFare': tripFare,
      'status': status,
      'routeDetail': routeDetail.toJson(),
    };
  }
}

class BusId {
  final String id;
  final String busName;
  final String busNumber;
  final String busType;
  final int totalSeats;

  BusId({
    required this.id,
    required this.busName,
    required this.busNumber,
    required this.busType,
    required this.totalSeats,
  });

  factory BusId.fromJson(Map<String, dynamic> json) {
    return BusId(
      id: json['_id'] ?? '',
      busName: json['busName'] ?? '',
      busNumber: json['busNumber'] ?? '',
      busType: json['busType'] ?? '',
      totalSeats: json['totalSeats'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'busName': busName,
      'busNumber': busNumber,
      'busType': busType,
      'totalSeats': totalSeats,
    };
  }
}

class RouteDetail {
  final String id;
  final String routeName;
  final String from;
  final String to;

  RouteDetail({
    required this.id,
    required this.routeName,
    required this.from,
    required this.to,
  });

  factory RouteDetail.fromJson(Map<String, dynamic> json) {
    return RouteDetail(
      id: json['_id'] ?? '',
      routeName: json['routeName'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'routeName': routeName,
      'from': from,
      'to': to,
    };
  }
}

class Payment {
  final String gateway;
  final String transactionId;
  final String status;
  final int totalAmount;
  final String paidAt;

  Payment({
    required this.gateway,
    required this.transactionId,
    required this.status,
    required this.totalAmount,
    required this.paidAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      gateway: json['gateway'] ?? '',
      transactionId: json['transactionId'] ?? '',
      status: json['status'] ?? '',
      totalAmount: json['totalAmount'] ?? 0,
      paidAt: json['paidAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gateway': gateway,
      'transactionId': transactionId,
      'status': status,
      'totalAmount': totalAmount,
      'paidAt': paidAt,
    };
  }
}

class RefundInfo {
  final int refundAmount;
  final int cancellationCharge;
  final int originalAmount;
  final String status;
  final String? requestedAt;
  final String? processedAt;
  final String? completedAt;
  final String? reason;
  final String? remarks;
  final String? refundGateway;

  RefundInfo({
    required this.refundAmount,
    required this.cancellationCharge,
    required this.originalAmount,
    required this.status,
    this.requestedAt,
    this.processedAt,
    this.completedAt,
    this.reason,
    this.remarks,
    this.refundGateway,
  });

  factory RefundInfo.fromJson(Map<String, dynamic> json) {
    return RefundInfo(
      refundAmount: json['refundAmount'] ?? 0,
      cancellationCharge: json['cancellationCharge'] ?? 0,
      originalAmount: json['originalAmount'] ?? 0,
      status: json['status'] ?? 'pending',
      requestedAt: json['requestedAt'],
      processedAt: json['processedAt'],
      completedAt: json['completedAt'],
      reason: json['reason'],
      remarks: json['remarks'],
      refundGateway: json['refundGateway'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'refundAmount': refundAmount,
      'cancellationCharge': cancellationCharge,
      'originalAmount': originalAmount,
      'status': status,
      'requestedAt': requestedAt,
      'processedAt': processedAt,
      'completedAt': completedAt,
      'reason': reason,
      'remarks': remarks,
      'refundGateway': refundGateway,
    };
  }
}
