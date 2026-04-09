import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:shop/core/config/payment_config.dart';

class RazorpayCheckoutService {
  RazorpayCheckoutService() : _razorpay = Razorpay();

  final Razorpay _razorpay;

  Future<String> createOrderId({
    required int amountInPaise,
    required String receiptId,
    Map<String, dynamic>? notes,
  }) async {
    if (razorpayOrderCreationUrl.isEmpty) {
      throw StateError(
        'Configure a secure backend endpoint for Razorpay order creation. '
        'The Razorpay secret key must never live in the Flutter client.',
      );
    }

    final configuredUri = Uri.parse(razorpayOrderCreationUrl);
    final requestUri = _normalizeOrderCreationUri(configuredUri);

    http.Response response = await http
        .post(
          requestUri,
          headers: const <String, String>{'Content-Type': 'application/json'},
          body: jsonEncode(<String, dynamic>{
            'amount': amountInPaise,
            'currency': razorpayCurrency,
            'receipt': receiptId,
            'notes': notes ?? <String, dynamic>{},
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Unable to create Razorpay order right now. '
        'Status: ${response.statusCode}.',
      );
    }

    final decodedBody = jsonDecode(response.body);
    if (decodedBody is! Map<String, dynamic>) {
      throw StateError('Backend returned an invalid Razorpay order response.');
    }

    final orderId =
        decodedBody['orderId'] as String? ?? decodedBody['id'] as String?;

    if (orderId == null || orderId.isEmpty) {
      throw StateError('Backend did not return a Razorpay order id.');
    }

    return orderId;
  }

  void openCheckout({
    required String orderId,
    required int amountInPaise,
    required String userName,
    required String userEmail,
    required String userPhone,
    required void Function(PaymentSuccessResponse response) onSuccess,
    required void Function(PaymentFailureResponse response) onFailure,
    void Function(dynamic response)? onExternalWallet,
  }) {
    _razorpay.clear();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onFailure);
    if (onExternalWallet != null) {
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
    }

    final options = <String, dynamic>{
      'key': razorpayKeyId,
      'amount': amountInPaise,
      'currency': razorpayCurrency,
      'order_id': orderId,
      'name': 'PawCare Store',
      'description': 'Checkout payment',
      'prefill': <String, dynamic>{
        'contact': userPhone,
        'email': userEmail,
        'name': userName,
      },
      'theme': <String, dynamic>{'color': '#7B61FF'},
    };

    _razorpay.open(options);
  }

  void dispose() {
    _razorpay.clear();
  }

  Uri _normalizeOrderCreationUri(Uri configuredUri) {
    final normalizedPath = configuredUri.path.trim();
    if (normalizedPath.isEmpty || normalizedPath == '/') {
      return configuredUri.replace(path: '/create-order');
    }
    return configuredUri;
  }
}
