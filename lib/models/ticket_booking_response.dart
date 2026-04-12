class TicketBookingResponse {
  final bool status;
  final String message;
  final String ticketId;

  TicketBookingResponse({
    required this.status,
    required this.message,
    required this.ticketId,
  });

  factory TicketBookingResponse.fromJson(Map<String, dynamic> json) {
    return TicketBookingResponse(
      status: json['status'],
      message: json['message'],
      ticketId: json['ticketId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'ticketId': ticketId,
    };
  }
}
