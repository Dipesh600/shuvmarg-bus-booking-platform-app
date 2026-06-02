import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sumarg/utils/app_theme.dart';

class TicketData {
  final String ticketId;
  final String passengerName;
  final String operatorName;
  final String from;
  final String to;
  final String date;
  final String time;
  final String arrivalTime;
  final String duration;
  final String busNumber;
  final String busName;
  final List<String> seats;
  final double price;
  final double? originalPrice; // Before discount

  TicketData({
    required this.ticketId,
    required this.passengerName,
    required this.operatorName,
    required this.from,
    required this.to,
    required this.date,
    required this.time,
    this.arrivalTime = '',
    this.duration = '',
    required this.busNumber,
    required this.busName,
    required this.seats,
    required this.price,
    this.originalPrice,
  });

  /// Format raw ISO/date strings into human-readable format with day of week.
  String get formattedDate {
    try {
      final parsed = DateTime.tryParse(date);
      if (parsed != null) {
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final dayName = days[parsed.weekday - 1];
        return '${parsed.day} ${months[parsed.month - 1]}, ${parsed.year} ($dayName)';
      }
    } catch (_) {}
    return date;
  }

  /// Format time to 12h with AM/PM. If already has AM/PM, return as-is.
  static String _formatTime(String rawTime) {
    try {
      final trimmed = rawTime.trim();
      if (trimmed.isEmpty) return '';
      if (trimmed.toUpperCase().endsWith('AM') || trimmed.toUpperCase().endsWith('PM')) {
        return trimmed;
      }
      if (trimmed.contains(':')) {
        final parts = trimmed.split(':');
        int hour = int.parse(parts[0]);
        final minute = parts[1].padLeft(2, '0');
        final period = hour >= 12 ? 'PM' : 'AM';
        if (hour > 12) hour -= 12;
        if (hour == 0) hour = 12;
        return '$hour:$minute $period';
      }
    } catch (_) {}
    return rawTime;
  }

  String get formattedTime => _formatTime(time);
  String get formattedArrivalTime => _formatTime(arrivalTime);

  bool get hasArrivalTime => arrivalTime.trim().isNotEmpty;
  bool get hasDuration => duration.trim().isNotEmpty;
  bool get hasDiscount => originalPrice != null && originalPrice! > price;
}

class TicketCardWidget extends StatelessWidget {
  final TicketData ticketData;
  final Widget? qrCodeWidget;
  final Widget? actionButtons;

  const TicketCardWidget({
    super.key,
    required this.ticketData,
    this.qrCodeWidget,
    this.actionButtons,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: TicketShapeClipper(),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryDarkest.withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Status Header ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppTheme.stroke, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accentLime.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: AppTheme.accentLime.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_outline_rounded,
                                color: AppTheme.accentLime, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'Confirmed',
                              style: TextStyle(
                                color: AppTheme.accentLime,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: ticketData.ticketId));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ticket ID copied'),
                              backgroundColor: AppTheme.primary,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              ticketData.ticketId,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.copy_outlined, size: 12, color: AppTheme.textSecondary),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Route Section ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Row(
                    children: [
                      // From column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'From',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ticketData.from,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Bus icon in center
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.accentLime.withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.accentLime.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.directions_bus_outlined,
                                color: AppTheme.accentLime,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 2,
                              width: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.stroke,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // To column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'To',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ticketData.to,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Date ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: _buildInfoChip(
                    icon: Icons.calendar_today_outlined,
                    label: ticketData.formattedDate,
                    fullWidth: true,
                  ),
                ),

                // ── Departure → Arrival with Duration ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.inputBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.stroke, width: 1),
                    ),
                    child: Row(
                      children: [
                        // Departure
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Departs', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 2),
                            Text(
                              ticketData.formattedTime,
                              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        // Duration line
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              children: [
                                if (ticketData.hasDuration)
                                  Text(
                                    ticketData.duration,
                                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w500),
                                  ),
                                const SizedBox(height: 4),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(height: 1, color: AppTheme.stroke),
                                    const Icon(Icons.arrow_forward_rounded, size: 14, color: AppTheme.textSecondary),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Arrival
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Arrives', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 2),
                            Text(
                              ticketData.hasArrivalTime ? ticketData.formattedArrivalTime : '--:--',
                              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Dashed Divider (ticket tear line) ──
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    children: List.generate(
                      40,
                      (index) => Expanded(
                        child: Container(
                          height: 1,
                          color: index.isEven
                              ? AppTheme.stroke
                              : Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Bus Info (full width) ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Bus',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${ticketData.busName}  •  ${ticketData.busNumber}',
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildDetailColumn(
                          'Seat',
                          ticketData.seats.map((s) => s.toUpperCase()).join(', '),
                        ),
                      ),
                      Container(
                        height: 32,
                        width: 1,
                        color: AppTheme.stroke,
                      ),
                      Expanded(
                        child: _buildDetailColumn(
                          'Passenger',
                          ticketData.passengerName,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Price ──
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDarkest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.accentLime.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Fare',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          if (ticketData.hasDiscount) ...[
                            Text(
                              'Rs. ${ticketData.originalPrice!.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            'Rs. ${ticketData.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppTheme.accentLime,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── QR Code ──
                if (qrCodeWidget != null) ...[
                  qrCodeWidget!,
                  const SizedBox(height: 24),
                ],

                // ── Action Buttons ──
                if (actionButtons != null) ...[
                  actionButtons!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label, bool fullWidth = false}) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.inputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.stroke, width: 1),
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
    return fullWidth ? chip : Expanded(child: chip);
  }

  Widget _buildDetailColumn(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class TicketShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const cornerRadius = 24.0;
    const notchRadius = 14.0;
    // Position the notch at the dashed divider area (~55% down)
    final notchY = size.height * 0.48;

    path.moveTo(cornerRadius, 0);
    path.lineTo(size.width - cornerRadius, 0);
    path.arcToPoint(
      Offset(size.width, cornerRadius),
      radius: const Radius.circular(cornerRadius),
    );
    // Right side — top to notch
    path.lineTo(size.width, notchY - notchRadius);
    path.arcToPoint(
      Offset(size.width - notchRadius, notchY),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    path.arcToPoint(
      Offset(size.width, notchY + notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    // Right side — notch to bottom
    path.lineTo(size.width, size.height - cornerRadius);
    path.arcToPoint(
      Offset(size.width - cornerRadius, size.height),
      radius: const Radius.circular(cornerRadius),
    );
    path.lineTo(cornerRadius, size.height);
    path.arcToPoint(
      Offset(0, size.height - cornerRadius),
      radius: const Radius.circular(cornerRadius),
    );
    // Left side — bottom to notch
    path.lineTo(0, notchY + notchRadius);
    path.arcToPoint(
      Offset(notchRadius, notchY),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    path.arcToPoint(
      Offset(0, notchY - notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    // Left side — notch to top
    path.lineTo(0, cornerRadius);
    path.arcToPoint(
      Offset(cornerRadius, 0),
      radius: const Radius.circular(cornerRadius),
    );
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
