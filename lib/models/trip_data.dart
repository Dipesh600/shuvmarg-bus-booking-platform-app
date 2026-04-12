class TripData {
  final String tripId;
  final String busNumber;
  final String from;
  final String to;
  final String date;
  final String time;
  final String status; // 'upcoming', 'completed', 'cancelled'
  final String operatorName;
  final List<String> seats;
  final double price;
  final String bookingId;
  final String ticketId;
  final String passengerName;
  final bool review;

  TripData({
    required this.tripId,
    required this.busNumber,
    required this.from,
    required this.to,
    required this.date,
    required this.time,
    required this.status,
    required this.operatorName,
    required this.seats,
    required this.price,
    required this.bookingId,
    required this.ticketId,
    required this.review,
    required this.passengerName,
  });

  // Add fromJson method if you need to parse from JSON
  factory TripData.fromJson(Map<String, dynamic> json) {
    return TripData(
      tripId: json['tripId'] ?? '',
      busNumber: json['busNumber'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      status: json['status'] ?? 'upcoming',
      operatorName: json['operatorName'] ?? '',
      seats: List<String>.from(json['seats'] ?? []),
      price: (json['price'] ?? 0).toDouble(),
      bookingId: json['bookingId'] ?? '',
      ticketId: json['ticketId'] ?? '',
      passengerName: json['passengerName'] ?? '',
      review: json['review'] ?? false,

    );
  }
}
