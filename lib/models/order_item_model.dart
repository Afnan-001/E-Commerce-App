import 'package:flutter/foundation.dart';

import 'package:shop/models/cart_item_model.dart';

@immutable
class OrderItemModel {
  const OrderItemModel({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.productPrice,
    required this.quantity,
  });

  final String productId;
  final String productName;
  final String imageUrl;
  final double productPrice;
  final int quantity;

  String get name => productName;
  double get unitPrice => productPrice;

  double get lineTotal => productPrice * quantity;

  factory OrderItemModel.fromCartItem(CartItemModel item) {
    return OrderItemModel(
      productId: item.product.id,
      productName: item.product.name,
      imageUrl: item.product.imageUrl,
      productPrice: item.unitPrice,
      quantity: item.quantity,
    );
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> data) {
    return OrderItemModel(
      productId: data['productId'] as String? ?? '',
      productName:
          data['productName'] as String? ?? data['name'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      productPrice:
          (data['productPrice'] as num?)?.toDouble() ??
          (data['unitPrice'] as num?)?.toDouble() ??
          0,
      quantity: data['quantity'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'productId': productId,
      'productName': productName,
      'imageUrl': imageUrl,
      'productPrice': productPrice,
      'quantity': quantity,
      'name': productName,
      'unitPrice': productPrice,
    };
  }
}
