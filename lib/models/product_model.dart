import 'package:flutter/foundation.dart';

import 'package:shop/constants.dart';

@immutable
class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.brandName,
    required this.price,
    required this.imageUrl,
    this.description = '',
    this.categoryId = '',
    this.categoryName = '',
    this.salePrice,
    this.discountPercent,
    this.stockQuantity = 0,
    this.isActive = true,
    this.isFeatured = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String brandName;
  final String description;
  final String categoryId;
  final String categoryName;
  final double price;
  final double? salePrice;
  final int? discountPercent;
  final String imageUrl;
  final int stockQuantity;
  final bool isActive;
  final bool isFeatured;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get title => name;
  String get image => imageUrl;
  double? get priceAfetDiscount => salePrice;
  int? get dicountpercent => discountPercent;
  bool get hasDiscount => salePrice != null && salePrice! < price;

  ProductModel copyWith({
    String? id,
    String? name,
    String? brandName,
    String? description,
    String? categoryId,
    String? categoryName,
    double? price,
    double? salePrice,
    int? discountPercent,
    String? imageUrl,
    int? stockQuantity,
    bool? isActive,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      brandName: brandName ?? this.brandName,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      price: price ?? this.price,
      salePrice: salePrice ?? this.salePrice,
      discountPercent: discountPercent ?? this.discountPercent,
      imageUrl: imageUrl ?? this.imageUrl,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ProductModel.fromMap(String id, Map<String, dynamic> data) {
    return ProductModel(
      id: id,
      name: data['name'] as String? ?? '',
      brandName: data['brandName'] as String? ?? '',
      description: data['description'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      categoryName: data['categoryName'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      salePrice: (data['salePrice'] as num?)?.toDouble(),
      discountPercent: data['discountPercent'] as int?,
      imageUrl: data['imageUrl'] as String? ?? '',
      stockQuantity: data['stockQuantity'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      isFeatured: data['isFeatured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'brandName': brandName,
      'description': description,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'price': price,
      'salePrice': salePrice,
      'discountPercent': discountPercent,
      'imageUrl': imageUrl,
      'stockQuantity': stockQuantity,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

const List<ProductModel> demoPopularProducts = <ProductModel>[
  ProductModel(
    id: 'prod_dog_shampoo',
    name: 'Oatmeal Dog Shampoo',
    brandName: 'PawPure',
    price: 549,
    salePrice: 449,
    discountPercent: 18,
    imageUrl: productDemoImg1,
    categoryId: 'cat_grooming',
    categoryName: 'Grooming',
    description: 'Gentle shampoo for regular dog coat care and odor control.',
    stockQuantity: 24,
    isFeatured: true,
  ),
  ProductModel(
    id: 'prod_cat_brush',
    name: 'Deshedding Cat Brush',
    brandName: 'WhiskerCare',
    price: 699,
    imageUrl: productDemoImg4,
    categoryId: 'cat_accessories',
    categoryName: 'Accessories',
    description: 'Soft grip grooming brush for cats and small pets.',
    stockQuantity: 18,
    isFeatured: true,
  ),
  ProductModel(
    id: 'prod_paw_balm',
    name: 'Natural Paw Balm',
    brandName: 'PawPure',
    price: 399,
    salePrice: 329,
    discountPercent: 18,
    imageUrl: productDemoImg5,
    categoryId: 'cat_health',
    categoryName: 'Care',
    description: 'Moisturizing paw balm for dry, cracked paw pads.',
    stockQuantity: 40,
  ),
  ProductModel(
    id: 'prod_flea_combo',
    name: 'Flea Care Combo Pack',
    brandName: 'PetShield',
    price: 1199,
    salePrice: 999,
    discountPercent: 17,
    imageUrl: productDemoImg6,
    categoryId: 'cat_health',
    categoryName: 'Care',
    description: 'Shampoo and spray combo for pet coat hygiene support.',
    stockQuantity: 12,
  ),
];

const List<ProductModel> demoFlashSaleProducts = <ProductModel>[
  ProductModel(
    id: 'prod_grooming_wipes',
    name: 'Pet Grooming Wipes',
    brandName: 'FreshPaws',
    price: 299,
    salePrice: 219,
    discountPercent: 27,
    imageUrl: productDemoImg5,
    categoryId: 'cat_grooming',
    categoryName: 'Grooming',
    description: 'Quick-clean wipes for paws, ears, and fur.',
    stockQuantity: 35,
  ),
  ProductModel(
    id: 'prod_bow_tie',
    name: 'Pet Bow Tie Collar',
    brandName: 'PawStyle',
    price: 449,
    salePrice: 349,
    discountPercent: 22,
    imageUrl: productDemoImg6,
    categoryId: 'cat_accessories',
    categoryName: 'Accessories',
    description: 'Adjustable collar with soft festive bow tie.',
    stockQuantity: 26,
  ),
  ProductModel(
    id: 'prod_puppy_kit',
    name: 'Starter Puppy Grooming Kit',
    brandName: 'PetNest',
    price: 1499,
    salePrice: 1249,
    discountPercent: 16,
    imageUrl: productDemoImg4,
    categoryId: 'cat_grooming',
    categoryName: 'Grooming',
    description: 'Beginner-friendly grooming essentials for puppies.',
    stockQuantity: 10,
  ),
];

const List<ProductModel> demoBestSellersProducts = <ProductModel>[
  ProductModel(
    id: 'prod_tick_comb',
    name: 'Anti-Tick Steel Comb',
    brandName: 'PetShield',
    price: 349,
    salePrice: 279,
    discountPercent: 20,
    imageUrl: productDemoImg2,
    categoryId: 'cat_grooming',
    categoryName: 'Grooming',
    description: 'Fine-tooth comb built for regular anti-tick grooming.',
    stockQuantity: 28,
    isFeatured: true,
  ),
  ProductModel(
    id: 'prod_calming_spray',
    name: 'Calming Coat Spray',
    brandName: 'WhiskerCare',
    price: 599,
    salePrice: 499,
    discountPercent: 17,
    imageUrl: productDemoImg3,
    categoryId: 'cat_health',
    categoryName: 'Care',
    description: 'Light leave-in spray to freshen and soften the coat.',
    stockQuantity: 14,
  ),
  ProductModel(
    id: 'prod_pet_perfume',
    name: 'Mild Pet Cologne',
    brandName: 'FreshPaws',
    price: 799,
    imageUrl: productDemoImg4,
    categoryId: 'cat_grooming',
    categoryName: 'Grooming',
    description: 'Long-lasting fresh scent made for dogs and cats.',
    stockQuantity: 11,
  ),
];

const List<ProductModel> kidsProducts = <ProductModel>[
  ProductModel(
    id: 'prod_small_breed_harness',
    name: 'Small Breed Harness',
    brandName: 'PawStyle',
    price: 899,
    salePrice: 749,
    discountPercent: 17,
    imageUrl: 'https://i.imgur.com/dbbT6PA.png',
    categoryId: 'cat_accessories',
    categoryName: 'Accessories',
    description: 'Lightweight harness for puppies and toy breeds.',
    stockQuantity: 15,
  ),
  ProductModel(
    id: 'prod_puppy_shampoo',
    name: 'Puppy Wash Foam',
    brandName: 'PetNest',
    price: 499,
    imageUrl: 'https://i.imgur.com/7fSxC7k.png',
    categoryId: 'cat_grooming',
    categoryName: 'Grooming',
    description: 'Tear-free foam wash for young pets.',
    stockQuantity: 22,
  ),
  ProductModel(
    id: 'prod_nail_clipper',
    name: 'Pet Nail Clipper',
    brandName: 'PawPure',
    price: 399,
    imageUrl: 'https://i.imgur.com/pXnYE9Q.png',
    categoryId: 'cat_grooming',
    categoryName: 'Grooming',
    description: 'Safety-lock nail clipper for quick grooming sessions.',
    stockQuantity: 30,
  ),
  ProductModel(
    id: 'prod_travel_bowl',
    name: 'Collapsible Travel Bowl',
    brandName: 'PetNest',
    price: 299,
    salePrice: 239,
    discountPercent: 20,
    imageUrl: 'https://i.imgur.com/V1MXgfa.png',
    categoryId: 'cat_accessories',
    categoryName: 'Accessories',
    description: 'Portable silicone bowl for food and water on the go.',
    stockQuantity: 33,
  ),
];
