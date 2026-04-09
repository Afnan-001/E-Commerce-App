import 'package:flutter/foundation.dart';

@immutable
class OrderPricingModel {
  const OrderPricingModel({
    required this.subtotal,
    required this.deliveryCharge,
    required this.discount,
    required this.totalAmount,
  });

  final double subtotal;
  final double deliveryCharge;
  final double discount;
  final double totalAmount;

  factory OrderPricingModel.fromMap(Map<String, dynamic> data) {
    return OrderPricingModel(
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryCharge: (data['deliveryCharge'] as num?)?.toDouble() ?? 0,
      discount: (data['discount'] as num?)?.toDouble() ?? 0,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'subtotal': subtotal,
      'deliveryCharge': deliveryCharge,
      'discount': discount,
      'totalAmount': totalAmount,
    };
  }
}
