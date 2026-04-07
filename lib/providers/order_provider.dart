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
    _orders[index] = OrderModel(
      id: currentOrder.id,
      userId: currentOrder.userId,
      customerName: currentOrder.customerName,
      phoneNumber: currentOrder.phoneNumber,
      address: currentOrder.address,
      items: currentOrder.items,
      subtotal: currentOrder.subtotal,
      deliveryCharge: currentOrder.deliveryCharge,
      total: currentOrder.total,
      paymentMethod: currentOrder.paymentMethod,
      paymentStatus: currentOrder.paymentStatus,
      orderStatus: status,
      createdAt: currentOrder.createdAt,
    );

    notifyListeners();
  }
}
