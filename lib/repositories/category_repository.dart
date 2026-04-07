import 'package:shop/models/category_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

abstract class CategoryRepository {
  Future<List<CategoryModel>> getDiscoverCategories();
}

class FirebaseCategoryRepository implements CategoryRepository {
  FirebaseCategoryRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<List<CategoryModel>> getDiscoverCategories() async {
    if (Firebase.apps.isEmpty) {
      return const <CategoryModel>[];
    }

    final snapshot = await _firestore
        .collection('categories')
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .get();

    final categories = snapshot.docs
        .map((doc) => CategoryModel.fromMap(doc.id, doc.data()))
        .toList();

    final parentCategories =
        categories.where((category) => category.parentId == null).toList();

    return parentCategories.map((parent) {
      final children = categories
          .where((category) => category.parentId == parent.id)
          .toList();
      return CategoryModel(
        id: parent.id,
        title: parent.title,
        image: parent.image,
        svgSrc: parent.svgSrc,
        parentId: parent.parentId,
        subCategories: children,
        isActive: parent.isActive,
        sortOrder: parent.sortOrder,
      );
    }).toList();
  }
}
