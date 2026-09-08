import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sumarg/views/tickets/refund_destination_dialog.dart';

void main() {
  testWidgets('operator refund destination keeps the selected original source',
      (tester) async {
    String? submitted;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Builder(
      builder: (context) => TextButton(
        onPressed: () => RefundDestinationDialog.show(
          context,
          refundAmount: 750,
          onSubmit: (value) async {
            submitted = value;
            return true;
          },
        ),
        child: const Text('Open'),
      ),
    ))));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.textContaining('NPR 750'), findsOneWidget);
    await tester.tap(find.text('Original payment method'));
    await tester.pump();
    await tester.tap(find.text('Confirm destination'));
    await tester.pumpAndSettle();
    expect(submitted, 'original');
  });

  testWidgets('failed destination save stays open', (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Builder(
      builder: (context) => TextButton(
        onPressed: () => RefundDestinationDialog.show(
          context,
          refundAmount: 100,
          onSubmit: (_) async => false,
        ),
        child: const Text('Open'),
      ),
    ))));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm destination'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Could not save'), findsOneWidget);
    expect(find.text('Choose refund destination'), findsOneWidget);
  });
}
