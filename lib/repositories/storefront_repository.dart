import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:shop/models/delivery_settings_model.dart';
import 'package:shop/models/home_section_model.dart';

abstract class StorefrontRepository {
  Future<DeliverySettingsModel> getDeliverySettings();
  Future<void> saveDeliverySettings(DeliverySettingsModel settings);
  Future<List<HomeSectionModel>> getHomeSections();
  Future<void> saveHomeSection(HomeSectionModel section);
  Future<void> deleteHomeSection(String sectionId);
}

class FirestoreStorefrontRepository implements StorefrontRepository {
  FirestoreStorefrontRepository({FirebaseFirestore? firestore})
    : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

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

  @override
  Future<void> saveDeliverySettings(DeliverySettingsModel settings) async {
    if (Firebase.apps.isEmpty) return;
    await _db
        .collection('store_config')
        .doc('delivery_settings')
        .set(settings.toMap(), SetOptions(merge: true));
  }

  @override
  Future<List<HomeSectionModel>> getHomeSections() async {
    if (Firebase.apps.isEmpty) return const <HomeSectionModel>[];

    final snapshot = await _db.collection('home_sections').get();
    final sections =
        snapshot.docs
            .map((doc) => HomeSectionModel.fromMap(doc.id, doc.data()))
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return sections;
  }

  @override
  Future<void> saveHomeSection(HomeSectionModel section) async {
    if (Firebase.apps.isEmpty) return;

    final docRef = section.id.trim().isEmpty
        ? _db.collection('home_sections').doc()
        : _db.collection('home_sections').doc(section.id);
    final payload = section.copyWith(
      id: docRef.id,
      updatedAt: DateTime.now(),
      createdAt: section.createdAt ?? DateTime.now(),
    );
    await docRef.set(payload.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteHomeSection(String sectionId) async {
    if (Firebase.apps.isEmpty) return;
    await _db.collection('home_sections').doc(sectionId).delete();
  }
}
