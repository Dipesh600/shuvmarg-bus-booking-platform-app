import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../models/esewa_checkout.dart';

class EsewaCheckoutScreen extends StatefulWidget {
  final EsewaCheckout checkout;
  const EsewaCheckoutScreen({super.key, required this.checkout});
  @override
  State<EsewaCheckoutScreen> createState() => _EsewaCheckoutScreenState();
}

class _EsewaCheckoutScreenState extends State<EsewaCheckoutScreen> {
  late final WebViewController _controller;
  bool _returned = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) {
          final url = Uri.tryParse(request.url);
          if (url == null) return NavigationDecision.prevent;
          if (url.hasAuthority && widget.checkout.isReturnUrl(url)) {
            if (!_returned && mounted) {
              _returned = true;
              Navigator.pop(context, url.queryParameters['data']);
            }
            return NavigationDecision.prevent;
          }
          if (url.toString() == 'about:blank' || (url.scheme == 'https' &&
              (url.host == 'esewa.com.np' || url.host.endsWith('.esewa.com.np')))) {
            return NavigationDecision.navigate;
          }
          return NavigationDecision.prevent;
        },
        onWebResourceError: (error) {
          if (error.isForMainFrame == true && mounted) {
            setState(() {
            _error = 'The payment page could not load. Close it to check payment status safely.';
            });
          }
        },
      ))
      ..loadHtmlString(widget.checkout.formHtml);
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Pay with eSewa')),
    body: Column(children: [
      if (_error != null) Padding(padding: const EdgeInsets.all(16), child: Text(_error!)),
      Expanded(child: WebViewWidget(controller: _controller)),
    ]),
  );
}
