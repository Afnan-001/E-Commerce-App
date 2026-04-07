import 'package:flutter/foundation.dart';

import 'package:shop/models/order_item_model.dart';

enum PaymentMethod { cod, razorpay }
enum PaymentStatus { pending, paid, failed }
enum OrderStatus { placed, confirmed, packed, shipped, delivered, cancelled }

@immutable
class OrderModel {
  const OrderModel({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.phoneNumber,
    required this.address,
    required this.items,
    required this.subtotal,
    required this.deliveryCharge,
    required this.total,
    required this.paymentMethod,
    this.paymentStatus = PaymentStatus.pending,
    this.orderStatus = OrderStatus.placed,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String customerName;
  final String phoneNumber;
  final String address;
  final List<OrderItemModel> items;
  final double subtotal;
  final double deliveryCharge;
  final double total;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final OrderStatus orderStatus;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'customerName': customerName,
      'phoneNumber': phoneNumber,
      'address': address,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryCharge': deliveryCharge,
      'total': total,
      'paymentMethod': paymentMethod.name,
      'paymentStatus': paymentStatus.name,
      'orderStatus': orderStatus.name,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
