class TicketBookingResponse {
  final bool status;
  final String message;
  final String? ticketId;
  final String? caseId; // For disputed payments
  final String? scratchCardId;

  TicketBookingResponse({
    required this.status,
    required this.message,
    this.ticketId,
    this.caseId,
    this.scratchCardId,
  });

  factory TicketBookingResponse.fromJson(Map<String, dynamic> json) {
    return TicketBookingResponse(
      status: json['status'] ?? json['success'] ?? false, // handle both success/status keys
      message: json['message'] ?? '',
      ticketId: json['data']?['ticketId'] ?? json['ticketId'],
      caseId: json['data']?['caseId'] ?? json['caseId'],
      scratchCardId: json['data']?['scratchCardId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'ticketId': ticketId,
      'caseId': caseId,
      'scratchCardId': scratchCardId,
    };
  }
}
