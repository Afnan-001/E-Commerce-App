import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:shop/models/order_model.dart';

abstract class OrderRepository {
  Future<void> saveOrder(OrderModel order);
  Future<OrderModel> placeOrder(OrderModel order);
  Future<List<OrderModel>> getUserOrders(String userId);
  Future<List<OrderModel>> getAllOrders();
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
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

    final payload = order
        .copyWith(
          orderId: docRef.id,
          updatedAt: DateTime.now(),
          createdAt: order.createdAt ?? DateTime.now(),
        )
        .toMap();

    payload['updatedAt'] = FieldValue.serverTimestamp();
    payload['timestamp'] = FieldValue.serverTimestamp();
    if (order.createdAt == null) {
      payload['createdAt'] = FieldValue.serverTimestamp();
    }

    await docRef.set(payload, SetOptions(merge: true));
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
    await _db.collection('orders').doc(orderId).update(<String, dynamic>{
      'orderStatus': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
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
}
