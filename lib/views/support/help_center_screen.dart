import 'package:flutter/material.dart';
import 'package:sumarg/utils/color_constants.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  List<Map<String, String>> get _faqs => const [
        {
          'q': 'How do I book a bus ticket?',
          'a': 'Search your route and date on Home, choose a bus, select seats, enter passenger details, then confirm and pay.'
        },
        {
          'q': 'Can I cancel or change my ticket?',
          'a': 'Cancellation and change policies depend on the bus operator. Check your ticket details page for eligibility and request options.'
        },
        {
          'q': 'I did not receive my ticket.',
          'a': 'Check your Trips or Tickets section and ensure notifications or email are enabled. If still missing, contact support with your phone and trip details.'
        },
        {
          'q': 'Payment was deducted but ticket not issued.',
          'a': 'Sometimes payments take a few minutes to confirm. If not resolved within 30 minutes, share the transaction reference with support to investigate.'
        },
        {
          'q': 'How do I apply a coupon?',
          'a': 'On the checkout page, tap Apply Coupon and enter a valid code before payment.'
        },
      ];

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(color: AppColors.text, fontWeight: FontWeight.w600);
    final bodyStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: AppColors.text.withOpacity(0.85));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & FAQ'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryLightest,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How can we help?', style: titleStyle),
                  const SizedBox(height: 8),
                  Text(
                    'Find quick answers or reach out to our support team for assistance.',
                    style: bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _HelpChip(
                        icon: Icons.receipt_long,
                        label: 'My bookings',
                        color: AppColors.primary,
                        onTap: () {},
                      ),
                      _HelpChip(
                        icon: Icons.payment,
                        label: 'Payment issues',
                        color: AppColors.secondary,
                        onTap: () {},
                      ),
                      _HelpChip(
                        icon: Icons.airline_seat_recline_normal,
                        label: 'Seat selection',
                        color: AppColors.primaryDark,
                        onTap: () {},
                      ),
                      _HelpChip(
                        icon: Icons.local_offer,
                        label: 'Coupons',
                        color: AppColors.accent,
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // _SectionTitle('Contact support'),
            // Row(
            //   children: [
            //     Expanded(
            //       child: _ContactCard(
            //         icon: Icons.email_outlined,
            //         title: 'Email',
            //         subtitle: 'sumarg@gmail.com',
            //         color: AppColors.primary,
            //         onTap: () {},
            //       ),
            //     ),
            //     const SizedBox(width: 12),
            //     Expanded(
            //       child: _ContactCard(
            //         icon: Icons.chat_bubble_outline,
            //         title: 'Chat',
            //         subtitle: 'In-app support',
            //         color: AppColors.secondary,
            //         onTap: () {},
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 16),
            _SectionTitle('Frequently asked questions'),
            const SizedBox(height: 8),
            ..._faqs.map(
              (f) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                    splashColor: AppColors.primaryLightest,
                    highlightColor: AppColors.primaryLightest,
                    hoverColor: AppColors.primaryLightest,
                  ),
                  child: ExpansionTile(
                    tilePadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    iconColor: AppColors.primary,
                    collapsedIconColor: AppColors.primary,
                    title: Text(
                      f['q']!,
                      style: titleStyle,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            f['a']!,
                            style: bodyStyle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: AppColors.background,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _HelpChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _HelpChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: AppColors.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.16)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.text.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }
}