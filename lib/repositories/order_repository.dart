import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:shop/models/order_model.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/models/product_option_model.dart';

abstract class OrderRepository {
  Future<void> saveOrder(OrderModel order);
  Future<OrderModel> placeOrder(OrderModel order);
  Future<List<OrderModel>> getUserOrders(String userId);
  Future<List<OrderModel>> getAllOrders();
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
  Future<void> cancelOrder({
    required String orderId,
    required String userId,
  });
}

class FirestoreOrderRepository implements OrderRepository {
  FirestoreOrderRepository({FirebaseFirestore? firestore})
    : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  bool get _isReady => Firebase.apps.isNotEmpty;

  @override
  Future<void> saveOrder(OrderModel order) async {
    _ensureReady();

    final docRef = order.orderId.trim().isEmpty
        ? _db.collection('orders').doc()
        : _db.collection('orders').doc(order.orderId);
    final now = DateTime.now();
    final normalizedOrder = order.copyWith(
      orderId: docRef.id,
      updatedAt: now,
      createdAt: order.createdAt ?? now,
    );
    final payload = normalizedOrder.toMap();

    payload['updatedAt'] = FieldValue.serverTimestamp();
    payload['timestamp'] = FieldValue.serverTimestamp();
    if (order.createdAt == null) {
      payload['createdAt'] = FieldValue.serverTimestamp();
    }

    await _db.runTransaction((transaction) async {
      for (final item in normalizedOrder.items) {
        final productId = item.productId.trim();
        if (productId.isEmpty) {
          throw StateError('One of the order items is missing a product id.');
        }

        final productRef = _db.collection('products').doc(productId);
        final productSnapshot = await transaction.get(productRef);
        if (!productSnapshot.exists) {
          throw StateError('Product not found for item: ${item.productName}.');
        }

        final product = ProductModel.fromMap(
          productSnapshot.id,
          productSnapshot.data() ?? <String, dynamic>{},
        );
        if (product.packOptions.isNotEmpty) {
          final optionIndex = product.packOptions.indexWhere(
            (option) => option.id == item.selectedOptionId,
          );
          if (optionIndex == -1) {
            throw StateError(
              'Selected pack is no longer available for ${item.productName}.',
            );
          }

          final option = product.packOptions[optionIndex];
          if (option.stockQuantity < item.quantity) {
            throw StateError(
              'Only ${option.stockQuantity} pack(s) left for ${item.name}.',
            );
          }

          final updatedOptions = product.packOptions.toList();
          updatedOptions[optionIndex] = option.copyWith(
            stockQuantity: option.stockQuantity - item.quantity,
          );
          final updatedProduct = product.copyWith(
            packOptions: updatedOptions,
            stockQuantity: _updatedProductPrimaryStock(updatedOptions),
          );

          transaction.update(productRef, <String, dynamic>{
            'packOptions': updatedOptions.map((option) => option.toMap()).toList(),
            'stockQuantity': updatedProduct.stockQuantity,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          continue;
        }

        final currentStock = product.stockQuantity;
        if (currentStock < item.quantity) {
          throw StateError(
            'Only $currentStock item(s) left in stock for ${item.productName}.',
          );
        }

        transaction.update(productRef, <String, dynamic>{
          'stockQuantity': currentStock - item.quantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      transaction.set(docRef, payload, SetOptions(merge: true));
    });
  }

  @override
  Future<OrderModel> placeOrder(OrderModel order) async {
    _ensureReady();
    final docRef = _db.collection('orders').doc();
    final now = DateTime.now();
    final payload = order
        .copyWith(
          orderId: docRef.id,
          createdAt: order.createdAt ?? now,
          updatedAt: now,
        )
        .toMap();

    payload['timestamp'] = FieldValue.serverTimestamp();
    payload['createdAt'] = FieldValue.serverTimestamp();
    payload['updatedAt'] = FieldValue.serverTimestamp();

    await docRef.set(payload, SetOptions(merge: true));

    final savedDoc = await docRef.get();
    final data = savedDoc.data();
    if (data == null) {
      throw StateError('Order was created but could not be loaded again.');
    }
    return OrderModel.fromMap(savedDoc.id, data);
  }

  @override
  Future<List<OrderModel>> getUserOrders(String userId) async {
    if (!_isReady || userId.trim().isEmpty) {
      return const <OrderModel>[];
    }

    final snapshot = await _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .get();

    final orders = snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
        .toList()
      ..sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

    return orders;
  }

  @override
  Future<List<OrderModel>> getAllOrders() async {
    if (!_isReady) {
      return const <OrderModel>[];
    }

    final snapshot = await _db.collection('orders').get();

    final orders = snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
        .toList()
      ..sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

    return orders;
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    _ensureReady();
    await _db.runTransaction((transaction) async {
      final docRef = _db.collection('orders').doc(orderId);
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw StateError('Order not found.');
      }

      final current = OrderModel.fromMap(snapshot.id, snapshot.data()!);
      if (current.isCompleted) {
        throw StateError('Delivered or cancelled orders cannot be changed.');
      }

      transaction.update(docRef, <String, dynamic>{
        'orderStatus': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> cancelOrder({
    required String orderId,
    required String userId,
  }) async {
    _ensureReady();

    await _db.runTransaction((transaction) async {
      final docRef = _db.collection('orders').doc(orderId);
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw StateError('Order not found.');
      }

      final order = OrderModel.fromMap(snapshot.id, snapshot.data()!);
      if (order.userId != userId) {
        throw StateError('You can only cancel your own orders.');
      }
      if (!order.canUserCancel) {
        throw StateError('This order can no longer be cancelled.');
      }

      transaction.update(docRef, <String, dynamic>{
        'orderStatus': OrderStatus.cancelled.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  void _ensureReady() {
    if (!_isReady) {
      throw StateError(
        'Firebase is not configured yet. Run flutterfire configure and add '
        'the platform config files before using orders.',
      );
    }
  }

  int _updatedProductPrimaryStock(List<ProductOptionModel> updatedOptions) {
    if (updatedOptions.isEmpty) return 0;
    for (final option in updatedOptions) {
      if (option.isDefault) {
        return option.stockQuantity;
      }
    }
    return updatedOptions.first.stockQuantity;
  }
}
