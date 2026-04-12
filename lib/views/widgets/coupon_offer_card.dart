import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sumarg/models/get_coupn_respnse_model.dart' as list_model;
import 'package:sumarg/utils/color_constants.dart';
import 'dart:ui';

class CouponOfferCard extends StatelessWidget {
  final list_model.Coupon coupon;

  const CouponOfferCard({
    super.key,
    required this.coupon,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the badge text based on the discount type, fallback to "NEW USER"
    final badgeText = coupon.discountType.isNotEmpty ? coupon.discountType.toUpperCase() : "NEW USER";

    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondary, // Vibrant Orange or map to Cyan later
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    color: AppColors.primaryDarkest, // Dark teal text
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_offer_outlined,
                  color: AppColors.primary,
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
              color: AppColors.primaryDarkest,
              fontWeight: FontWeight.w900,
              fontSize: 18,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          // BOTTOM ROW: Promo Code and Copy
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // DASHED PROMO CODE CAPSULE
              Flexible(
                child: CustomPaint(
                  painter: _DashedBorderPainter(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    strokeWidth: 2,
                    dashWidth: 6,
                    dashSpace: 4,
                    borderRadius: 12,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Text(
                      coupon.couponCode.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primaryDarkest,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
              
              // COPY TEXT
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: coupon.couponCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Promo code '${coupon.couponCode}' copied!"),
                      backgroundColor: AppColors.primary,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: Text(
                    "Copy",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
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

    // Create a path from the RRect
    final Path path = Path()..addRRect(rrect);
    return _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    // We compute the length of each segment and draw dashes manually
    for (PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double segmentLength = draw ? dashWidth : dashSpace;
        if (draw) {
          final Path extractPath = metric.extractPath(distance, distance + segmentLength);
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
