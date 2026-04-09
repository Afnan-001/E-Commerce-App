import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.description = '',
    this.category = '',
    this.brandName = '',
    this.salePrice,
    this.discountPercent,
    this.stockQuantity = 0,
    this.isActive = true,
    this.isFeatured = false,
    this.isPopular = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String category;
  final String brandName;
  final String description;
  final double price;
  final double? salePrice;
  final int? discountPercent;
  final String imageUrl;
  final int stockQuantity;
  final bool isActive;
  final bool isFeatured;
  final bool isPopular;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get title => name;
  String get image => imageUrl;
  String get categoryId => category;
  String get categoryName => category;
  double? get priceAfetDiscount => salePrice;
  int? get dicountpercent => discountPercent;
  bool get hasDiscount => salePrice != null && salePrice! < price;

  ProductModel copyWith({
    String? id,
    String? name,
    String? category,
    String? brandName,
    String? description,
    double? price,
    double? salePrice,
    int? discountPercent,
    String? imageUrl,
    int? stockQuantity,
    bool? isActive,
    bool? isFeatured,
    bool? isPopular,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      brandName: brandName ?? this.brandName,
      description: description ?? this.description,
      price: price ?? this.price,
      salePrice: salePrice ?? this.salePrice,
      discountPercent: discountPercent ?? this.discountPercent,
      imageUrl: imageUrl ?? this.imageUrl,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      isPopular: isPopular ?? this.isPopular,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ProductModel.fromMap(String id, Map<String, dynamic> data) {
    final basePrice = (data['price'] as num?)?.toDouble() ?? 0;
    final parsedSalePrice = (data['salePrice'] as num?)?.toDouble();
    return ProductModel(
      id: id,
      name: data['name'] as String? ?? '',
      category:
          data['category'] as String? ?? data['categoryName'] as String? ?? '',
      brandName: data['brandName'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: basePrice,
      salePrice: parsedSalePrice,
      discountPercent:
          data['discountPercent'] as int? ??
          _discountFromPrices(basePrice, parsedSalePrice),
      imageUrl: data['imageUrl'] as String? ?? '',
      stockQuantity: data['stockQuantity'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      isFeatured: data['isFeatured'] as bool? ?? false,
      isPopular: data['isPopular'] as bool? ?? false,
      createdAt: _dateTimeFromValue(data['createdAt']),
      updatedAt: _dateTimeFromValue(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'brandName': brandName,
      'description': description,
      'category': category,
      'price': price,
      'salePrice': salePrice,
      'discountPercent': discountPercent,
      'imageUrl': imageUrl,
      'stockQuantity': stockQuantity,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'isPopular': isPopular,
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
    };
  }

  static DateTime? _dateTimeFromValue(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static int? _discountFromPrices(double price, double? salePrice) {
    if (salePrice == null || salePrice >= price || price <= 0) {
      return null;
    }

    return (((price - salePrice) / price) * 100).round();
  }
}
