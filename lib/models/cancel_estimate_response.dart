/// Model for the cancel estimate response from the backend.
/// Used to display the refund breakdown to the user before they confirm cancellation.
class CancelEstimateResponse {
  final bool status;
  final String message;
  final CancelEstimateData? data;

  CancelEstimateResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory CancelEstimateResponse.fromJson(Map<String, dynamic> json) {
    return CancelEstimateResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? CancelEstimateData.fromJson(json['data'])
          : null,
    );
  }
}

class CancelEstimateData {
  final String ticketId;
  final int ticketFare;
  final bool eligible;
  final String? reason;
  final int refundAmount;
  final int cancellationCharge;
  final int gatewayDeduction;
  final double refundPercentage;
  final double hoursBeforeDeparture;
  final AppliedPolicy? appliedPolicy;

  CancelEstimateData({
    required this.ticketId,
    required this.ticketFare,
    required this.eligible,
    this.reason,
    required this.refundAmount,
    required this.cancellationCharge,
    required this.gatewayDeduction,
    required this.refundPercentage,
    required this.hoursBeforeDeparture,
    this.appliedPolicy,
  });

  factory CancelEstimateData.fromJson(Map<String, dynamic> json) {
    return CancelEstimateData(
      ticketId: json['ticketId'] ?? '',
      ticketFare: json['ticketFare'] ?? 0,
      eligible: json['eligible'] ?? false,
      reason: json['reason'],
      refundAmount: json['refundAmount'] ?? 0,
      cancellationCharge: json['cancellationCharge'] ?? 0,
      gatewayDeduction: json['gatewayDeduction'] ?? 0,
      refundPercentage: (json['refundPercentage'] ?? 0).toDouble(),
      hoursBeforeDeparture: (json['hoursBeforeDeparture'] ?? 0).toDouble(),
      appliedPolicy: json['appliedPolicy'] != null
          ? AppliedPolicy.fromJson(json['appliedPolicy'])
          : null,
    );
  }
}

class AppliedPolicy {
  final String? id;
  final String name;
  final String description;

  AppliedPolicy({
    this.id,
    required this.name,
    required this.description,
  });

  factory AppliedPolicy.fromJson(Map<String, dynamic> json) {
    return AppliedPolicy(
      id: json['id'],
      name: json['name'] ?? 'Default Policy',
      description: json['description'] ?? '',
    );
  }
}
