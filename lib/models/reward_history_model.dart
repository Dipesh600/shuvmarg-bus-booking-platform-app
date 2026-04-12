import 'dart:convert';

class RewardHistoryResponse {
  final bool status;
  final String message;
  final List<RewardHistory> data;

  RewardHistoryResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RewardHistoryResponse.fromJson(Map<String, dynamic> json) {
    return RewardHistoryResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => RewardHistory.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data.map((e) => e.toJson()).toList(),
      };

  static RewardHistoryResponse fromJsonString(String str) =>
      RewardHistoryResponse.fromJson(json.decode(str));

  String toJsonString() => json.encode(toJson());
}

class RewardHistory {
  final String id;
  final String userId;
  final String type;
  final num points;
  final num balanceBefore;
  final num balanceAfter;
  final String bookingId;
  final String scheduleId;
  final String ticketId;
  final String description;
  final Meta meta;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  RewardHistory({
    required this.id,
    required this.userId,
    required this.type,
    required this.points,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.bookingId,
    required this.scheduleId,
    required this.ticketId,
    required this.description,
    required this.meta,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory RewardHistory.fromJson(Map<String, dynamic> json) {
    return RewardHistory(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      points: json['points'] ?? 0,
      balanceBefore: json['balanceBefore'] ?? 0,
      balanceAfter: json['balanceAfter'] ?? 0,
      bookingId: json['bookingId'] ?? '',
      scheduleId: json['scheduleId'] ?? '',
      ticketId: json['ticketId'] ?? '',
      description: json['description'] ?? '',
      meta: Meta.fromJson(json['meta'] ?? {}),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'userId': userId,
        'type': type,
        'points': points,
        'balanceBefore': balanceBefore,
        'balanceAfter': balanceAfter,
        'bookingId': bookingId,
        'scheduleId': scheduleId,
        'ticketId': ticketId,
        'description': description,
        'meta': meta.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        '__v': v,
      };
}

class Meta {
  final num originalAmount;
  final num finalAmount;
  final List<String> seats;

  Meta({
    required this.originalAmount,
    required this.finalAmount,
    required this.seats,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      originalAmount: num.tryParse(json['originalAmount'].toString()) ?? 0,
      finalAmount: num.tryParse(json['finalAmount'].toString()) ?? 0,
      seats: (json['seats'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'originalAmount': originalAmount,
        'finalAmount': finalAmount,
        'seats': seats,
      };
}
