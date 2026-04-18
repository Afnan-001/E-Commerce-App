import 'package:flutter/foundation.dart';

@immutable
class ProductOptionModel {
  const ProductOptionModel({
    required this.id,
    required this.label,
    required this.price,
    this.salePrice,
    this.stockQuantity = 0,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final double price;
  final double? salePrice;
  final int stockQuantity;
  final bool isDefault;

  bool get hasDiscount => salePrice != null && salePrice! < price;
  double get effectivePrice => hasDiscount ? salePrice! : price;
  int? get discountPercent {
    if (!hasDiscount || price <= 0) return null;
    return (((price - salePrice!) / price) * 100).round();
  }

  ProductOptionModel copyWith({
    String? id,
    String? label,
    double? price,
    double? salePrice,
    int? stockQuantity,
    bool? isDefault,
  }) {
    return ProductOptionModel(
      id: id ?? this.id,
      label: label ?? this.label,
      price: price ?? this.price,
      salePrice: salePrice ?? this.salePrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  factory ProductOptionModel.fromMap(Map<String, dynamic> data) {
    final price = (data['price'] as num?)?.toDouble() ?? 0;
    final salePrice = (data['salePrice'] as num?)?.toDouble();
    return ProductOptionModel(
      id: data['id'] as String? ?? '',
      label: data['label'] as String? ?? '',
      price: price,
      salePrice: salePrice,
      stockQuantity: data['stockQuantity'] as int? ?? 0,
      isDefault: data['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'price': price,
      'salePrice': salePrice,
      'stockQuantity': stockQuantity,
      'isDefault': isDefault,
    };
  }
}
