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

  OrderModel copyWith({
    String? id,
    String? userId,
    String? customerName,
    String? phoneNumber,
    String? address,
    List<OrderItemModel>? items,
    double? subtotal,
    double? deliveryCharge,
    double? total,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    OrderStatus? orderStatus,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderStatus: orderStatus ?? this.orderStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory OrderModel.fromMap(String id, Map<String, dynamic> data) {
    final items = (data['items'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(OrderItemModel.fromMap)
        .toList();

    return OrderModel(
      id: id,
      userId: data['userId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      address: data['address'] as String? ?? '',
      items: items,
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryCharge: (data['deliveryCharge'] as num?)?.toDouble() ?? 0,
      total: (data['total'] as num?)?.toDouble() ?? 0,
      paymentMethod: _paymentMethodFromString(
        data['paymentMethod'] as String?,
      ),
      paymentStatus: _paymentStatusFromString(
        data['paymentStatus'] as String?,
      ),
      orderStatus: _orderStatusFromString(
        data['orderStatus'] as String?,
      ),
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? ''),
    );
  }

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

  static OrderStatus _orderStatusFromString(String? value) {
    return OrderStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => OrderStatus.placed,
    );
  }
}
