import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop/core/services/cloudinary_service.dart';
import 'package:shop/firebase_options.dart';
import 'package:shop/models/order_model.dart';
import 'package:shop/models/product_model.dart';

abstract class AdminRepository {
  Future<List<ProductModel>> getProducts();
  Future<List<OrderModel>> getOrders();
  Future<void> saveProduct(ProductModel product);
  Future<void> deleteProduct(String productId);
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
  Future<String> uploadProductImage(XFile file);
}

class FirestoreAdminRepository implements AdminRepository {
  FirestoreAdminRepository({
    FirebaseFirestore? firestore,
    CloudinaryService? cloudinaryService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _cloudinaryService = cloudinaryService ?? const CloudinaryService();

  final FirebaseFirestore _firestore;
  final CloudinaryService _cloudinaryService;

  bool get _isReady =>
      DefaultFirebaseOptions.isConfigured && Firebase.apps.isNotEmpty;

  @override
  Future<void> deleteProduct(String productId) async {
    _ensureReady();
    await _firestore.collection('products').doc(productId).delete();
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    if (!_isReady) return const <OrderModel>[];

    final snapshot = await _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    if (!_isReady) return const <ProductModel>[];

    final snapshot = await _firestore
        .collection('products')
        .orderBy('name')
        .get();

    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<void> saveProduct(ProductModel product) async {
    _ensureReady();

    final docRef = product.id.isEmpty
        ? _firestore.collection('products').doc()
        : _firestore.collection('products').doc(product.id);

    final now = DateTime.now();
    final payload = product.copyWith(
      id: docRef.id,
      updatedAt: now,
      createdAt: product.createdAt ?? now,
    );

    await docRef.set(payload.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    _ensureReady();
    await _firestore.collection('orders').doc(orderId).update(
      <String, dynamic>{'orderStatus': status.name},
    );
  }

  @override
  Future<String> uploadProductImage(XFile file) {
    return _cloudinaryService.uploadProductImage(file);
  }

  void _ensureReady() {
    if (!_isReady) {
      throw StateError(
        'Firebase is not configured yet. Run flutterfire configure and add '
        'the platform config files before using the admin panel.',
      );
    }
  }
}
