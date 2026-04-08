import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:shop/models/order_item_model.dart';

enum OrderStatus { pending, completed }

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
    required this.totalPrice,
    this.paymentStatus = 'COD',
    this.orderStatus = OrderStatus.pending,
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
  final double totalPrice;
  final String paymentStatus;
  final OrderStatus orderStatus;
  final DateTime? createdAt;

  double get total => totalPrice;

  OrderModel copyWith({
    String? id,
    String? userId,
    String? customerName,
    String? phoneNumber,
    String? address,
    List<OrderItemModel>? items,
    double? subtotal,
    double? deliveryCharge,
    double? totalPrice,
    String? paymentStatus,
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
      totalPrice: totalPrice ?? this.totalPrice,
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
      totalPrice: (data['totalPrice'] as num?)?.toDouble() ??
          (data['total'] as num?)?.toDouble() ??
          0,
      paymentStatus: data['paymentStatus'] as String? ?? 'COD',
      orderStatus: _orderStatusFromString(
        data['orderStatus'] as String?,
      ),
      createdAt: _dateTimeFromValue(data['timestamp']) ??
          _dateTimeFromValue(data['createdAt']),
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
      'totalPrice': totalPrice,
      'paymentStatus': paymentStatus,
      'orderStatus': orderStatus.name,
      'timestamp': createdAt,
    };
  }

  static OrderStatus _orderStatusFromString(String? value) {
    return OrderStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => OrderStatus.pending,
    );
  }

  static DateTime? _dateTimeFromValue(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
