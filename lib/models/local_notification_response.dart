class LocalNotificationResponse {
  final bool status;
  final List<NotificationItem> notifications;

  LocalNotificationResponse({
    required this.status,
    required this.notifications,
  });

  factory LocalNotificationResponse.fromJson(
      Map<String, dynamic> json) {
    return LocalNotificationResponse(
      status: json['status'] ?? false,
      notifications: (json['notifications'] as List<dynamic>?)
              ?.map((e) => NotificationItem.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'notifications': notifications.map((e) => e.toJson()).toList(),
    };
  }
}

class NotificationItem {
  final String id;
  final String user;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final Meta meta;
  final String createdAt;
  final int v;

  NotificationItem({
    required this.id,
    required this.user,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.meta,
    required this.createdAt,
    required this.v,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['_id'] ?? '',
      user: json['user'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['isRead'] ?? false,
      meta: Meta.fromJson(json['meta'] ?? {}),
      createdAt: json['createdAt'] ?? '',
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'type': type,
      'title': title,
      'message': message,
      'isRead': isRead,
      'meta': meta.toJson(),
      'createdAt': createdAt,
      '__v': v,
    };
  }
}

class Meta {
  final String scheduleId;
  final List<String> seats;
  final int totalAmount;

  Meta({
    required this.scheduleId,
    required this.seats,
    required this.totalAmount,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      scheduleId: json['scheduleId'] ?? '',
      seats: (json['seats'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      totalAmount: int.tryParse(json['totalAmount'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scheduleId': scheduleId,
      'seats': seats,
      'totalAmount': totalAmount,
    };
  }
}
