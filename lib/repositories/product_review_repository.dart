import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:shop/models/product_review_model.dart';

abstract class ProductReviewRepository {
  Stream<List<ProductReviewModel>> watchReviews(String productId);
  Future<void> upsertReview({
    required String productId,
    required ProductReviewModel review,
  });
}

class FirestoreProductReviewRepository implements ProductReviewRepository {
  FirestoreProductReviewRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  bool get _isReady => Firebase.apps.isNotEmpty;

  CollectionReference<Map<String, dynamic>> _reviewsCollection(String productId) {
    return _db.collection('products').doc(productId).collection('reviews');
  }

  @override
  Future<void> upsertReview({
    required String productId,
    required ProductReviewModel review,
  }) async {
    if (!_isReady) {
      throw StateError('Firebase is not configured yet.');
    }
    if (productId.trim().isEmpty || review.userId.trim().isEmpty) {
      throw ArgumentError('Product id and user id are required.');
    }

    await _reviewsCollection(productId).doc(review.userId).set(
      <String, dynamic>{
        'userId': review.userId,
        'userName': review.userName,
        'userEmail': review.userEmail,
        'rating': review.rating,
        'comment': review.comment,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Stream<List<ProductReviewModel>> watchReviews(String productId) {
    if (!_isReady || productId.trim().isEmpty) {
      return const Stream<List<ProductReviewModel>>.empty();
    }

    return _reviewsCollection(productId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductReviewModel.fromMap(doc.data()))
              .toList(),
        );
  }
}
