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
    if (!isRazorpayConfigured) {
      throw StateError(
        'Razorpay is not configured. Provide RAZORPAY_KEY_ID and '
        'RAZORPAY_ORDER_CREATION_URL as dart-defines, and keep the secret key '
        'only on your backend.',
      );
    }

    final response = await http.post(
      Uri.parse(razorpayOrderCreationUrl),
      headers: const <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'amount': amountInPaise,
        'currency': razorpayCurrency,
        'receipt': receiptId,
        'notes': notes ?? <String, dynamic>{},
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Unable to create Razorpay order right now.');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final orderId = payload['orderId'] as String? ?? payload['id'] as String?;

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
    required void Function(ExternalWalletResponse response) onExternalWallet,
  }) {
    if (razorpayKeyId.trim().isEmpty) {
      throw StateError(
        'Missing Razorpay key id. Add RAZORPAY_KEY_ID before opening checkout.',
      );
    }

    _razorpay.clear();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onFailure);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);

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
      'external': <String, dynamic>{
        'wallets': <String>['paytm', 'gpay', 'phonepe'],
      },
      'theme': <String, dynamic>{'color': '#7B61FF'},
    };

    _razorpay.open(options);
  }

  void dispose() {
    _razorpay.clear();
  }
}
