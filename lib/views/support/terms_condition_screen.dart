import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class TermsConditionScreen extends StatelessWidget {
  const TermsConditionScreen({super.key});

  static const String _termsHtml = '''
  <h1>Terms and Conditions</h1>
  <p><strong>Last updated:</strong> November 21, 2025</p>
  <p>These Terms and Conditions ("Terms") govern your use of the Sumarg mobile application and services for bus ticket search, booking, and trip management. By using the app, you agree to these Terms.</p>

  <h2>1. Account and Eligibility</h2>
  <ul>
    <li>You must be at least the age of majority in your jurisdiction to create an account or use the services independently.</li>
    <li>Provide accurate, complete, and up-to-date information. You are responsible for all activities under your account.</li>
  </ul>

  <h2>2. Booking and Payments</h2>
  <ul>
    <li>Prices, seat availability, and schedules are provided by bus operators and may change without notice.</li>
    <li>By confirming a booking, you authorize us and our payment partners to process the transaction. We do not store full card details.</li>
    <li>Tickets, fees, and applicable taxes are displayed at checkout. Some charges may be non-refundable per operator policy.</li>
  </ul>

  <h2>3. Cancellations, Refunds, and Changes</h2>
  <ul>
    <li>Cancellation and refund eligibility are subject to the bus operator’s policy. We facilitate requests where possible.</li>
    <li>Change requests (e.g., date or seat) are not guaranteed and may incur additional fees.</li>
  </ul>

  <h2>4. User Conduct</h2>
  <ul>
    <li>Do not misuse the app, attempt unauthorized access, or engage in fraudulent activity.</li>
    <li>Respect operators’ terms, codes of conduct, and any onboard rules.</li>
  </ul>

  <h2>5. App Content and License</h2>
  <ul>
    <li>We grant you a limited, non-exclusive, non-transferable license to use the app for personal, non-commercial purposes.</li>
    <li>All content and materials in the app are protected by intellectual property laws.</li>
  </ul>

  <h2>6. Third-Party Services</h2>
  <p>The app may integrate third-party services (e.g., payment gateways, analytics, notifications). Their terms and privacy practices apply to their services.</p>

  <h2>7. Disclaimers</h2>
  <ul>
    <li>The app and services are provided on an "as is" and "as available" basis.</li>
    <li>We do not warrant uninterrupted or error-free service, nor the accuracy of schedules or availability provided by operators.</li>
  </ul>

  <h2>8. Limitation of Liability</h2>
  <p>To the maximum extent permitted by law, Sumarg is not liable for indirect, incidental, special, consequential, or punitive damages, or for delays, cancellations, or acts of third parties including bus operators.</p>

  <h2>9. Indemnification</h2>
  <p>You agree to indemnify and hold harmless Sumarg from any claims arising out of your misuse of the app or violation of these Terms.</p>

  <h2>10. Changes to the Terms</h2>
  <p>We may update these Terms from time to time. We will notify you of material changes by updating the date above and, where appropriate, providing notice in the app. Continued use constitutes acceptance of the updated Terms.</p>

  <h2>11. Termination</h2>
  <p>We may suspend or terminate access if you violate these Terms or engage in activities that harm the app, other users, or partners.</p>

  <h2>12. Governing Law</h2>
  <p>These Terms are governed by applicable local laws, without regard to conflict of law principles. Venue and jurisdiction will be as permitted by law.</p>

  <h2>13. Contact Us</h2>
  <p>Questions about these Terms? Contact us at <a href="mailto:sumarg@gmail.com">sumarg@gmail.com</a>.</p>
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: HtmlWidget(
              _termsHtml,
            ),
          ),
        ),
      ),
    );
  }
}