import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop/core/services/cloudinary_service.dart';
import 'package:shop/models/category_model.dart';
import 'package:shop/models/home_banner_model.dart';
import 'package:shop/models/order_model.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/repositories/order_repository.dart';

abstract class AdminRepository {
  Future<List<CategoryModel>> getCategories();
  Future<List<ProductModel>> getProducts();
  Future<List<OrderModel>> getOrders();
  Future<void> saveCategory(CategoryModel category);
  Future<void> deleteCategory(String categoryId);
  Future<void> saveProduct(ProductModel product);
  Future<void> deleteProduct(String productId);
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
  Future<String> uploadProductImage(XFile file);
  Future<HomeBannerModel?> getHomeBanner();
  Future<void> saveHomeBanner(HomeBannerModel banner);
}

class FirestoreAdminRepository implements AdminRepository {
  FirestoreAdminRepository({
    FirebaseFirestore? firestore,
    CloudinaryService? cloudinaryService,
  }) : _firestore = firestore,
       _cloudinaryService = cloudinaryService ?? const CloudinaryService(),
       _orderRepository = FirestoreOrderRepository(firestore: firestore);

  final FirebaseFirestore? _firestore;
  final CloudinaryService _cloudinaryService;
  final OrderRepository _orderRepository;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  bool get _isReady => Firebase.apps.isNotEmpty;

  @override
  Future<void> deleteProduct(String productId) async {
    _ensureReady();
    await _db.collection('products').doc(productId).delete();
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    _ensureReady();
    await _db.collection('categories').doc(categoryId).delete();
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    if (!_isReady) return const <CategoryModel>[];

    final snapshot = await _db.collection('categories').get();
    final categories =
        snapshot.docs
            .map((doc) => CategoryModel.fromMap(doc.id, doc.data()))
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return categories;
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    return _orderRepository.getAllOrders();
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    if (!_isReady) return const <ProductModel>[];

    final snapshot = await _db.collection('products').get();

    final products =
        snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
            .toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );

    return products;
  }

  @override
  Future<void> saveProduct(ProductModel product) async {
    _ensureReady();

    final docRef = product.id.isEmpty
        ? _db.collection('products').doc()
        : _db.collection('products').doc(product.id);

    final now = DateTime.now();
    final payload = product.copyWith(
      id: docRef.id,
      updatedAt: now,
      createdAt: product.createdAt ?? now,
    );

    await docRef.set(payload.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> saveCategory(CategoryModel category) async {
    _ensureReady();

    final docRef = category.id.isEmpty
        ? _db.collection('categories').doc()
        : _db.collection('categories').doc(category.id);

    final payload = CategoryModel(
      id: docRef.id,
      title: category.title,
      image: category.image,
      svgSrc: category.svgSrc,
      parentId: category.parentId,
      subCategories: category.subCategories,
      isActive: category.isActive,
      sortOrder: category.sortOrder,
    );

    await docRef.set(payload.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _orderRepository.updateOrderStatus(orderId, status);
  }

  @override
  Future<String> uploadProductImage(XFile file) {
    return _cloudinaryService.uploadProductImage(file);
  }

  @override
  Future<HomeBannerModel?> getHomeBanner() async {
    if (!_isReady) return null;
    final doc = await _db.collection('banners').doc('home_main').get();
    if (!doc.exists) {
      return null;
    }
    return HomeBannerModel.fromMap(doc.id, doc.data() ?? <String, dynamic>{});
  }

  @override
  Future<void> saveHomeBanner(HomeBannerModel banner) async {
    _ensureReady();
    final payload = banner.copyWith(id: 'home_main', updatedAt: DateTime.now());
    await _db
        .collection('banners')
        .doc('home_main')
        .set(payload.toMap(), SetOptions(merge: true));
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
