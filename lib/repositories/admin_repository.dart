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
  Future<void> upsertCategories(List<CategoryModel> categories);
  Future<void> deleteCategory(String categoryId);
  Future<void> saveProduct(ProductModel product);
  Future<void> deleteProduct(String productId);
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
  Future<String> uploadProductImage(XFile file);
  Future<String> uploadCategoryImage(XFile file);
  Future<String> uploadBannerImage(XFile file);
  Future<Map<String, String>> uploadCategoryAssets(List<String> assetPaths);
  Future<List<HomeBannerModel>> getHomeBanners();
  Future<void> saveHomeBanner(HomeBannerModel banner);
  Future<void> deleteHomeBanner(String bannerId);
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
    final docRef = _db.collection('products').doc(productId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      return;
    }

    final product = ProductModel.fromMap(snapshot.id, snapshot.data()!);
    await docRef.delete();
    await _cloudinaryService.deleteImagesByUrls(product.galleryImages);
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    _ensureReady();
    final batch = _db.batch();
    final categoriesRef = _db.collection('categories');
    final descendants = await categoriesRef
        .where('parentId', isEqualTo: categoryId)
        .get();
    final rootSnapshot = await categoriesRef.doc(categoryId).get();
    final imageUrlsToDelete = <String>[];

    if (rootSnapshot.exists) {
      final root = CategoryModel.fromMap(rootSnapshot.id, rootSnapshot.data()!);
      imageUrlsToDelete.addAll(_categoryImageUrls(root));
    }

    for (final doc in descendants.docs) {
      final category = CategoryModel.fromMap(doc.id, doc.data());
      imageUrlsToDelete.addAll(_categoryImageUrls(category));
      batch.delete(doc.reference);
    }
    batch.delete(categoriesRef.doc(categoryId));
    await batch.commit();
    await _cloudinaryService.deleteImagesByUrls(imageUrlsToDelete);
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

    final isNewProduct = product.id.isEmpty;
    final docRef = isNewProduct
        ? _db.collection('products').doc()
        : _db.collection('products').doc(product.id);
    ProductModel? previousProduct;
    if (!isNewProduct) {
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        previousProduct = ProductModel.fromMap(snapshot.id, snapshot.data()!);
      }
    }
    final payload = product.copyWith(id: docRef.id).toMap();

    payload['updatedAt'] = FieldValue.serverTimestamp();
    if (isNewProduct) {
      payload['createdAt'] = FieldValue.serverTimestamp();
    } else if (product.createdAt == null) {
      payload.remove('createdAt');
    }

    await docRef.set(payload, SetOptions(merge: true));

    if (previousProduct != null) {
      final removedImages = previousProduct.galleryImages
          .where((image) => !product.galleryImages.contains(image))
          .toList();
      await _cloudinaryService.deleteImagesByUrls(removedImages);
    }
  }

  @override
  Future<void> saveCategory(CategoryModel category) async {
    _ensureReady();

    final docRef = category.id.isEmpty
        ? _db.collection('categories').doc()
        : _db.collection('categories').doc(category.id);
    CategoryModel? previousCategory;
    if (category.id.isNotEmpty) {
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        previousCategory = CategoryModel.fromMap(snapshot.id, snapshot.data()!);
      }
    }

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

    if (previousCategory != null) {
      final removedImages = _categoryImageUrls(previousCategory)
          .where((image) => !_categoryImageUrls(payload).contains(image))
          .toList();
      await _cloudinaryService.deleteImagesByUrls(removedImages);
    }
  }

  @override
  Future<void> upsertCategories(List<CategoryModel> categories) async {
    _ensureReady();
    if (categories.isEmpty) return;

    final batch = _db.batch();
    for (final category in categories) {
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
      batch.set(docRef, payload.toMap(), SetOptions(merge: true));
    }
    await batch.commit();
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
  Future<String> uploadCategoryImage(XFile file) {
    return _cloudinaryService.uploadCategoryImage(file);
  }

  @override
  Future<String> uploadBannerImage(XFile file) {
    return _cloudinaryService.uploadBannerImage(file);
  }

  @override
  Future<Map<String, String>> uploadCategoryAssets(
    List<String> assetPaths,
  ) async {
    final result = <String, String>{};
    for (final assetPath in assetPaths) {
      final url = await _cloudinaryService.uploadAssetCategoryImage(assetPath);
      if (url.trim().isNotEmpty) {
        result[assetPath] = url.trim();
      }
    }
    return result;
  }

  @override
  Future<List<HomeBannerModel>> getHomeBanners() async {
    if (!_isReady) return const <HomeBannerModel>[];

    final snapshot = await _db.collection('banners').get();
    final banners = snapshot.docs
        .map((doc) => HomeBannerModel.fromMap(doc.id, doc.data()))
        .where((banner) => banner.imageUrl.trim().isNotEmpty)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return banners;
  }

  @override
  Future<void> saveHomeBanner(HomeBannerModel banner) async {
    _ensureReady();
    final docRef = banner.id.trim().isEmpty
        ? _db.collection('banners').doc()
        : _db.collection('banners').doc(banner.id);
    final payload = banner.copyWith(id: docRef.id, updatedAt: DateTime.now());
    await docRef.set(payload.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteHomeBanner(String bannerId) async {
    _ensureReady();
    await _db.collection('banners').doc(bannerId).delete();
  }

  void _ensureReady() {
    if (!_isReady) {
      throw StateError(
        'Firebase is not configured yet. Run flutterfire configure and add '
        'the platform config files before using the admin panel.',
      );
    }
  }

  List<String> _categoryImageUrls(CategoryModel category) {
    final urls = <String>{};
    if ((category.image ?? '').trim().isNotEmpty) {
      urls.add(category.image!.trim());
    }
    if ((category.svgSrc ?? '').trim().isNotEmpty) {
      urls.add(category.svgSrc!.trim());
    }
    return urls.toList();
  }
}
