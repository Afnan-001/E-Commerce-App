import 'package:flutter/foundation.dart';

@immutable
class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.title,
    this.image,
    this.svgSrc,
    this.parentId,
    this.subCategories = const <CategoryModel>[],
    this.isActive = true,
    this.sortOrder = 0,
  });

  final String id;
  final String title;
  final String? image;
  final String? svgSrc;
  final String? parentId;
  final List<CategoryModel> subCategories;
  final bool isActive;
  final int sortOrder;

  factory CategoryModel.fromMap(String id, Map<String, dynamic> data) {
    return CategoryModel(
      id: id,
      title: data['title'] as String? ?? '',
      image: data['image'] as String?,
      svgSrc: data['svgSrc'] as String?,
      parentId: data['parentId'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      sortOrder: data['sortOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'image': image,
      'svgSrc': svgSrc,
      'parentId': parentId,
      'isActive': isActive,
      'sortOrder': sortOrder,
    };
  }
}
