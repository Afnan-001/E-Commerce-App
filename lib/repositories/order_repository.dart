import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:shop/models/order_model.dart';

abstract class OrderRepository {
  Future<void> saveOrder(OrderModel order);
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

    final payload = order.copyWith(updatedAt: DateTime.now());
    await _db.collection('orders').doc(payload.orderId).set(payload.toMap());
  }

  void _ensureReady() {
    if (!_isReady) {
      throw StateError(
        'Firebase is not configured yet. Run flutterfire configure and add '
        'the platform config files before saving orders.',
      );
    }
  }
}
