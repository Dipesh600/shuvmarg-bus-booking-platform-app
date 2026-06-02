import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sumarg/utils/app_theme.dart';

class SeatsPolicyInfo extends StatelessWidget {
  const SeatsPolicyInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Seat Booking Policy",
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left_rounded, color: AppTheme.textPrimary, size: 28),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info Card
            _buildHeaderCard(),
            const SizedBox(height: 24),
            
            // Policy Points
            _buildPolicyItem(
              icon: Icons.event_seat_rounded,
              title: "Seat Selection",
              description:
                  "Seats can be selected during booking based on availability. Once selected, seats are reserved for you until the booking is confirmed or cancelled.",
            ),
            _buildPolicyItem(
              icon: Icons.cancel_schedule_send_rounded,
              title: "Cancellation Policy",
              description:
                  "Cancellations made 24 hours before departure are eligible for a full refund. Cancellations within 24 hours incur a 50% penalty. No refunds for no-shows.",
            ),
            _buildPolicyItem(
              icon: Icons.payments_rounded,
              title: "Payment and Confirmation",
              description:
                  "Full payment is required at the time of booking. A booking confirmation will be sent via email or SMS once payment is processed.",
            ),
            _buildPolicyItem(
              icon: Icons.swap_horizontal_circle_rounded,
              title: "Seat Changes",
              description:
                  "Seat changes are allowed up to 12 hours before departure, subject to availability. No additional charges apply for seat changes.",
            ),
            _buildPolicyItem(
              icon: Icons.gpp_maybe_rounded,
              title: "Non-Transferable Tickets",
              description:
                  "Tickets are non-transferable and valid only for the passenger named during booking. ID verification may be required at boarding.",
            ),
            _buildPolicyItem(
              icon: Icons.support_agent_rounded,
              title: "Contact Support",
              description:
                  "For any issues or inquiries regarding your booking, contact our support team via email or phone, available 24/7.",
            ),
            const SizedBox(height: 16),
            
            // Footer Note
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentLime.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.accentLime.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppTheme.accentLime, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Note: Policies are subject to change. Please check our website for the latest updates.",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary.withOpacity(0.9),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.stroke, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Our Booking Policy",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Please read these terms carefully before finalizing your booking. By proceeding, you agree to these conditions.",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xE000564E), // AppTheme.primary with 88% opacity
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.stroke, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentLime.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.accentLime.withOpacity(0.3), width: 1),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.accentLime,
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
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
