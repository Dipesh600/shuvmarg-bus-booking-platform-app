import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sumarg/apis/api_services.dart';
import 'package:sumarg/services/esewa_checkout_service.dart';
import 'esewa_checkout_test.dart' show checkoutJson;

class PaymentApi extends ApiService {
  dynamic result;
  Object? failure;
  int calls = 0;
  List<Map<String, dynamic>> pending = [];
  @override
  Future getDataWithToken(String endpoint, {BuildContext? context}) async => {'data': {'attempts': pending}};
  @override
  Future postDataWithToken(String endpoint, dynamic data, {BuildContext? context}) async {
    calls++;
    if (failure != null) throw failure!;
    return result;
  }
}
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PaymentApi api;
  late EsewaCheckoutService service;
  setUp(() {
    SharedPreferences.setMockInitialValues({'phone': '9800000000'});
    api = PaymentApi()..result = {'data': checkoutJson()};
    service = EsewaCheckoutService(api: api);
  });
  test('server discovery restores a reference lost before local persistence', () async {
    api.pending = [{'transactionUuid': 'server_payment_123'}];
    expect(await service.discoverPendingReference(), 'server_payment_123');
    await expectLater(service.initiate({}), throwsStateError);
    expect(api.calls, 0);
  });
  test('restart keeps only the reference and blocks a second initiation', () async {
    await service.initiate({'paymentAuthorizationId': 'purchase-123'});
    final restored = EsewaCheckoutService(api: api);
    expect(await restored.pendingReference(), 'payment_123');
    await expectLater(restored.initiate({}), throwsStateError);
    expect(api.calls, 1);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys().map(prefs.get).toList(), unorderedEquals(['9800000000', 'payment_123']));
  });
  test('pending and network failures preserve recovery; confirmed success clears it', () async {
    await service.initiate({});
    api.result = {'status': false, 'message': 'Still pending'};
    expect((await service.finalize('payment_123')).status, isFalse);
    expect(await service.pendingReference(), 'payment_123');
    api.failure = DioException(requestOptions: RequestOptions(), type: DioExceptionType.connectionError);
    await expectLater(service.finalize('payment_123'), throwsA(isA<DioException>()));
    expect(await service.pendingReference(), 'payment_123');
    api.failure = null;
    api.result = {'status': true, 'data': {'ticketId': 'ticket-1'}};
    await service.finalize('payment_123');
    expect(await service.pendingReference(), isNull);
  });
  test('account switch cannot expose another account reference', () async {
    await service.initiate({});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('phone', '9800000001');
    expect(await service.pendingReference(), isNull);
    await prefs.setString('phone', '9800000000');
    expect(await service.pendingReference(), 'payment_123');
  });
  test('terminal server error clears reference but unknown errors do not', () async {
    await service.initiate({});
    final request = RequestOptions();
    api.failure = DioException(requestOptions: request,
      response: Response(requestOptions: request, statusCode: 409,
        data: {'status': false, 'errorCode': 'PAYMENT_CLOSED'}));
    await service.finalize('payment_123');
    expect(await service.pendingReference(), isNull);
  });
}
