import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../apis/api_services.dart';
import '../../../utils/api_endpoints.dart';

class PaymentApprovalDialog extends StatefulWidget {
  final Map<String, dynamic> challenge;
  final ApiService? api;
  const PaymentApprovalDialog({super.key, required this.challenge, this.api});

  static Future<String?> request(BuildContext context, Map<String, dynamic> purchase) async {
    final response = await ApiService().postDataWithToken(
      '${ApiEndpoints.baseUrl}/api/ticket/payment-authorization/request', purchase);
    if (!context.mounted) return null;
    if (response['success'] != true || response['data'] is! Map) {
      throw StateError('Could not request payment approval.');
    }
    return showDialog<String>(context: context, barrierDismissible: false,
      builder: (_) => PaymentApprovalDialog(challenge: Map<String, dynamic>.from(response['data'])));
  }

  @override
  State<PaymentApprovalDialog> createState() => _PaymentApprovalDialogState();
}

class _PaymentApprovalDialogState extends State<PaymentApprovalDialog> {
  final _code = TextEditingController();
  bool _busy = false;
  String? _error;
  @override
  void dispose() { _code.dispose(); super.dispose(); }

  Future<void> _approve() async {
    if (_busy || !RegExp(r'^\d{6}$').hasMatch(_code.text.trim())) return;
    setState(() { _busy = true; _error = null; });
    try {
      final response = await (widget.api ?? ApiService()).postDataWithToken(
        '${ApiEndpoints.baseUrl}/api/ticket/payment-authorization/approve',
        {'authorizationId': widget.challenge['authorizationId'], 'otp': _code.text.trim()});
      if (!mounted) return;
      if (response['success'] != true) throw StateError('Payment approval failed.');
      Navigator.pop(context, widget.challenge['authorizationId'] as String);
    } catch (_) {
      if (mounted) setState(() => _error = 'The code could not be verified. Check the code or cancel and try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: AlertDialog(
      title: const Text('Approve SM Money payment'),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Use Rs ${widget.challenge['smMoneyApplied']} from SM Money for this booking. Total: Rs ${widget.challenge['totalAmount']}.'),
        const SizedBox(height: 12),
        Text('Enter the code sent to your registered phone ending ${widget.challenge['phoneHint']}.'),
        TextField(controller: _code, enabled: !_busy, keyboardType: TextInputType.number,
          autofillHints: const [AutofillHints.oneTimeCode], maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(labelText: 'Payment code', errorText: _error)),
      ]),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _busy ? null : _approve, child: Text(_busy ? 'Checking…' : 'Approve payment')),
      ],
    ),
  );
}
