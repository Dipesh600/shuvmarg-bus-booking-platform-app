import 'dart:convert';

class EsewaCheckout {
  final String reference;
  final Uri paymentUrl;
  final Map<String, String> fields;
  EsewaCheckout._(this.reference, this.paymentUrl, this.fields);

  factory EsewaCheckout.fromJson(Map<String, dynamic> json) {
    final reference = json['transactionUuid'] as String;
    final url = Uri.parse(json['paymentUrl'] as String);
    final fields = Map<String, dynamic>.from(json['fields'] as Map)
        .map((key, value) => MapEntry(key, value.toString()));
    if (!RegExp(r'^[A-Za-z0-9_-]{1,128}$').hasMatch(reference) ||
        url.scheme != 'https' || url.userInfo.isNotEmpty ||
        !['epay.esewa.com.np', 'rc-epay.esewa.com.np'].contains(url.host) ||
        url.path != '/api/epay/main/v2/form' ||
        fields['transaction_uuid'] != reference ||
        (fields['signature'] ?? '').isEmpty) {
      throw const FormatException('Invalid server checkout');
    }
    for (final key in ['success_url', 'failure_url']) {
      final callback = Uri.parse(fields[key] ?? '');
      if (!callback.hasAuthority || !['http', 'https'].contains(callback.scheme) ||
          callback.pathSegments.lastOrNull != reference) {
        throw const FormatException('Invalid checkout return URL');
      }
    }
    return EsewaCheckout._(reference, url, fields);
  }

  bool isReturnUrl(Uri url) => url.hasAuthority &&
      ['http', 'https'].contains(url.scheme) &&
      url.userInfo.isEmpty && ['success_url', 'failure_url'].any((key) {
    final expected = Uri.parse(fields[key]!);
    return url.origin == expected.origin && url.path == expected.path;
  });

  String get formHtml {
    const escape = HtmlEscape();
    final inputs = fields.entries.map((field) => '<input type="hidden" '
        'name="${escape.convert(field.key)}" value="${escape.convert(field.value)}">').join();
    return '<!doctype html><html><body><p>Opening eSewa…</p>'
        '<form id="payment" method="post" action="${escape.convert(paymentUrl.toString())}">'
        '$inputs</form><script>document.getElementById("payment").submit();</script></body></html>';
  }
}
