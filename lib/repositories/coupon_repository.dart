import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:shop/models/coupon_model.dart';

abstract class CouponRepository {
  Future<List<CouponModel>> getCoupons();
  Future<CouponModel?> getCouponByCode(String code);
  Future<void> saveCoupon(CouponModel coupon);
  Future<void> deleteCoupon(String couponId);
  Future<void> incrementCouponUsage(String couponId);
}

class FirestoreCouponRepository implements CouponRepository {
  FirestoreCouponRepository({FirebaseFirestore? firestore})
    : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<CouponModel>> getCoupons() async {
    if (Firebase.apps.isEmpty) return const <CouponModel>[];

    final snapshot = await _db.collection('coupons').get();
    final coupons =
        snapshot.docs
            .map((doc) => CouponModel.fromMap(doc.id, doc.data()))
            .toList()
          ..sort((a, b) => a.code.compareTo(b.code));
    return coupons;
  }

  @override
  Future<CouponModel?> getCouponByCode(String code) async {
    if (Firebase.apps.isEmpty) return null;

    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) return null;

    final snapshot = await _db
        .collection('coupons')
        .where('code', isEqualTo: normalized)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return CouponModel.fromMap(doc.id, doc.data());
  }

  @override
  Future<void> saveCoupon(CouponModel coupon) async {
    if (Firebase.apps.isEmpty) return;

    final docRef = coupon.id.trim().isEmpty
        ? _db.collection('coupons').doc()
        : _db.collection('coupons').doc(coupon.id);
    final payload = coupon.copyWith(
      id: docRef.id,
      updatedAt: DateTime.now(),
      createdAt: coupon.createdAt ?? DateTime.now(),
    );
    await docRef.set(payload.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteCoupon(String couponId) async {
    if (Firebase.apps.isEmpty) return;
    await _db.collection('coupons').doc(couponId).delete();
  }

  @override
  Future<void> incrementCouponUsage(String couponId) async {
    if (Firebase.apps.isEmpty || couponId.trim().isEmpty) return;
    await _db.collection('coupons').doc(couponId).set(<String, dynamic>{
      'usageCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
