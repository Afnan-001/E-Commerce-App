import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:shop/models/cart_item_model.dart';
import 'package:shop/models/product_model.dart';

abstract class UserDataRepository {
  Future<List<CartItemModel>> getCartItems(String userId);
  Future<void> upsertCartItem({
    required String userId,
    required CartItemModel item,
  });
  Future<void> removeCartItem({
    required String userId,
    required String cartItemId,
  });
  Future<void> clearCart(String userId);

  Future<Set<String>> getSavedProductIds(String userId);
  Future<void> saveProduct({
    required String userId,
    required ProductModel product,
  });
  Future<void> removeSavedProduct({
    required String userId,
    required String productId,
  });
}

class FirestoreUserDataRepository implements UserDataRepository {
  FirestoreUserDataRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  bool get _isReady => Firebase.apps.isNotEmpty;

  CollectionReference<Map<String, dynamic>> _cartCollection(String userId) =>
      _db.collection('users').doc(userId).collection('cartItems');

  CollectionReference<Map<String, dynamic>> _savedCollection(String userId) =>
      _db.collection('users').doc(userId).collection('savedItems');

  @override
  Future<void> clearCart(String userId) async {
    if (!_isReady || userId.trim().isEmpty) {
      return;
    }

    final snapshot = await _cartCollection(userId).get();
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  Future<List<CartItemModel>> getCartItems(String userId) async {
    if (!_isReady || userId.trim().isEmpty) {
      return const <CartItemModel>[];
    }

    final snapshot = await _cartCollection(userId).get();
    return snapshot.docs
        .map((doc) => CartItemModel.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<Set<String>> getSavedProductIds(String userId) async {
    if (!_isReady || userId.trim().isEmpty) {
      return <String>{};
    }

    final snapshot = await _savedCollection(userId).get();
    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  @override
  Future<void> removeCartItem({
    required String userId,
    required String cartItemId,
  }) async {
    if (!_isReady || userId.trim().isEmpty || cartItemId.trim().isEmpty) {
      return;
    }

    await _cartCollection(userId).doc(cartItemId).delete();
  }

  @override
  Future<void> removeSavedProduct({
    required String userId,
    required String productId,
  }) async {
    if (!_isReady || userId.trim().isEmpty || productId.trim().isEmpty) {
      return;
    }

    await _savedCollection(userId).doc(productId).delete();
  }

  @override
  Future<void> saveProduct({
    required String userId,
    required ProductModel product,
  }) async {
    if (!_isReady || userId.trim().isEmpty || product.id.trim().isEmpty) {
      return;
    }

    await _savedCollection(userId).doc(product.id).set(<String, dynamic>{
      'productId': product.id,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> upsertCartItem({
    required String userId,
    required CartItemModel item,
  }) async {
    if (!_isReady || userId.trim().isEmpty || item.product.id.trim().isEmpty) {
      return;
    }

    final payload = item.toMap();
    payload['updatedAt'] = FieldValue.serverTimestamp();
    await _cartCollection(userId).doc(item.id).set(payload);
  }
}
