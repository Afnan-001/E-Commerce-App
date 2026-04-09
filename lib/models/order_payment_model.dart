import 'package:flutter/foundation.dart';

import 'package:shop/models/order_enums.dart';

@immutable
class OrderPaymentModel {
  const OrderPaymentModel({
    required this.paymentMethod,
    required this.paymentStatus,
    this.razorpayPaymentId,
    this.razorpayOrderId,
    this.razorpaySignature,
  });

  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final String? razorpayPaymentId;
  final String? razorpayOrderId;
  final String? razorpaySignature;

  factory OrderPaymentModel.fromMap(Map<String, dynamic> data) {
    return OrderPaymentModel(
      paymentMethod: _paymentMethodFromString(
        data['paymentMethod'] as String? ?? data['method'] as String?,
      ),
      paymentStatus: _paymentStatusFromString(
        data['paymentStatus'] as String? ?? data['status'] as String?,
      ),
      razorpayPaymentId: data['razorpayPaymentId'] as String?,
      razorpayOrderId: data['razorpayOrderId'] as String?,
      razorpaySignature: data['razorpaySignature'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'paymentMethod': paymentMethod.name,
      'paymentStatus': paymentStatus.name,
      'razorpayPaymentId': razorpayPaymentId,
      'razorpayOrderId': razorpayOrderId,
      'razorpaySignature': razorpaySignature,
    };
  }

  static PaymentMethod _paymentMethodFromString(String? value) {
    return PaymentMethod.values.firstWhere(
      (method) => method.name == value,
      orElse: () => PaymentMethod.cod,
    );
  }

  static PaymentStatus _paymentStatusFromString(String? value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}
