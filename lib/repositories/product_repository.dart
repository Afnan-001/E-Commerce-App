import 'package:shop/models/product_model.dart';
import 'package:shop/models/home_banner_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getCatalogProducts({String? category});
  Future<List<ProductModel>> getFeaturedProducts();
  Future<HomeBannerModel?> getHomeBanner();
}

class FirebaseProductRepository implements ProductRepository {
  FirebaseProductRepository({FirebaseFirestore? firestore})
    : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<ProductModel>> getCatalogProducts({String? category}) async {
    if (Firebase.apps.isEmpty) {
      return const <ProductModel>[];
    }

    Query<Map<String, dynamic>> query = _db
        .collection('products')
        .where('isActive', isEqualTo: true);

    if (category != null && category.trim().isNotEmpty) {
      query = query.where('category', isEqualTo: category.trim());
    }

    final snapshot = await query.get();

    final products =
        snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
            .toList()
          ..sort((a, b) {
            final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bDate.compareTo(aDate);
          });

    return products;
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    if (Firebase.apps.isEmpty) {
      return const <ProductModel>[];
    }

    final snapshot = await _db
        .collection('products')
        .where('isActive', isEqualTo: true)
        .where('isFeatured', isEqualTo: true)
        .limit(8)
        .get();

    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<HomeBannerModel?> getHomeBanner() async {
    if (Firebase.apps.isEmpty) {
      return null;
    }

    final doc = await _db.collection('banners').doc('home_main').get();
    if (!doc.exists) {
      return null;
    }

    return HomeBannerModel.fromMap(doc.id, doc.data() ?? <String, dynamic>{});
  }
}
