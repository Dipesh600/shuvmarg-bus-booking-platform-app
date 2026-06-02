import 'package:flutter/material.dart';

import 'package:sumarg/utils/app_theme.dart';

/// Coupon input and validation section for the checkout flow.
class CouponSection extends StatelessWidget {
  final TextEditingController controller;
  final bool isExpanded;
  final bool isApplying;
  final bool isApplied;
  final String? message;
  final VoidCallback onToggleExpanded;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  const CouponSection({
    super.key,
    required this.controller,
    required this.isExpanded,
    required this.isApplying,
    required this.isApplied,
    required this.message,
    required this.onToggleExpanded,
    required this.onApply,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        GestureDetector(
          onTap: onToggleExpanded,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.accentLime.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.local_offer_rounded, color: AppTheme.accentLime, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Have a Coupon Code?",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 24,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Expanded Content
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: isExpanded
              ? Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller,
                                enabled: !isApplied,
                                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                                decoration: InputDecoration(
                                  hintText: 'Enter code',
                                  hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5), fontSize: 15),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                                textCapitalization: TextCapitalization.characters,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: GestureDetector(
                                onTap: isApplied ? onRemove : (isApplying ? null : onApply),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: isApplied ? AppTheme.error.withOpacity(0.15) : AppTheme.accentLime.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  alignment: Alignment.center,
                                  child: isApplying
                                      ? const SizedBox(
                                          width: 16, height: 16,
                                          child: CircularProgressIndicator(color: AppTheme.accentLime, strokeWidth: 2),
                                        )
                                      : Text(
                                          isApplied ? "Remove" : "Apply",
                                          style: TextStyle(
                                            color: isApplied ? AppTheme.error : AppTheme.accentLime,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      if (message != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              isApplied ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                              color: isApplied ? AppTheme.success : AppTheme.error,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                message!,
                                style: TextStyle(
                                  color: isApplied ? AppTheme.success : AppTheme.error,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
