import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sumarg/models/get_coupn_respnse_model.dart' as list_model;
import 'package:sumarg/utils/app_theme.dart';
import 'package:sumarg/widgets/glass_card.dart';

class CouponOfferCard extends StatelessWidget {
  final list_model.Coupon coupon;

  const CouponOfferCard({
    super.key,
    required this.coupon,
  });

  bool get _isExpired => DateTime.now().isAfter(coupon.validTo);
  bool get _isUpcoming => DateTime.now().isBefore(coupon.validFrom);

  @override
  Widget build(BuildContext context) {
    final badgeText = coupon.discountType.isNotEmpty
        ? coupon.discountType.toUpperCase()
        : "NEW USER";

    final card = Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Stack(
        children: [
          // Main card
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // TOP ROW: Badge and Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.accentLime.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color:
                                AppTheme.accentLime.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          color: AppTheme.accentLime,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 0.5,
                          fontFamily: AppTheme.fontFamily,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_offer_outlined,
                        color: AppTheme.accentLime,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // TITLE
                Text(
                  coupon.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    height: 1.2,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),

                // Expiry countdown (only for active offers)
                if (!_isExpired && !_isUpcoming) ...[
                  const SizedBox(height: 4),
                  _ExpiryRow(validTo: coupon.validTo),
                ],

                const SizedBox(height: 12),

                // BOTTOM ROW: Promo Code and Copy
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // DASHED PROMO CODE CAPSULE
                    Flexible(
                      child: CustomPaint(
                        painter: _DashedBorderPainter(
                          color: AppTheme.accentLime.withValues(alpha: 0.5),
                          strokeWidth: 2,
                          dashWidth: 6,
                          dashSpace: 4,
                          borderRadius: 12,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Text(
                            coupon.couponCode.toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.accentLime,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 1.5,
                              fontFamily: AppTheme.fontFamily,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),

                    // COPY button — hidden when expired
                    if (!_isExpired)
                      InkWell(
                        onTap: () {
                          Clipboard.setData(
                              ClipboardData(text: coupon.couponCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Promo code '${coupon.couponCode}' copied!",
                                style: const TextStyle(
                                    color: AppTheme.primaryDarkest),
                              ),
                              backgroundColor: AppTheme.accentLime,
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.accentLime,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Copy",
                            style: TextStyle(
                              color: AppTheme.primaryDarkest,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: AppTheme.fontFamily,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // EXPIRED label badge (top-right corner)
          if (_isExpired)
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "EXPIRED",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
              ),
            ),

          // UPCOMING label badge
          if (_isUpcoming)
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade800.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "UPCOMING",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    // Wrap expired cards in grayscale + reduced opacity
    if (_isExpired) {
      return ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0,      0,      0,      1, 0,
        ]),
        child: Opacity(opacity: 0.60, child: card),
      );
    }

    return card;
  }
}

// Live countdown label below the title
class _ExpiryRow extends StatelessWidget {
  final DateTime validTo;
  const _ExpiryRow({required this.validTo});

  String _label() {
    final diff = validTo.difference(DateTime.now());
    if (diff.inDays > 1) return "Expires in ${diff.inDays} days";
    if (diff.inHours >= 1) return "Expires in ${diff.inHours} hrs";
    if (diff.inMinutes >= 1) return "Expires in ${diff.inMinutes} min";
    return "Expiring very soon!";
  }

  Color _color() {
    final diff = validTo.difference(DateTime.now());
    if (diff.inDays <= 1) return Colors.redAccent;
    if (diff.inDays <= 3) return Colors.orangeAccent;
    return AppTheme.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.schedule_rounded, size: 12, color: _color()),
        const SizedBox(width: 4),
        Text(
          _label(),
          style: TextStyle(
            color: _color(),
            fontSize: 11,
            fontWeight: FontWeight.w500,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
    this.borderRadius = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final Path path = Path()..addRRect(rrect);
    return _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    for (PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double segmentLength = draw ? dashWidth : dashSpace;
        if (draw) {
          final Path extractPath =
              metric.extractPath(distance, distance + segmentLength);
          canvas.drawPath(extractPath, paint);
        }
        distance += segmentLength;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace ||
        oldDelegate.borderRadius != borderRadius;
  }
}
