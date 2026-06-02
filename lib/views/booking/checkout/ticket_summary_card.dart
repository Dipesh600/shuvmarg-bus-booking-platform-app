import 'package:flutter/material.dart';
import 'package:sumarg/models/trip_response.dart';
import 'dart:ui';
import 'package:sumarg/utils/app_theme.dart';

class TicketSummaryCard extends StatelessWidget {
  final TripData busData;
  final String selectedSeats;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;

  const TicketSummaryCard({
    super.key,
    required this.busData,
    required this.selectedSeats,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xE000564E), // AppTheme.primary with 88% opacity
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryDarkest.withOpacity(0.4),
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
              color: AppTheme.primaryDark.withOpacity(0.4),
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
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      busData.routeDetail.from,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
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
                          style: const TextStyle(color: AppTheme.accentLime, fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.textSecondary.withOpacity(0.5))),
                            Expanded(child: Container(height: 2, color: AppTheme.textSecondary.withOpacity(0.2))),
                            const Icon(Icons.directions_bus_filled, color: AppTheme.accentLime, size: 20),
                            Expanded(child: Container(height: 2, color: AppTheme.textSecondary.withOpacity(0.2))),
                            Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.textSecondary.withOpacity(0.5))),
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
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      busData.routeDetail.to,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
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
                  color: AppTheme.primaryDarkest, // Cutout matches scaffold bg
                  borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))
                ),
              ),
              Expanded(
                child: CustomPaint(
                  painter: DashedLinePainter(color: Colors.white.withOpacity(0.1)),
                ),
              ),
              Container(
                height: 20, 
                width: 10,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryDarkest, 
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20))
                ),
              ),
            ],
          ),

          // 2. TICKET DETAILS
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow("Selected Seats", selectedSeats, "Date", busData.tripDate.split('T')[0]),
                const SizedBox(height: 24),
                _buildInfoRow("Bus Operator", busData.busDetail.busName, "Bus Number", busData.busDetail.busNumber),
                
                const SizedBox(height: 32),
                const Text("Primary Contact", style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                
                _buildInputField(label: "Full Name", controller: nameController, icon: Icons.person_outline),
                const SizedBox(height: 12),
                _buildInputField(label: "Phone Number", controller: phoneController, icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                _buildInputField(label: "Email Address (Optional)", controller: emailController, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              ],
            ),
          ),
        ],
      ),
        ),
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
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                value1,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
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
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                value2,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label, 
    required TextEditingController controller, 
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 15, fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
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
