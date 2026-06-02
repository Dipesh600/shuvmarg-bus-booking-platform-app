import 'package:flutter/material.dart';
import 'package:sumarg/utils/app_theme.dart';
import 'dart:ui';

/// Price breakdown and total amount display for the checkout flow.
///
/// Updated for split-payment: Shows SM Money deduction and gateway payable
/// amount separately when SM Money is applied.
class PriceBreakdownSection extends StatelessWidget {
  final int subtotalPrice;
  final int finalPrice;
  final bool isCouponApplied;
  final double discountAmount;

  // SM Money split-payment fields
  final bool isSmMoneyApplied;
  final int smMoneyAmount;
  final int gatewayPayable;

  const PriceBreakdownSection({
    super.key,
    required this.subtotalPrice,
    required this.finalPrice,
    required this.isCouponApplied,
    required this.discountAmount,
    this.isSmMoneyApplied = false,
    this.smMoneyAmount = 0,
    this.gatewayPayable = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xE000564E), // AppTheme.primary with opacity
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long_rounded, color: AppTheme.textSecondary, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    "Price Breakdown",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildRow("Subtotal", "Rs. $subtotalPrice", isHighlight: false),
              
              if (isCouponApplied) ...[
                const SizedBox(height: 12),
                _buildRow("Coupon Discount", "- Rs. ${discountAmount.round()}", isHighlight: true),
              ],
              
              if (isSmMoneyApplied && smMoneyAmount > 0) ...[
                const SizedBox(height: 12),
                _buildRow(
                  "SM Money",
                  "- Rs. $smMoneyAmount",
                  isHighlight: true,
                  icon: Icons.account_balance_wallet_rounded,
                ),
              ],
              
              const SizedBox(height: 20),
              Container(
                height: 1,
                color: Colors.white.withOpacity(0.1),
              ),
              const SizedBox(height: 20),
              
              // If split payment, show gateway payable separately
              if (isSmMoneyApplied && smMoneyAmount > 0 && gatewayPayable > 0) ...[
                _buildRow(
                  "Pay via Gateway",
                  "Rs. $gatewayPayable",
                  isHighlight: false,
                  isBold: true,
                ),
                const SizedBox(height: 8),
              ],

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Amount",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Show original price crossed out if there's any discount
                      if (isCouponApplied || (isSmMoneyApplied && smMoneyAmount > 0))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            "Rs. $subtotalPrice",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondary.withOpacity(0.5),
                              decoration: TextDecoration.lineThrough,
                              decorationColor: AppTheme.textSecondary.withOpacity(0.5),
                            ),
                          ),
                        ),
                      Text(
                        "Rs. $finalPrice",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.accentLime,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Zero-gateway message when 100% paid via SM Money
              if (isSmMoneyApplied && gatewayPayable <= 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentLime.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.accentLime.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.wallet_rounded,
                        color: AppTheme.accentLime,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "Fully paid with SM Money — no gateway payment needed!",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.accentLime,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    required bool isHighlight,
    IconData? icon,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppTheme.accentLime, size: 14),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: isHighlight ? AppTheme.accentLime : AppTheme.textSecondary,
                fontWeight: isHighlight || isBold ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            color: isHighlight ? AppTheme.accentLime : AppTheme.textPrimary,
            fontWeight: isHighlight || isBold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
