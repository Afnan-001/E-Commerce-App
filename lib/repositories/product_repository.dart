import 'package:shop/models/product_model.dart';
import 'package:shop/models/home_banner_model.dart';
import 'package:shop/models/delivery_settings_model.dart';
import 'package:shop/models/home_section_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class PaginatedResult<T> {
  const PaginatedResult({required this.items, this.lastDocument});

  final List<T> items;
  final DocumentSnapshot? lastDocument;
}

abstract class ProductRepository {
  Future<PaginatedResult<ProductModel>> getCatalogProducts({
    String? category,
    int? limit,
    DocumentSnapshot? startAfter,
  });
  Future<List<ProductModel>> searchProducts({
    required String query,
    int limit = 20,
  });
  Future<List<ProductModel>> getProductsByIds(List<String> ids);
  Future<List<ProductModel>> getFeaturedProducts();
  Future<List<HomeBannerModel>> getHomeBanners();
  Future<List<HomeSectionModel>> getHomeSections();
  Future<DeliverySettingsModel> getDeliverySettings();
}

class FirebaseProductRepository implements ProductRepository {
  FirebaseProductRepository({FirebaseFirestore? firestore})
    : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  @override
  Future<PaginatedResult<ProductModel>> getCatalogProducts({
    String? category,
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    if (Firebase.apps.isEmpty) {
      return const PaginatedResult<ProductModel>(items: <ProductModel>[]);
    }

    Query<Map<String, dynamic>> query = _db
        .collection('products')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    if (category != null && category.trim().isNotEmpty) {
      query = query.where('category', isEqualTo: category.trim());
    }

    if (limit != null && limit > 0) {
      query = query.limit(limit);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();

    final products = snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
        .toList();

    final lastDocument = snapshot.docs.isEmpty ? null : snapshot.docs.last;

    return PaginatedResult<ProductModel>(
      items: products,
      lastDocument: lastDocument,
    );
  }

  @override
  Future<List<ProductModel>> searchProducts({
    required String query,
    int limit = 20,
  }) async {
    if (Firebase.apps.isEmpty) {
      return const <ProductModel>[];
    }

    final normalized = query.trim();
    if (normalized.isEmpty) {
      return const <ProductModel>[];
    }

    final titleCaseQuery = _titleCaseQuery(normalized);
    final searchTerms = <String>{
      normalized,
      normalized.toLowerCase(),
      titleCaseQuery,
      normalized.toUpperCase(),
    }.where((term) => term.trim().isNotEmpty).toList();

    final futures = <Future<QuerySnapshot<Map<String, dynamic>>>>[];
    for (final term in searchTerms) {
      futures.add(_prefixQuery(field: 'name', term: term, limit: limit));
      futures.add(_prefixQuery(field: 'brandName', term: term, limit: limit));
      futures.add(_prefixQuery(field: 'category', term: term, limit: limit));
    }

    final snapshots = await Future.wait(futures);
    final productsById = <String, ProductModel>{};
    for (final snapshot in snapshots) {
      for (final doc in snapshot.docs) {
        final product = ProductModel.fromMap(doc.id, doc.data());
        if (!product.isActive) {
          continue;
        }
        productsById[doc.id] = product;
      }
    }

    final results = productsById.values.toList()
      ..sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

    return results.take(limit).toList();
  }

  @override
  Future<List<ProductModel>> getProductsByIds(List<String> ids) async {
    if (Firebase.apps.isEmpty || ids.isEmpty) {
      return const <ProductModel>[];
    }

    final uniqueIds = ids.toSet().toList();
    final products = <ProductModel>[];
    for (var index = 0; index < uniqueIds.length; index += 10) {
      final chunk = uniqueIds.skip(index).take(10).toList();
      final snapshot = await _db
          .collection('products')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      products.addAll(
        snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
            .where((product) => product.isActive),
      );
    }
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
  Future<List<HomeBannerModel>> getHomeBanners() async {
    if (Firebase.apps.isEmpty) {
      return const <HomeBannerModel>[];
    }

    final snapshot = await _db.collection('banners').get();
    final banners =
        snapshot.docs
            .map((doc) => HomeBannerModel.fromMap(doc.id, doc.data()))
            .where(
              (banner) => banner.imageUrl.trim().isNotEmpty && banner.isActive,
            )
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return banners;
  }

  @override
  Future<List<HomeSectionModel>> getHomeSections() async {
    if (Firebase.apps.isEmpty) {
      return const <HomeSectionModel>[];
    }

    final snapshot = await _db.collection('home_sections').get();
    final sections =
        snapshot.docs
            .map((doc) => HomeSectionModel.fromMap(doc.id, doc.data()))
            .where((section) => section.isWithinDisplayRange)
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return sections;
  }

  @override
  Future<DeliverySettingsModel> getDeliverySettings() async {
    if (Firebase.apps.isEmpty) {
      return const DeliverySettingsModel();
    }

    final snapshot = await _db
        .collection('store_config')
        .doc('delivery_settings')
        .get();
    if (!snapshot.exists) {
      return const DeliverySettingsModel();
    }
    return DeliverySettingsModel.fromMap(snapshot.data()!);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _prefixQuery({
    required String field,
    required String term,
    required int limit,
  }) {
    return _db
        .collection('products')
        .orderBy(field)
        .startAt(<String>[term])
        .endAt(<String>['$term\uf8ff'])
        .limit(limit)
        .get();
  }

  String _titleCaseQuery(String input) {
    return input
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.length > 1 ? part.substring(1).toLowerCase() : ''}',
        )
        .join(' ');
  }
}
