import 'package:flutter/material.dart';
import 'package:sumarg/utils/app_theme.dart';

/// SM Money toggle widget for the checkout flow.
///
/// This replaces the old YatraPoints section with a simple toggle design:
///   - Shows available SM Money balance
///   - Toggle switch to apply/remove
///   - Real-time display of how much SM Money will be used
///   - Server-computed amount (capped at 80% combined with coupon)
///
/// Unlike the old input-based YatraPoints, SM Money is always "use max" or "use none".
/// The server handles capping, FIFO, and validation — the toggle just sends the balance.
class SmMoneySection extends StatelessWidget {
  /// Whether SM Money is toggled on (user wants to use it)
  final bool isEnabled;

  /// Whether balance is still loading from API
  final bool isLoading;

  /// User's current spendable balance (from computeSpendableBalance)
  final int availableBalance;

  /// Server-computed amount that will actually be applied (after 80% cap)
  final int appliedAmount;

  /// Maximum SM Money allowed by the 80% combined cap
  final int maxAllowed;

  /// Toggle callback — true = enable, false = disable
  final ValueChanged<bool> onToggle;

  const SmMoneySection({
    super.key,
    required this.isEnabled,
    required this.isLoading,
    required this.availableBalance,
    required this.appliedAmount,
    required this.maxAllowed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show the section if user has no SM Money at all
    if (!isLoading && availableBalance <= 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header row with toggle ──────────────────────────────────
        Row(
          children: [
            // Icon badge
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.accentLime.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: AppTheme.accentLime,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),

            // Label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Use SM Money",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  isLoading
                      ? Row(
                          children: [
                            SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(
                                color: AppTheme.accentLime.withOpacity(0.6),
                                strokeWidth: 1.5,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Loading balance...",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          "Balance: Rs. $availableBalance",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ],
              ),
            ),

            // Toggle switch
            Transform.scale(
              scale: 0.85,
              child: Switch.adaptive(
                value: isEnabled,
                onChanged: isLoading || availableBalance <= 0 ? null : onToggle,
                activeColor: AppTheme.accentLime,
                activeTrackColor: AppTheme.accentLime.withOpacity(0.3),
                inactiveThumbColor: AppTheme.textSecondary.withOpacity(0.4),
                inactiveTrackColor: Colors.white.withOpacity(0.06),
              ),
            ),
          ],
        ),

        // ── Applied amount detail (shown when toggled on) ───────────
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: isEnabled && !isLoading
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentLime.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.accentLime.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppTheme.accentLime,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                                fontFamily: 'Satoshi',
                              ),
                              children: [
                                const TextSpan(text: "Rs. "),
                                TextSpan(
                                  text: "$appliedAmount",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.accentLime,
                                  ),
                                ),
                                const TextSpan(
                                  text: " will be deducted from SM Money",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // ── Cap notice (if SM Money is capped below balance) ────────
        if (isEnabled &&
            !isLoading &&
            appliedAmount < availableBalance &&
            appliedAmount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.textSecondary.withOpacity(0.6),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "SM Money capped at Rs. $maxAllowed (max 80% of ticket price after other discounts)",
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
