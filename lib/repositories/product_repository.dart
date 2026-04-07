import 'package:shop/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shop/firebase_options.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getPopularProducts();
  Future<List<ProductModel>> getFlashSaleProducts();
  Future<List<ProductModel>> getBestSellerProducts();
  Future<List<ProductModel>> getMostPopularProducts();
  Future<List<ProductModel>> getBookmarkedProducts();
}

class FirebaseProductRepository implements ProductRepository {
  FirebaseProductRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<List<ProductModel>> getBestSellerProducts() async {
    return _loadProducts(
      queryBuilder: (collection) =>
          collection.where('isActive', isEqualTo: true).limit(10),
    );
  }

  @override
  Future<List<ProductModel>> getBookmarkedProducts() async {
    return const <ProductModel>[];
  }

  @override
  Future<List<ProductModel>> getFlashSaleProducts() async {
    return _loadProducts(
      queryBuilder: (collection) => collection
          .where('isActive', isEqualTo: true)
          .where('salePrice', isNull: false)
          .limit(10),
    );
  }

  @override
  Future<List<ProductModel>> getMostPopularProducts() async {
    return _loadProducts(
      queryBuilder: (collection) =>
          collection.where('isActive', isEqualTo: true).limit(10),
    );
  }

  @override
  Future<List<ProductModel>> getPopularProducts() async {
    return _loadProducts(
      queryBuilder: (collection) => collection
          .where('isActive', isEqualTo: true)
          .where('isFeatured', isEqualTo: true)
          .limit(10),
    );
  }

  Future<List<ProductModel>> _loadProducts({
    required Query<Map<String, dynamic>> Function(
      CollectionReference<Map<String, dynamic>> collection,
    ) queryBuilder,
  }) async {
    if (!DefaultFirebaseOptions.isConfigured || Firebase.apps.isEmpty) {
      return const <ProductModel>[];
    }

    final collection = _firestore.collection('products');
    final snapshot = await queryBuilder(collection).get();

    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
        .toList();
  }
}
