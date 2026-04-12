import 'package:flutter/material.dart';
import 'package:sumarg/utils/color_constants.dart';

class SeatsPolicyInfo extends StatelessWidget {
  const SeatsPolicyInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          "Seat Booking Policy",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Our Booking Policy",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Policy Points
            _buildPolicyItem(
              icon: Icons.event_seat,
              title: "Seat Selection",
              description:
                  "Seats can be selected during booking based on availability. Once selected, seats are reserved for you until the booking is confirmed or cancelled.",
            ),
            _buildPolicyItem(
              icon: Icons.cancel,
              title: "Cancellation Policy",
              description:
                  "Cancellations made 24 hours before departure are eligible for a full refund. Cancellations within 24 hours incur a 50% penalty. No refunds for no-shows.",
            ),
            _buildPolicyItem(
              icon: Icons.payment,
              title: "Payment and Confirmation",
              description:
                  "Full payment is required at the time of booking. A booking confirmation will be sent via email or SMS once payment is processed.",
            ),
            _buildPolicyItem(
              icon: Icons.swap_horiz,
              title: "Seat Changes",
              description:
                  "Seat changes are allowed up to 12 hours before departure, subject to availability. No additional charges apply for seat changes.",
            ),
            _buildPolicyItem(
              icon: Icons.warning,
              title: "Non-Transferable Tickets",
              description:
                  "Tickets are non-transferable and valid only for the passenger named during booking. ID verification may be required at boarding.",
            ),
            _buildPolicyItem(
              icon: Icons.info,
              title: "Contact Support",
              description:
                  "For any issues or inquiries regarding your booking, contact our support team via email or phone, available 24/7.",
            ),
            const SizedBox(height: 24),
            // Footer Note
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Note: Policies are subject to change. Please check our website for the latest updates.",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.text,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.text,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
