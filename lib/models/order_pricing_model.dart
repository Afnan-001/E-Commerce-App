import 'package:flutter/foundation.dart';

@immutable
class OrderPricingModel {
  const OrderPricingModel({
    required this.subtotal,
    required this.deliveryCharge,
    required this.discount,
    required this.totalAmount,
    this.productDiscount = 0,
    this.couponDiscount = 0,
    this.couponCode,
  });

  final double subtotal;
  final double deliveryCharge;
  final double discount;
  final double totalAmount;
  final double productDiscount;
  final double couponDiscount;
  final String? couponCode;

  factory OrderPricingModel.fromMap(Map<String, dynamic> data) {
    return OrderPricingModel(
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryCharge: (data['deliveryCharge'] as num?)?.toDouble() ?? 0,
      discount: (data['discount'] as num?)?.toDouble() ?? 0,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0,
      productDiscount: (data['productDiscount'] as num?)?.toDouble() ?? 0,
      couponDiscount: (data['couponDiscount'] as num?)?.toDouble() ?? 0,
      couponCode: data['couponCode'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'subtotal': subtotal,
      'deliveryCharge': deliveryCharge,
      'discount': discount,
      'totalAmount': totalAmount,
      'productDiscount': productDiscount,
      'couponDiscount': couponDiscount,
      'couponCode': couponCode,
    };
  }
}
