import 'package:flutter/foundation.dart';

import 'package:shop/models/cart_item_model.dart';

@immutable
class OrderItemModel {
  const OrderItemModel({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
  });

  final String productId;
  final String name;
  final String imageUrl;
  final double unitPrice;
  final int quantity;

  double get lineTotal => unitPrice * quantity;

  factory OrderItemModel.fromCartItem(CartItemModel item) {
    return OrderItemModel(
      productId: item.product.id,
      name: item.product.name,
      imageUrl: item.product.imageUrl,
      unitPrice: item.unitPrice,
      quantity: item.quantity,
    );
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> data) {
    return OrderItemModel(
      productId: data['productId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      unitPrice: (data['unitPrice'] as num?)?.toDouble() ?? 0,
      quantity: data['quantity'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'productId': productId,
      'name': name,
      'imageUrl': imageUrl,
      'unitPrice': unitPrice,
      'quantity': quantity,
    };
  }
}
