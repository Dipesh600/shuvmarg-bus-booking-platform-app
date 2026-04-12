import 'package:flutter/material.dart';
import 'package:sumarg/utils/color_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  static const String _email = 'sumargsewa@gmail.com';
  static const String _phone = '+977 974-6592506';
  static const String _waTemplate = 'Dear sir/madam i need help for';

  String get _sanitizedPhoneForWhatsApp => _phone.replaceAll(RegExp(r'[^+0-9]'), '');

  Future<void> _launchEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _email,
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchPhone() async {
    final uri = Uri(
      scheme: 'tel',
      path: _phone.replaceAll(' ', ''),
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchWhatsApp() async {
    final text = Uri.encodeComponent(_waTemplate);
    final phone = _sanitizedPhoneForWhatsApp;
    final native = Uri.parse('whatsapp://send?phone=$phone&text=$text');
    final web = Uri.parse('https://wa.me/$phone?text=$text');
    if (await canLaunchUrl(native)) {
      await launchUrl(native, mode: LaunchMode.externalApplication);
      return;
    }
    await launchUrl(web, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final title = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(color: AppColors.text, fontWeight: FontWeight.w700);
    final body = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: AppColors.text.withOpacity(0.8));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('We are here to help', style: title),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a preferred contact option below. Our team will assist you as soon as possible.',
                    style: body,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _ActionCard(
              color: AppColors.primary,
              icon: Icons.email_outlined,
              title: 'Email us',
              subtitle: _email,
              buttonText: 'Send email',
              onPressed: _launchEmail,
            ),
            const SizedBox(height: 12),
            _ActionCard(
              color: AppColors.secondary,
              icon: Icons.phone_outlined,
              title: 'Call us',
              subtitle: _phone,
              buttonText: 'Call now',
              onPressed: _launchPhone,
            ),
            const SizedBox(height: 12),
            _ActionCard(
              color: Colors.green,
              icon: FontAwesomeIcons.whatsapp,
              title: 'WhatsApp',
              subtitle: 'Chat with support',
              buttonText: 'WhatsApp',
              onPressed: _launchWhatsApp,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonText;
  final Future<void> Function() onPressed;

  const _ActionCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(color: AppColors.text, fontWeight: FontWeight.w600);
    final subtitleStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: AppColors.text.withOpacity(0.75));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: titleStyle),
                const SizedBox(height: 4),
                Text(subtitle, style: subtitleStyle),
              ],
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: color,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onPressed: onPressed,
            child: Text(buttonText),
          )
        ],
      ),
    );
  }
}