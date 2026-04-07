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

const List<CategoryModel> demoCategoriesWithImage = <CategoryModel>[
  CategoryModel(
    id: 'cat_grooming',
    title: 'Pet Grooming',
    image: 'https://i.imgur.com/5M89G2P.png',
    sortOrder: 0,
  ),
  CategoryModel(
    id: 'cat_food',
    title: 'Pet Food',
    image: 'https://i.imgur.com/UM3GdWg.png',
    sortOrder: 1,
  ),
  CategoryModel(
    id: 'cat_accessories',
    title: 'Accessories',
    image: 'https://i.imgur.com/Lp0D6k5.png',
    sortOrder: 2,
  ),
  CategoryModel(
    id: 'cat_health',
    title: 'Health & Care',
    image: 'https://i.imgur.com/3mSE5sN.png',
    sortOrder: 3,
  ),
];

const List<CategoryModel> demoCategories = <CategoryModel>[
  CategoryModel(
    id: 'cat_grooming',
    title: 'Grooming',
    svgSrc: 'assets/icons/Sale.svg',
    subCategories: <CategoryModel>[
      CategoryModel(id: 'sub_bath', title: 'Bath & Spa'),
      CategoryModel(id: 'sub_coat', title: 'Coat Care'),
      CategoryModel(id: 'sub_nail', title: 'Nail Care'),
    ],
  ),
  CategoryModel(
    id: 'cat_food',
    title: 'Food',
    svgSrc: 'assets/icons/Man&Woman.svg',
    subCategories: <CategoryModel>[
      CategoryModel(id: 'sub_dog_food', title: 'Dog Food'),
      CategoryModel(id: 'sub_cat_food', title: 'Cat Food'),
      CategoryModel(id: 'sub_treats', title: 'Treats'),
    ],
  ),
  CategoryModel(
    id: 'cat_accessories',
    title: 'Accessories',
    svgSrc: 'assets/icons/Child.svg',
    subCategories: <CategoryModel>[
      CategoryModel(id: 'sub_collar', title: 'Collars & Leashes'),
      CategoryModel(id: 'sub_beds', title: 'Beds'),
      CategoryModel(id: 'sub_bowls', title: 'Bowls'),
    ],
  ),
  CategoryModel(
    id: 'cat_health',
    title: 'Health & Care',
    svgSrc: 'assets/icons/Accessories.svg',
    subCategories: <CategoryModel>[
      CategoryModel(id: 'sub_supplements', title: 'Supplements'),
      CategoryModel(id: 'sub_skin', title: 'Skin Care'),
      CategoryModel(id: 'sub_ticks', title: 'Tick & Flea Care'),
    ],
  ),
];
