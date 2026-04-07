import 'package:flutter/foundation.dart';

import 'package:shop/models/product_model.dart';

@immutable
class CartItemModel {
  const CartItemModel({
    required this.product,
    this.quantity = 1,
  });

  final ProductModel product;
  final int quantity;

  double get unitPrice => product.salePrice ?? product.price;
  double get totalPrice => unitPrice * quantity;

  CartItemModel copyWith({
    ProductModel? product,
    int? quantity,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
