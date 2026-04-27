import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:shop/core/config/payment_config.dart';
import 'package:shop/models/address_model.dart';
import 'package:shop/models/cart_item_model.dart';
import 'package:shop/models/order_model.dart';

class CheckoutApiService {
  CheckoutApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<RazorpayOrderSession> createRazorpayOrder({
    required String receiptId,
    required int amountInPaise,
    required String customerName,
    required String customerEmail,
    required String userId,
    required List<CartItemModel> items,
    required AddressModel address,
  }) async {
    final uri = _requireUri(
      razorpayOrderCreationUrl,
      missingMessage:
          'Set RAZORPAY_BACKEND_BASE_URL before starting Razorpay checkout.',
    );
    final payload = <String, dynamic>{
      'amount': amountInPaise,
      'currency': razorpayCurrency,
      'receipt': receiptId,
      'notes': _buildBackendNotes(
        receiptId: receiptId,
        userId: userId,
        customerName: customerName,
        customerEmail: customerEmail,
        paymentMethod: PaymentMethod.razorpay.name,
        amountInPaise: amountInPaise,
        items: items,
        address: address,
      ),
    };

    final data = await _postJson(uri, payload);
    final order = data['order'];
    final orderMap = order is Map<String, dynamic> ? order : null;
    final orderId =
        data['orderId'] as String? ??
        data['id'] as String? ??
        orderMap?['id'] as String?;
    final keyId =
        data['keyId'] as String? ??
        data['razorpayKeyId'] as String? ??
        orderMap?['keyId'] as String?;

    if (orderId == null || orderId.trim().isEmpty) {
      throw const CheckoutApiException(
        message: 'Backend did not return a Razorpay order id.',
      );
    }

    return RazorpayOrderSession(
      orderId: orderId,
      amountInPaise: (orderMap?['amount'] as num?)?.toInt() ?? amountInPaise,
      currency: orderMap?['currency'] as String? ?? razorpayCurrency,
      keyId: keyId,
      rawResponse: data,
    );
  }

