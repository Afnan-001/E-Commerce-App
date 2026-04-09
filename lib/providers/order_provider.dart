import 'package:flutter/foundation.dart';

import 'package:shop/models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  final List<OrderModel> _orders = <OrderModel>[];

  List<OrderModel> get orders => List<OrderModel>.unmodifiable(_orders);

  void addOrder(OrderModel order) {
    _orders.insert(0, order);
    notifyListeners();
  }

  void updateStatus(String orderId, OrderStatus status) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1) return;

    final currentOrder = _orders[index];
    _orders[index] = currentOrder.copyWith(orderStatus: status);

    notifyListeners();
  }
}
