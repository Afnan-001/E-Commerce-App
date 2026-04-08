import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:shop/models/address_model.dart';

abstract class AddressRepository {
  Future<List<AddressModel>> fetchAddresses(String userId);
  Future<AddressModel> addAddress(String userId, AddressModel address);
  Future<void> updateAddress(String userId, AddressModel address);
  Future<void> deleteAddress(String userId, String addressId);
  Future<void> setDefaultAddress(String userId, String addressId);
}

class FirestoreAddressRepository implements AddressRepository {
  FirestoreAddressRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  bool get _isReady => Firebase.apps.isNotEmpty;

  CollectionReference<Map<String, dynamic>> _addressesRef(String userId) {
    return _db.collection('users').doc(userId).collection('addresses');
  }

  @override
  Future<List<AddressModel>> fetchAddresses(String userId) async {
    _ensureReady();

    final snapshot = await _addressesRef(userId).get();
    return snapshot.docs
        .map((doc) => AddressModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<AddressModel> addAddress(String userId, AddressModel address) async {
    _ensureReady();

    final docRef = _addressesRef(userId).doc();
    final now = DateTime.now();
    final model = address.copyWith(
      id: docRef.id,
      createdAt: now,
      updatedAt: now,
    );

    await docRef.set(model.toMap());
    return model;
  }

  @override
  Future<void> updateAddress(String userId, AddressModel address) async {
    _ensureReady();

    await _addressesRef(userId).doc(address.id).set(
          address.copyWith(updatedAt: DateTime.now()).toMap(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> deleteAddress(String userId, String addressId) async {
    _ensureReady();

    await _addressesRef(userId).doc(addressId).delete();
  }

  @override
  Future<void> setDefaultAddress(String userId, String addressId) async {
    _ensureReady();

    final batch = _db.batch();
    final ref = _addressesRef(userId);
    final snapshot = await ref.get();

    for (final doc in snapshot.docs) {
      final shouldBeDefault = doc.id == addressId;
      batch.set(
        doc.reference,
        {
          'isDefault': shouldBeDefault,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  void _ensureReady() {
    if (!_isReady) {
      throw StateError(
        'Firebase is not configured yet. Run flutterfire configure and add '
        'the platform config files before using address storage.',
      );
    }
  }
}
