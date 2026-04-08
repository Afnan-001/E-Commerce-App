import 'package:flutter/foundation.dart';

import 'package:shop/models/order_model.dart';
import 'package:shop/repositories/order_repository.dart';
import 'package:shop/core/services/pdf_invoice_service.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider({
    required OrderRepository orderRepository,
    PdfInvoiceService? pdfInvoiceService,
  })  : _orderRepository = orderRepository,
        _pdfInvoiceService = pdfInvoiceService ?? PdfInvoiceService();

  final OrderRepository _orderRepository;
  final PdfInvoiceService _pdfInvoiceService;

  List<OrderModel> _orders = <OrderModel>[];
  bool _isLoading = false;
  String? _errorMessage;
  String? _userId;

  List<OrderModel> get orders => List<OrderModel>.unmodifiable(_orders);
  List<OrderModel> get pendingOrders => _orders
      .where((order) => order.orderStatus == OrderStatus.pending)
      .toList();
  List<OrderModel> get completedOrders => _orders
      .where((order) => order.orderStatus == OrderStatus.completed)
      .toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> syncForUser(String? userId) async {
    if (_userId == userId) {
      return;
    }

    _userId = userId;
    _orders = <OrderModel>[];
    notifyListeners();

    if (userId == null || userId.isEmpty) {
      return;
    }

    await loadUserOrders(userId);
  }

  Future<void> loadUserOrders(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _orderRepository.getUserOrders(userId);
    } catch (error) {
      _errorMessage = error.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<OrderPlacementResult?> placeOrder(OrderModel order) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final savedOrder = await _orderRepository.placeOrder(order);
      final invoiceBytes = await _pdfInvoiceService.buildInvoice(savedOrder);
      _orders = <OrderModel>[savedOrder, ..._orders];
      return OrderPlacementResult(
        order: savedOrder,
        invoiceBytes: invoiceBytes,
      );
    } catch (error) {
      _errorMessage = error.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _orderRepository.updateOrderStatus(orderId, status);
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(orderStatus: status);
      }
    } catch (error) {
      _errorMessage = error.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}

class OrderPlacementResult {
  const OrderPlacementResult({
    required this.order,
    required this.invoiceBytes,
  });

  final OrderModel order;
  final Uint8List invoiceBytes;
}
