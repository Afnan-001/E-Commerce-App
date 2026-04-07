import 'package:flutter/foundation.dart';

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
