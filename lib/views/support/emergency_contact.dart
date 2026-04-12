import 'package:flutter/material.dart';
import 'package:sumarg/utils/color_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContact extends StatelessWidget {
  const EmergencyContact({super.key});

  static const _contacts = [
    {
      'title': 'Police',
      'number': '100',
      'icon': Icons.local_police,
      'color': AppColors.primary,
    },
    {
      'title': 'Ambulance (NAS)',
      'number': '102',
      'icon': Icons.local_hospital,
      'color': AppColors.secondary,
    },
    {
      'title': 'Fire Brigade',
      'number': '101',
      'icon': Icons.local_fire_department,
      'color': Colors.red,
    },
    {
      'title': 'Traffic Police',
      'number': '103',
      'icon': Icons.traffic,
      'color': AppColors.primaryDark,
    },
    {
      'title': 'Tourist Police',
      'number': '1144',
      'icon': Icons.hiking,
      'color': AppColors.primaryLight,
    },
    {
      'title': 'Women Helpline',
      'number': '1145',
      'icon': Icons.support_agent,
      'color': AppColors.accent,
    },
  ];

  Future<void> _dial(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final title = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(color: AppColors.text, fontWeight: FontWeight.w700);
    final subtitle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: AppColors.text.withOpacity(0.75));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLightest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Tap any number to call. Available nationwide in Nepal.',
                style: subtitle,
              ),
            ),
            const SizedBox(height: 16),
            ..._contacts.map((c) {
              final Color color = c['color'] as Color;
              final IconData icon = c['icon'] as IconData;
              final String name = c['title'] as String;
              final String number = c['number'] as String;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: color.withOpacity(0.12),
                    child: Icon(icon, color: color),
                  ),
                  title: Text(name, style: title),
                  subtitle: Text('Dial $number', style: subtitle),
                  trailing: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    onPressed: () => _dial(number),
                    child: const Text('Call'),
                  ),
                  onTap: () => _dial(number),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}