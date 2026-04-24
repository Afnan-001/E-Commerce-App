import 'package:flutter/foundation.dart';

@immutable
class CartPricingSummaryModel {
  const CartPricingSummaryModel({
    required this.subtotal,
    required this.originalSubtotal,
    required this.productDiscount,
    required this.couponDiscount,
    required this.deliveryCharge,
    required this.total,
    required this.freeDeliveryThreshold,
  });

  final double subtotal;
  final double originalSubtotal;
  final double productDiscount;
  final double couponDiscount;
  final double deliveryCharge;
  final double total;
  final double freeDeliveryThreshold;

  double get totalDiscount => productDiscount + couponDiscount;
  bool get qualifiesForFreeDelivery =>
      subtotal >= freeDeliveryThreshold || deliveryCharge <= 0;
  double get amountLeftForFreeDelivery {
    if (qualifiesForFreeDelivery) return 0;
    final remaining = freeDeliveryThreshold - subtotal;
    return remaining < 0 ? 0 : remaining;
  }
}
