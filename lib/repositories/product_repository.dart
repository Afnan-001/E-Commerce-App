import 'package:shop/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getCatalogProducts();
  Future<List<ProductModel>> getPopularProducts();
  Future<List<ProductModel>> getFlashSaleProducts();
  Future<List<ProductModel>> getBestSellerProducts();
  Future<List<ProductModel>> getMostPopularProducts();
  Future<List<ProductModel>> getBookmarkedProducts();
}

class FirebaseProductRepository implements ProductRepository {
  FirebaseProductRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<ProductModel>> getCatalogProducts() async {
    return _loadActiveProducts();
  }

  @override
  Future<List<ProductModel>> getBestSellerProducts() async {
    final products = await _loadActiveProducts();
    return products.take(10).toList();
  }

  @override
  Future<List<ProductModel>> getBookmarkedProducts() async {
    return const <ProductModel>[];
  }

  @override
  Future<List<ProductModel>> getFlashSaleProducts() async {
    final products = await _loadActiveProducts();
    return products.where((product) => product.salePrice != null).take(10).toList();
  }

  @override
  Future<List<ProductModel>> getMostPopularProducts() async {
    final products = await _loadActiveProducts();
    return products.take(10).toList();
  }

  @override
  Future<List<ProductModel>> getPopularProducts() async {
    final products = await _loadActiveProducts();
    return products.where((product) => product.isFeatured).take(10).toList();
  }

  Future<List<ProductModel>> _loadActiveProducts() async {
    if (Firebase.apps.isEmpty) {
      return const <ProductModel>[];
    }

    final snapshot = await _db.collection('products').get();

    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
        .where((product) => product.isActive)
        .toList();
  }
}
