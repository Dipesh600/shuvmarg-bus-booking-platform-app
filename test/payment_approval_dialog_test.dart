import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sumarg/apis/api_services.dart';
import 'package:sumarg/views/booking/checkout/payment_approval_dialog.dart';

class ApprovalApi extends ApiService {
  int calls = 0;
  Map<String, dynamic>? payload;
  bool fail = false;
  @override
  Future postDataWithToken(String endpoint, dynamic data, {BuildContext? context}) async {
    calls++;
    payload = Map<String, dynamic>.from(data);
    if (fail) throw StateError('Provider unavailable');
    return {'success': true};
  }
}
void main() {
  testWidgets('shows the server amount and submits OTP bound to the authorization', (tester) async {
    final api = ApprovalApi();
    String? result;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) => TextButton(
      onPressed: () async { result = await showDialog<String>(context: context,
        builder: (_) => PaymentApprovalDialog(api: api, challenge: {
          'authorizationId': 'purchase-123', 'smMoneyApplied': 40, 'totalAmount': 1000, 'phoneHint': '0000',
        })); }, child: const Text('Open')))));
    await tester.tap(find.text('Open')); await tester.pumpAndSettle();
    expect(find.textContaining('Rs 40'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '123');
    await tester.tap(find.text('Approve payment')); await tester.pump();
    expect(api.calls, 0);
    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.text('Approve payment')); await tester.pumpAndSettle();
    expect(result, 'purchase-123');
    expect(api.payload, {'authorizationId': 'purchase-123', 'otp': '123456'});
  });
  testWidgets('failed approval stays on the dialog without returning authorization', (tester) async {
    final api = ApprovalApi()..fail = true;
    await tester.pumpWidget(MaterialApp(home: PaymentApprovalDialog(api: api, challenge: {
      'authorizationId': 'purchase-123', 'smMoneyApplied': 40, 'totalAmount': 1000, 'phoneHint': '0000',
    })));
    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.text('Approve payment')); await tester.pumpAndSettle();
    expect(find.textContaining('could not be verified'), findsOneWidget);
    expect(find.byType(PaymentApprovalDialog), findsOneWidget);
  });
}
