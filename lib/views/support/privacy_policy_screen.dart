import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const String _policyHtml = '''
  <h1>Privacy Policy</h1>
  <p><strong>Last updated:</strong> November 21, 2025</p>
  <p>Welcome to Sumarg, a bus ticket search, booking, and trip management application. This Privacy Policy describes how we collect, use, and share information when you use our app and services.</p>

  <h2>Information We Collect</h2>
  <ul>
    <li><strong>Account:</strong> Name, phone number, email address, and authentication data (e.g., OTP).</li>
    <li><strong>Profile:</strong> Profile photo and preferences you choose to provide.</li>
    <li><strong>Bookings:</strong> Routes, dates, seat selections, passenger details, and payment references. We do not store full card details.</li>
    <li><strong>Device:</strong> Device model, OS, app version, language, and identifiers.</li>
    <li><strong>Usage:</strong> App interactions, screens viewed, and diagnostics to improve performance.</li>
    <li><strong>Location:</strong> If permitted, approximate location to improve search relevance.</li>
    <li><strong>Notifications:</strong> Your push notification preferences.</li>
  </ul>

  <h2>How We Use Information</h2>
  <ul>
    <li>Provide and improve booking and trip management services.</li>
    <li>Process transactions and send tickets, confirmations, and receipts.</li>
    <li>Improve reliability, safety, and performance of the app.</li>
    <li>Communicate updates, policy changes, and security alerts.</li>
    <li>Send offers or promotions where permitted; you can opt out anytime.</li>
    <li>Detect, prevent, and address fraud or misuse.</li>
  </ul>

  <h2>Legal Bases</h2>
  <p>We process data based on consent, contract performance (e.g., bookings), legal obligations, and our legitimate interests (e.g., security and service improvement).</p>

  <h2>Sharing of Information</h2>
  <ul>
    <li><strong>Service providers:</strong> Payment, analytics, notifications, and support vendors under confidentiality.</li>
    <li><strong>Bus operators/partners:</strong> Necessary booking details to fulfill your reservation.</li>
    <li><strong>Legal/safety:</strong> To comply with law or protect rights, property, or safety.</li>
    <li><strong>Business transfers:</strong> In case of merger or acquisition in accordance with this policy.</li>
  </ul>

  <h2>Retention</h2>
  <p>Data is kept as long as needed to provide the service, meet legal requirements, resolve disputes, and enforce agreements. Retention varies by data type and law.</p>

  <h2>Security</h2>
  <p>We use reasonable technical and organizational measures to protect information. No method is 100% secure.</p>

  <h2>Your Choices</h2>
  <ul>
    <li>Access or update account information in the app.</li>
    <li>Manage notification preferences in settings.</li>
    <li>Withdraw consent where applicable.</li>
    <li>Request a copy or deletion of your data subject to legal limits.</li>
  </ul>

  <h2>Children</h2>
  <p>Our services are not directed to children under 13 (or the equivalent age in your region). If you believe a child has provided personal data, contact us.</p>

  <h2>International Transfers</h2>
  <p>Your data may be processed in countries other than yours. We use appropriate safeguards consistent with applicable laws.</p>

  <h2>Third-Party Links and SDKs</h2>
  <p>We may link to third-party sites or integrate SDKs (e.g., payments, notifications). Their practices are governed by their own policies.</p>

  <h2>Changes</h2>
  <p>We may update this policy from time to time. Material changes will be communicated in the app.</p>

  <h2>Contact</h2>
  <p>Questions? Email us at <a href="mailto:sumarg@gmail.com">sumarg@gmail.com</a>.</p>
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: HtmlWidget(
              _policyHtml,
            ),
          ),
        ),
      ),
    );
  }
}