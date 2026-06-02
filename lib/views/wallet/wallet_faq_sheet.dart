import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sumarg/utils/app_theme.dart';

class WalletFaqSheet extends StatefulWidget {
  const WalletFaqSheet({super.key});

  /// Show the premium FAQ sheet
  static Future<void> show(BuildContext context) async {
    HapticFeedback.lightImpact();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: AppTheme.primaryDark.withOpacity(0.6), // Dim background slightly
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: const WalletFaqSheet(),
        );
      },
    );
  }

  @override
  State<WalletFaqSheet> createState() => _WalletFaqSheetState();
}

class _WalletFaqSheetState extends State<WalletFaqSheet> {
  int? _expandedIndex;

  final List<Map<String, String>> _faqs = [
    {
      'q': 'What is Shuvmarg Money?',
      'a': 'Shuvmarg Money is your secure digital wallet designed for instant, one-tap payments, guaranteed cashbacks, and a seamless booking experience on our platform.',
    },
    {
      'q': 'How do I earn Shuvmarg Money?',
      'a': 'You earn guaranteed cashback on every successful bus booking via fun Scratch Cards! You can also earn rewards by referring friends to Shuvmarg.',
    },
    {
      'q': 'What are Scratch Cards?',
      'a': 'After every confirmed booking, you receive a digital scratch card in your wallet. Tap to reveal your cashback amount! Remember to scratch them within 90 days before they expire.',
    },
    {
      'q': 'Does my Shuvmarg Money expire?',
      'a': 'Yes, earned Shuvmarg Money credits expire after 12 months. Don\'t worry — when you book a ticket, our system automatically uses your oldest-expiring credits first to maximize your value.',
    },
    {
      'q': 'Can I withdraw to my bank account?',
      'a': 'Shuvmarg Money is a closed-loop wallet built for fast, zero-friction rebooking on our platform. Currently, funds cannot be withdrawn directly to external bank accounts.',
    },
    {
      'q': 'Is my wallet secure?',
      'a': 'Absolutely. We utilize enterprise-grade encryption and require a mandatory 4-digit PIN for every single transaction, ensuring zero unauthorized access to your funds.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Height is 80% of screen
    final height = MediaQuery.of(context).size.height * 0.80;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.primaryDark, // Pure background color, no heavy gradients
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // ── Drag Handle ──
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),

          // ── Header ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Help & FAQ',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                // Minimal Close Button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppTheme.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── FAQ List ──
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0).copyWith(bottom: 40),
              physics: const BouncingScrollPhysics(),
              itemCount: _faqs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final faq = _faqs[index];
                final isExpanded = _expandedIndex == index;

                return _buildFaqCard(
                  question: faq['q']!,
                  answer: faq['a']!,
                  isExpanded: isExpanded,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _expandedIndex = isExpanded ? null : index;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqCard({
    required String question,
    required String answer,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isExpanded 
              ? Colors.white.withOpacity(0.04) 
              : Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isExpanded 
                ? AppTheme.accentLime.withOpacity(0.3)
                : Colors.white.withOpacity(0.03),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isExpanded ? AppTheme.accentLime : AppTheme.textSecondary,
                    size: 24,
                  ),
                ),
              ],
            ),
            
            // The expandable answer section
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        answer,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ),
                    )
                  : const SizedBox(width: double.infinity, height: 0),
            ),
          ],
        ),
      ),
    );
  }
}