  Future<CheckoutOrderConfirmation> verifyRazorpayPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String receiptId,
    required int amountInPaise,
    required String userId,
    required String customerName,
    required String customerEmail,
    required List<CartItemModel> items,
    required AddressModel address,
  }) async {
    final uri = _requireUri(
      razorpayPaymentVerificationUrl,
      missingMessage:
          'Set RAZORPAY_BACKEND_BASE_URL before verifying Razorpay payments.',
    );
    final payload = <String, dynamic>{
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_signature': razorpaySignature,
      'customerEmail': customerEmail,
      'customerName': customerName,
      'amount': amountInPaise,
      'currency': razorpayCurrency,
      'receipt': receiptId,
      'items': _buildBackendItems(items),
      'notes': _buildBackendNotes(
        receiptId: receiptId,
        userId: userId,
        customerName: customerName,
        customerEmail: customerEmail,
        paymentMethod: PaymentMethod.razorpay.name,
        amountInPaise: amountInPaise,
        items: items,
        address: address,
      ),
    };

    final data = await _postJson(uri, payload);
    return CheckoutOrderConfirmation.fromBackendResponse(data);
  }

  Future<CheckoutOrderConfirmation> createCashOnDeliveryOrder({
    required String receiptId,
    required int amountInPaise,
    required String customerName,
    required String customerEmail,
    required String userId,
    required List<CartItemModel> items,
    required AddressModel address,
  }) async {
    final uri = _requireUri(
      codOrderCreationUrl,
      missingMessage:
          'Set RAZORPAY_BACKEND_BASE_URL before placing COD orders.',
    );
    final payload = <String, dynamic>{
      'email': customerEmail,
      'customerName': customerName,
      'amount': amountInPaise,
      'currency': razorpayCurrency,
      'receipt': receiptId,
      'paymentMethod': PaymentMethod.cod.name,
      'paymentStatus': PaymentStatus.pending.name,
      'items': _buildBackendItems(items),
      'notes': _buildBackendNotes(
        receiptId: receiptId,
        userId: userId,
        customerName: customerName,
        customerEmail: customerEmail,
        paymentMethod: PaymentMethod.cod.name,
        amountInPaise: amountInPaise,
        items: items,
        address: address,
      ),
    };

    final data = await _postJson(uri, payload, expectedStatusCodes: {200, 201});
    return CheckoutOrderConfirmation.fromBackendResponse(data);
  }

  Uri _requireUri(String rawUrl, {required String missingMessage}) {
    if (rawUrl.trim().isEmpty) {
      throw CheckoutApiException(message: missingMessage);
    }
    return Uri.parse(rawUrl);
  }

  Future<Map<String, dynamic>> _postJson(
    Uri uri,
    Map<String, dynamic> payload, {
    Set<int> expectedStatusCodes = const {200},
  }) async {
    try {
      final response = await _client
          .post(
            uri,
            headers: const <String, String>{'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));

      final decoded = _decodeJsonObject(response.body);
      if (!expectedStatusCodes.contains(response.statusCode)) {
        throw CheckoutApiException(
          message:
              _extractMessage(decoded) ??
              'Backend request failed with status ${response.statusCode}.',
          statusCode: response.statusCode,
          responseBody: response.body,
          url: uri.toString(),
        );
      }

      final success = decoded['success'];
      if (success is bool && !success) {
        throw CheckoutApiException(
          message: _extractMessage(decoded) ?? 'Backend request failed.',
          statusCode: response.statusCode,
          responseBody: response.body,
          url: uri.toString(),
        );
      }

      return decoded;
    } on SocketException {
      throw CheckoutApiException(
        message: 'Unable to reach the backend service. Check your connection.',
        url: uri.toString(),
      );
    } on TimeoutException {
      throw CheckoutApiException(
        message: 'The backend took too long to respond. Please try again.',
        url: uri.toString(),
      );
    } on FormatException {
      throw CheckoutApiException(
        message: 'Backend returned an invalid JSON response.',
        url: uri.toString(),
      );
    }
  }

  Map<String, dynamic> _decodeJsonObject(String body) {
    if (body.trim().isEmpty) {
      throw const FormatException('Empty response body');
    }

    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('JSON response is not an object');
    }
    return decoded;
  }

  String? _extractMessage(Map<String, dynamic> data) {
    return data['error'] as String? ?? data['message'] as String?;
  }

  List<Map<String, dynamic>> _buildBackendItems(List<CartItemModel> items) {
    return items
        .map(
          (item) => <String, dynamic>{
            'name': item.product.name,
            'quantity': item.quantity,
            'price': (item.unitPrice * 100).round(),
            'productId': item.product.id,
          },
        )
        .toList();
  }

  Map<String, dynamic> _buildBackendNotes({
    required String receiptId,
    required String userId,
    required String customerName,
    required String customerEmail,
    required String paymentMethod,
    required int amountInPaise,
    required List<CartItemModel> items,
    required AddressModel address,
  }) {
    return <String, dynamic>{
      'receipt': receiptId,
      'user_id': userId,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'payment_method': paymentMethod,
      'amount': amountInPaise,
      'items': _buildBackendItems(items),
      'shipping_address': <String, dynamic>{
        'full_name': address.fullName,
        'phone': address.phoneNumber,
        'label': address.label,
        'address_line_1': address.addressLine1,
        'address_line_2': address.addressLine2,
        'city': address.city,
        'state': address.state,
        'pincode': address.pincode,
        'landmark': address.landmark,
      },
    };
  }
}

class RazorpayOrderSession {
  const RazorpayOrderSession({
    required this.orderId,
    required this.amountInPaise,
    required this.currency,
    this.keyId,
    required this.rawResponse,
  });

  final String orderId;
  final int amountInPaise;
  final String currency;
  final String? keyId;
  final Map<String, dynamic> rawResponse;
}

class CheckoutOrderConfirmation {
  const CheckoutOrderConfirmation({
    required this.message,
    this.backendOrderId,
    this.paymentId,
    this.order,
  });

  final String message;
  final String? backendOrderId;
  final String? paymentId;
  final Map<String, dynamic>? order;

  factory CheckoutOrderConfirmation.fromBackendResponse(
    Map<String, dynamic> data,
  ) {
    final rawOrder = data['order'];
    final order = rawOrder is Map<String, dynamic> ? rawOrder : null;
    return CheckoutOrderConfirmation(
      message: data['message'] as String? ?? 'Order confirmed successfully.',
      backendOrderId:
          data['orderId'] as String? ??
          order?['orderId'] as String? ??
          order?['razorpayOrderId'] as String?,
      paymentId: data['paymentId'] as String?,
      order: order,
    );
  }
}

class CheckoutApiException implements Exception {
  const CheckoutApiException({
    required this.message,
    this.statusCode,
    this.responseBody,
    this.url,
  });

  final String message;
  final int? statusCode;
  final String? responseBody;
  final String? url;

  String toDisplayMessage() {
    final buffer = StringBuffer(message);
    if (statusCode != null) {
      buffer.write('\nStatus: $statusCode');
    }
    return buffer.toString();
  }

  @override
  String toString() => toDisplayMessage();
}
