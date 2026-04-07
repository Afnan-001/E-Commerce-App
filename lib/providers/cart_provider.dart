import 'package:flutter/foundation.dart';

import 'package:shop/models/cart_item_model.dart';
import 'package:shop/models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = <CartItemModel>[];

  List<CartItemModel> get items => List<CartItemModel>.unmodifiable(_items);

  int get totalItems =>
      _items.fold<int>(0, (total, item) => total + item.quantity);

  double get subtotal =>
      _items.fold<double>(0, (total, item) => total + item.totalPrice);

  void addToCart(ProductModel product, {int quantity = 1}) {
    final existingIndex =
        _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex == -1) {
      _items.add(CartItemModel(product: product, quantity: quantity));
    } else {
      final existingItem = _items[existingIndex];
      _items[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    }

    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index == -1) return;

    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(quantity: quantity);
    }

    notifyListeners();
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
