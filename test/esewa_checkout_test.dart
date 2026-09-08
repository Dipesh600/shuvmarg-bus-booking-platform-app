import 'package:flutter_test/flutter_test.dart';
import 'package:sumarg/models/esewa_checkout.dart';

Map<String, dynamic> checkoutJson() => {
  'transactionUuid': 'payment_123',
  'paymentUrl': 'https://epay.esewa.com.np/api/epay/main/v2/form',
  'fields': {
    'transaction_uuid': 'payment_123', 'signature': 'signed-value',
    'success_url': 'https://api.example.com/success/payment_123',
    'failure_url': 'https://api.example.com/failure/payment_123',
  },
};
void main() {
  test('return URLs must match the server origin and path', () {
    final checkout = EsewaCheckout.fromJson(checkoutJson());
    expect(checkout.isReturnUrl(Uri.parse('https://api.example.com/success/payment_123?data=abc')), isTrue);
    for (final url in ['intent://api.example.com/success/payment_123',
      'https://attacker.example/success/payment_123',
      'https://api.example.com/success/other',
      'https://user@api.example.com/success/payment_123', 'about:blank']) {
      expect(checkout.isReturnUrl(Uri.parse(url)), isFalse, reason: url);
    }
  });
  test('rejects altered payment destinations and reference mismatch', () {
    for (final url in ['http://epay.esewa.com.np/api/epay/main/v2/form',
      'https://epay.esewa.com.np.attacker.example/api/epay/main/v2/form',
      'https://user@epay.esewa.com.np/api/epay/main/v2/form']) {
      expect(() => EsewaCheckout.fromJson({...checkoutJson(), 'paymentUrl': url}), throwsFormatException);
    }
    final json = checkoutJson();
    (json['fields'] as Map)['transaction_uuid'] = 'other';
    expect(() => EsewaCheckout.fromJson(json), throwsFormatException);
  });
  test('form escapes field values instead of inserting executable markup', () {
    final json = checkoutJson();
    (json['fields'] as Map)['test'] = '\"><script>alert(1)</script>';
    final html = EsewaCheckout.fromJson(json).formHtml;
    expect(html, isNot(contains('<script>alert(1)</script>')));
    expect(html, contains('&lt;script&gt;'));
  });
}
