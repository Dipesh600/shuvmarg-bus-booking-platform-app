import 'package:flutter/material.dart';
import 'package:sumarg/models/trip_response.dart';
import 'package:sumarg/utils/color_constants.dart';

class TicketSummaryCard extends StatelessWidget {
  final TripData busData;
  final String selectedSeats;
  final String passengerName;

  const TicketSummaryCard({
    super.key,
    required this.busData,
    required this.selectedSeats,
    required this.passengerName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryDarkest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryDark.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDarkest.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. TIMELINE HEADER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withOpacity(0.4),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Departure
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      busData.departureTime,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      busData.routeDetail.from,
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                
                // Duration Arrow
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Text(
                          busData.routeDetail.duration,
                          style: const TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryLight)),
                            Expanded(child: Container(height: 2, color: AppColors.primaryLight.withOpacity(0.4))),
                            const Icon(Icons.directions_bus_filled, color: AppColors.primaryLight, size: 20),
                            Expanded(child: Container(height: 2, color: AppColors.primaryLight.withOpacity(0.4))),
                            Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryLight)),
                          ],
                        )
                      ],
                    ),
                  ),
                ),

                // Arrival
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      busData.arrivalTime,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      busData.routeDetail.to,
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Ticket Perforation Divider
          Row(
            children: [
              Container(
                height: 20, 
                width: 10,
                decoration: const BoxDecoration(
                  color: AppColors.white, // Match background Color
                  borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))
                ),
              ),
              Expanded(
                child: CustomPaint(
                  painter: DashedLinePainter(color: AppColors.primaryLight.withOpacity(0.3)),
                ),
              ),
              Container(
                height: 20, 
                width: 10,
                decoration: const BoxDecoration(
                  color: AppColors.white, // Match background Color
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20))
                ),
              ),
            ],
          ),

          // 2. TICKET DETAILS
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildInfoRow("Passenger", passengerName, "Date", busData.tripDate),
                const SizedBox(height: 24),
                _buildInfoRow("Selected Seats", selectedSeats, "Booking Time", "Now"),
                const SizedBox(height: 24),
                _buildInfoRow("Bus Operator", busData.busDetail.busName, "Bus Number", busData.busDetail.busNumber),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label1, String value1, String label2, String value2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label1,
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                value1,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                label2,
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                value2,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double dashWidth = 8;
    double dashSpace = 6;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
