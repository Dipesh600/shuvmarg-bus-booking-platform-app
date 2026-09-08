import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class RefundDestinationDialog extends StatefulWidget {
  final int refundAmount;
  final Future<bool> Function(String destination) onSubmit;

  const RefundDestinationDialog({
    super.key,
    required this.refundAmount,
    required this.onSubmit,
  });

  static Future<bool?> show(
    BuildContext context, {
    required int refundAmount,
    required Future<bool> Function(String destination) onSubmit,
  }) =>
      showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => RefundDestinationDialog(
          refundAmount: refundAmount,
          onSubmit: onSubmit,
        ),
      );

  @override
  State<RefundDestinationDialog> createState() =>
      _RefundDestinationDialogState();
}

class _RefundDestinationDialogState extends State<RefundDestinationDialog> {
  String _destination = 'wallet';
  bool _busy = false;
  String? _error;

  Future<void> _submit() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final success = await widget.onSubmit(_destination);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context, true);
      return;
    }
    setState(() {
      _busy = false;
      _error = 'Could not save the refund destination. Please try again.';
    });
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !_busy,
        child: AlertDialog(
          backgroundColor: AppTheme.primaryDarker,
          title: const Text('Choose refund destination',
              style: TextStyle(color: AppTheme.textPrimary)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
                'Your operator cancelled this trip. Choose where NPR ${widget.refundAmount} should go.',
                style: const TextStyle(color: AppTheme.textSecondary)),
            RadioListTile<String>(
              value: 'wallet',
              groupValue: _destination,
              onChanged: _busy
                  ? null
                  : (value) => setState(() => _destination = value!),
              title: const Text('Shuvmarg Money',
                  style: TextStyle(color: AppTheme.textPrimary)),
              subtitle: const Text('Instant credit',
                  style: TextStyle(color: AppTheme.textSecondary)),
            ),
            RadioListTile<String>(
              value: 'original',
              groupValue: _destination,
              onChanged: _busy
                  ? null
                  : (value) => setState(() => _destination = value!),
              title: const Text('Original payment method',
                  style: TextStyle(color: AppTheme.textPrimary)),
              subtitle: const Text('Processed after provider settlement',
                  style: TextStyle(color: AppTheme.textSecondary)),
            ),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: AppTheme.error)),
          ]),
          actions: [
            TextButton(
                onPressed: _busy ? null : () => Navigator.pop(context, false),
                child: const Text('Later')),
            FilledButton(
                onPressed: _busy ? null : _submit,
                child: Text(_busy ? 'Saving…' : 'Confirm destination')),
          ],
        ),
      );
}
